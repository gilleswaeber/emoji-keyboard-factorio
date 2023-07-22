This mod will export a plugin for the [Emoji Keyboard](https://github.com/gilleswaeber/emoji-keyboard) app for the active Factorio game, including mods, using the active locale.

The plugin consists of a JSON file describing all items, fluids, recipes, technologies, and virtual signals that can be typed using [Rich Text](https://wiki.factorio.com/Rich_text), categorized and with their tag, and a sprite map.

This mod won't do anything when not run in Instrument Mode.

The code based on [FactorioLab Export](https://mods.factorio.com/mod/factoriolab-export).

## Usage instructions

1. Install this mod alongside any mods that should be included in the data set
2. Set up Steam to run this mod in [Instrument Mode](https://lua-api.factorio.com/latest/Instrument.html)
   - In the library, right click Factorio and in Launch Options enter: `--instrument-mod emoji-keyboard-export`
   - Alternately, run Factorio from the command line with these options
   - [Why instrument mode?](#why-instrument-mode)
3. Start Factorio and start a new game, a message will appear indicating the export started (if not, check that this mod and flib mod are enabled, and you used instrument mode)
4. Wait for the export to complete, another message appears in the chat, you can now exit Factorio
5. Copy the contents of `%APPDATA%\Factorio\script-output\emoji-keyboard-export` into the plugin directory of Emoji Keyboard and restart it.
