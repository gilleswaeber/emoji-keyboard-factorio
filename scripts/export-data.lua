local collect_data = require("collect-data")
local json = require("json")
local utils = require("utils")

local folder = "emoji-keyboard-export/"
local color_error = {r = 1, g = 0, b = 0}
local color_warn = {r = 1, g = 0.5, b = 0}
local color_good = {r = 0, g = 1, b = 0}
local player

local function add_icon(hash_id, name, scale, sprite, icons)
  if hash_id ~= -1 then
    if hash_id then
      for _, icon in pairs(icons) do
        if icon.hash_id == hash_id then
          table.insert(icon.copies, name)
          return
        end
      end
    end

    table.insert(icons, {hash_id = hash_id, name = name, scale = scale, sprite = sprite, copies = {}})
  end
end

local function check_recipe_name(recipe_id_claimed, desired_id, backup_id, icons)
  if recipe_id_claimed[desired_id] then
    for _, icon in pairs(icons) do
      if icon.name == desired_id then
        table.insert(icon.copies, backup_id)
        break
      end
    end

    recipe_id_claimed[backup_id] = true
    return backup_id
  end

  recipe_id_claimed[desired_id] = true
  return desired_id
end

local function check_icon_name(desired_id, backup_id, icons)
  for _, icon in pairs(icons) do
    if icon.name == desired_id then
      return backup_id
    else
      for _, copy in pairs(icon.copies) do
        if copy == desired_id then
          return backup_id
        end
      end
    end
  end

  return desired_id
end

return function(player_index, language_data)
  player = game.players[player_index]
  local player_settings = settings.get_player_settings(player)
  local dictionaries = language_data.dictionaries
  local language = language_data.language

  local function warn_player(msg)
    player.print(msg, color_warn)
  end

  -- Localized names
  local group_names = dictionaries["item_group_names"]
  local item_names = dictionaries["item_names"]
  local fluid_names = dictionaries["fluid_names"]
  local recipe_names = dictionaries["recipe_names"]
  local technology_names = dictionaries["technology_names"]
  local gui_names = dictionaries["other_names"]
  local virtual_signal_names = dictionaries["virtual_signal_names"]
  local entity_names = dictionaries["entity_names"]

  local sorted_protos = collect_data()
  local icons = {}
  local recipe_id_claimed = {}

  -- Final data collections
  local sprite_map_index = {}
  local by_group = {}
  local by_group_recipes = {}

  local board_name = "Factorio"
  local board_sprite = "inserter"

  -- Build ID based on active mods
  local build_id = game.active_mods['base'] .. "-"
  local version = {}
  if game.active_mods['space-exploration'] ~= nil then
    build_id = build_id .. "se" .. game.active_mods['space-exploration'] .. "-"
    board_name = board_name .. " SE"
    board_sprite = "se-spaceship"
  end
  for name, ver in pairs(game.active_mods) do
    if name ~= "emoji-keyboard-export" and name ~= "flib" then
      version[name] = ver
    end
  end
  build_id = build_id .. language
  local sprite_map_name = "factorio" .. "-" .. build_id
  local sprite_map_path = "factorio-icons-" .. build_id .. ".png"
  local plugin_file_path = "factorio-plugin-" .. build_id .. ".json"

  group_names["research"] = gui_names["research"]
  for name, _ in pairs(group_names) do
    by_group[name] = {}
    by_group_recipes[name] = {}
  end

  -- Process items
  for _, proto in pairs(sorted_protos) do
    if proto.item then
      local item = proto.item
      local name = item.name
      table.insert(by_group[item.group.name], {
        cluster = "[item=" .. name .. "]",
        name = item_names[name],
        symbol = {
          spriteMap = sprite_map_name,
          sprite = name,
        },
      })
      local hash_id, scale = utils.get_order_info("item/" .. name)
      add_icon(hash_id, name, scale or 2, "item/" .. name, icons)
    end

    if proto.fluid then
      local fluid = proto.fluid
      local name = fluid.name
      if fluid then
        table.insert(by_group[fluid.group.name], {
          cluster = "[fluid=" .. name .. "]",
          name = fluid_names[name],
          symbol = {
            spriteMap = sprite_map_name,
            sprite = name,
          },
        })
        local hash_id, scale = utils.get_order_info("fluid/" .. name)
        add_icon(hash_id, name, scale or 2, "fluid/" .. name, icons)
      else
        player.print({"emoji-keyboard-export.error-no-item-prototype", name}, color_error)
      end
    end

    if proto.recipe then
      recipe_id_claimed[proto.recipe.name] = true
    end
  end

  -- Process recipes
  for _, proto in pairs(sorted_protos) do
    if proto.recipe then
      local recipe = proto.recipe
      local name = recipe.name
      local hash_id, scale = utils.get_order_info("recipe/" .. name)
      if hash_id and hash_id ~= -1 then
        local icon_id = check_icon_name(name, name .. "|recipe", icons)

        table.insert(by_group_recipes[recipe.group.name], {
          cluster = "[recipe=" .. name .. "]",
          name = recipe_names[name],
          symbol = {
            spriteMap = sprite_map_name,
            sprite = icon_id,
          },
        })

        add_icon(hash_id, icon_id, scale or 2, "recipe/" .. name, icons)
      end
    end
  end

  -- Process signals
  for name, _signal in pairs(game.virtual_signal_prototypes) do
    local hash_id, scale = utils.get_order_info("virtual-signal/" .. name)
    local icon_id = check_icon_name(name, name .. "|signal", icons)
    table.insert(by_group["signals"], {
      cluster = "[virtual-signal=" .. name .. "]",
      name = virtual_signal_names[name],
      symbol = {
        spriteMap = sprite_map_name,
        sprite = icon_id,
      },
    })

    add_icon(hash_id, icon_id, scale or 2, "virtual-signal/" .. name, icons)
  end

  -- Process entities
  for name, entity in pairs(game.entity_prototypes) do
    local remnants = "-remnants"
    local hash_id, scale = utils.get_order_info("entity/" .. name)
    if hash_id ~= nil and name:sub(-#remnants) ~= remnants then -- and entity.selectable_in_game 
      local icon_id = check_icon_name(name, name .. "|entity", icons)
      table.insert(by_group[entity.group.name], {
        cluster = "[entity=" .. name .. "]",
        name = entity_names[name],
        symbol = {
          spriteMap = sprite_map_name,
          sprite = icon_id,
        },
      })
      add_icon(hash_id, icon_id, scale or 2, "entity/" .. name, icons)
    end
  end

  -- Process Technologies
  for name, tech in pairs(game.technology_prototypes) do
    local desired_id = name
    local backup_id = name .. "-technology"
    local id = check_recipe_name(recipe_id_claimed, desired_id, backup_id, {})
    local hash_id, scale = utils.get_order_info("technology/" .. name)
    add_icon(hash_id, id, scale or 0.25, "technology/" .. name, icons)
    local icon_id = id

    table.insert(by_group["research"], {
      cluster = "[technology=" .. name .. "]",
      name = technology_names[name],
      symbol = {
        spriteMap = sprite_map_name,
        sprite = icon_id,
      },
    })
  end

  -- Process categories
  local boards = {}
  local recipes_boards = {}
  for name, _ in pairs(by_group) do
    local icon_id
    if name == "research" then
      icon_id = "research"
      local sprite = "space-science-pack"
      if game.active_mods["space-exploration"] then
        sprite = "se-rocket-science-pack"
      end
    
      if not game.technology_prototypes[sprite] then
        player.print({"emoji-keyboard-export.error-no-research-sprite", sprite}, color_error)
      else
        sprite = "technology/" .. sprite
        local hash_id, scale = utils.get_order_info(sprite)
        add_icon(hash_id, icon_id, scale or 0.25, sprite, icons)
      end
    else
      local hash_id, scale = utils.get_order_info("item-group/" .. name)
      icon_id = check_icon_name(name, name .. "|category", icons)
      add_icon(hash_id, icon_id, scale or 0.25, "item-group/" .. name, icons)
    end

    if #by_group[name] > 0 then
      table.insert(boards, {
        name = group_names[name],
        symbol = {
          spriteMap = sprite_map_name,
          sprite = icon_id,
        },
        content = by_group[name],
      })
    end
    if #by_group_recipes[name] > 0 then
      table.insert(recipes_boards, {
        name = group_names[name] .. "\n" .. gui_names["crafting"],
        symbol = {
          spriteMap = sprite_map_name,
          sprite = icon_id,
        },
        content = by_group_recipes[name],
      })
    end
  end

  game.remove_path(folder)
  local pretty_json = true --player_settings["emoji-keyboard-export-pretty-json"].value

  -- Process and generate sprite for scaled icons
  local sprite_surface = game.create_surface("lab-sprite")

  -- Calculate sprite sheet width (height determined by # of loop iterations)
  local width = math.ceil((#icons) ^ 0.5)
  if width < 8 then
    width = 8
  end

  local tile_size = 32
  local sprite_size = 64 -- each sprite takes 2×2 tiles once scaled
  local sprite_pad = 8
  local stride = (sprite_size + sprite_pad) / tile_size
  local x_position = stride / 2 * (width - 1)
  local x_resolution = width * (sprite_size + sprite_pad)

  local x = 0
  local y = 0
  for _, icon in pairs(icons) do
    rendering.draw_sprite(
      {
        sprite = icon.sprite,
        x_scale = icon.scale,
        y_scale = icon.scale,
        target = {x = x * stride, y = y * stride},
        surface = sprite_surface
      }
    )
    local position = {
      row = y,
      col = x
    }
    sprite_map_index[icon.name] = position
    for _, copy in pairs(icon.copies) do
      sprite_map_index[copy] = position
    end

    x = x + 1
    if x == width then
      y = y + 1
      x = 0
    end
  end

  if x == 0 then
    y = y - 1
  end

  local rows = y + 1
  local y_resolution = rows * (sprite_size + sprite_pad)
  local y_position = stride / 2 * (rows - 1)

  game.take_screenshot(
    {
      player = player,
      by_player = player,
      surface = sprite_surface,
      position = {x_position, y_position},
      resolution = {x_resolution, y_resolution},
      zoom = 1,
      quality = 100,
      daytime = 1,
      path = folder .. sprite_map_path,
      show_gui = false,
      show_entity_info = false,
      anti_alias = false
    }
  )

  local sprite_maps = {}
  sprite_maps[sprite_map_name] = {
    path = sprite_map_path,
    width = sprite_size,
    height = sprite_size,
    padding = sprite_pad / 2,
    cols = width,
    rows = rows,
    index = sprite_map_index,
  }

  local lab_data = {
    name = board_name,
    symbol = {
      spriteMap = sprite_map_name,
      sprite = board_sprite,
    },
    boards = {{
      name = board_name,
      symbol = {
        spriteMap = sprite_map_name,
        sprite = board_sprite,
      },
      byRow = {
        {},
        boards,
        recipes_boards,
      }
    }},
    spriteMaps = sprite_maps,
    __version = version,
    __language = language,
  }

  game.write_file(folder .. plugin_file_path, json.stringify(lab_data, pretty_json))
  player.print({"emoji-keyboard-export.complete-data"}, color_good)
end
