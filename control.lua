local dictionary = require("__flib__.dictionary")
local event = require("__flib__.event")

local export_data = require("scripts/export-data")

local function create_dictionaries()
  for _, type in pairs({
    "fluid", "item", "item_group", "recipe", "technology", "virtual_signal",
  }) do
    -- If the object's name doesn't have a translation, use its internal name as the translation
    local Names = dictionary.new(type .. "_names", true)
    for name, prototype in pairs(game[type .. "_prototypes"]) do
      Names:add(name, prototype.localised_name)
    end
  end
  local EntityNames = dictionary.new("entity_names", true)
  for name, prototype in pairs(game["entity_prototypes"]) do
    if game.noise_layer_prototypes["emoji-keyboard-export/entity/" .. name] ~= nil then
      EntityNames:add(name, prototype.localised_name)
    end
  end
  local OtherNames = dictionary.new("other_names", true)
  OtherNames:add("research", {"gui-technology-progress.title"})
  OtherNames:add("crafting", {"gui.crafting"})
end

event.on_init(
  function()
    dictionary.init()
    create_dictionaries()
  end
)

event.on_player_created(
  function(e)
    if game.noise_layer_prototypes["emoji-keyboard-export/"] == nil then
      -- Instrument mode is not enabled
      return
    end
    local player = game.players[e.player_index]
    player.print({"emoji-keyboard-export.initialize"})
    dictionary.translate(player)
  end
)

event.on_string_translated(
  function(e)
    local language_data = dictionary.process_translation(e)
    if language_data then
      for _, player_index in pairs(language_data.players) do
        export_data(player_index, language_data)
      end
    end
  end
)
