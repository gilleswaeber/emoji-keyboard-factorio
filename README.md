# Emoji Keyboard Export

This is the reposition for the Emoji Keyboard Export mod for Factorio.
This mod will export a plugin for the [Emoji Keyboard](https://github.com/gilleswaeber/emoji-keyboard) app for the active Factorio game, including mods, using the active locale.

The plugin consists of a JSON file describing all items, fluids, recipes, technologies, and virtual signals that can be typed using [Rich Text](https://wiki.factorio.com/Rich_text), categorized and with their tag, and a sprite map.

This mod won't do anything when not run in Instrument Mode. [Learn more](#why-instrument-mode).

This is based on [FactorioLab Export](https://github.com/factoriolab/factoriolab-export) by ilbJanissary, available under MIT License. Thank you!

## Getting started

1. Install this mod alongside any mods that should be included in the data set
2. Set up Steam to run this mod in [Instrument Mode](https://lua-api.factorio.com/latest/Instrument.html)
   - In the library, right click Factorio and in Launch Options enter: `--instrument-mod emoji-keyboard-export`
   - Alternately, run Factorio from the command line with these options
   - [Why instrument mode?](#why-instrument-mode)
3. Start Factorio and start a new game, a message will appear indicating the export started (if not, check that this mod and flib mod are enabled, and you used instrument mode)
4. Wait for the export to complete, another message appears in the chat, you can now exit Factorio
5. Copy the contents of `%APPDATA%\Factorio\script-output\emoji-keyboard-export` into the plugin directory of Emoji Keyboard and restart it.

## Why instrument mode?

Running in instrument mode is technically optional but the mod disables itself when it's not used. The source mode, FactorioLab Export can run without it.

The FactorioLab Export code uses instrument mode to check icon data for cases where icons will be rendered at unexpected sizes in the game, to ensure that the generated sprite sheet sizes the icons appropriately. In certain cases icons can bleed out of the expected size or can be scaled in unexpected ways that can only be detected in the data stage. The mod runs these checks in the `instrument-after-data.lua` file to ensure that it has the most up to date icon information from all loaded mods.

Unfortunately, the Factorio Lua runtime exposes no method to determine what size a sprite will be rendered to when using `LuaRendering.draw_sprite`. By checking the icons in the data stage, the mod can predict the size and use the `scale` parameter to ensure all the icons are the desired size.

## Warnings and errors

The code that FactorioLab Export uses to compute recipes has been stripped out, so no known source of error remains.
Please file an issue if anything weird happens.
