# FactorioLab Export

This is the repository for [FactorioLab Export](https://mods.factorio.com/mod/factoriolab-export), a [Factorio](https://www.factorio.com/) mod that logs game data to JSON files and an icon sprite sheet that can be used by [FactorioLab](https://factoriolab.github.io).

After following the steps in [getting started](#getting-started), you can use this mod to [create a new data set](#creating-a-new-data-set), [update an existing data set](#updating-an-existing-data-set), or [localize a data set](#localize-a-new-or-existing-data-set).

This mod works best when run in Instrument Mode. [Learn more](#why-instrument-mode)

## Getting started

1. Install this mod alongside any mods that should be included in the data set
1. Set up Steam to run this mod in [Instrument Mode](https://lua-api.factorio.com/latest/Instrument.html)
   - In the library, right click Factorio and in Launch Options enter: `--instrument-mod factoriolab-export`
   - Alternately, run Factorio from the command line with these options
   - [Why instrument mode?](#why-instrument-mode)

## Creating a new data set

1. Ensure the Factorio language is set to Default
1. Start a new game
1. A message should be logged indicating the output has been written to `%APPDATA%\Factorio\script-output\factoriolab-export`
   - A normal export includes `data.json`, `hash.json`, and `icons.png`
1. Create a new folder in the [FactorioLab](https://github.com/factoriolab/factoriolab) repository under `src\data`
   - These folders use a three-letter abbreviation for brevity when used in the URL, or a combination of three-letter abbreviations if multiple mod sets are included (e.g. `bobang` for Bob's and Angel's)
1. Add an entry for this mod set in `factoriolab\src\data\index.ts`
   - This should include the folder name as the `id`, a friendly name as the `name`, and `game: Game.Factorio`
1. Double check the `defaults` object in `data.json` to ensure reasonable defaults are used for this data set
1. In the FactorioLab repository, run the command `npm run process-mod abc` where `abc` is the folder name you chose for the data
   - This command adds the average color to each icon in the data set, which is used in the Flow view
1. Run the application and load the data set, then refresh the page
1. If the calculator fails to find a solution within five seconds, update the `disabledRecipes` in `defaults`
   - A suggested default for this will also be logged to the browser console

## Updating an existing data set

1. Ensure the Factorio language is set to Default
1. Start a new game
1. A message should be logged indicating the output has been written to `%APPDATA%\Factorio\script-output\factoriolab-export`
   - A normal export includes `data.json`, `hash.json`, and `icons.png`
1. Copy **only** `data.json` and `icons.png` to the appropriate folder in the [FactorioLab](https://github.com/factoriolab/factoriolab) repository under `src\data`
   - **Do not** copy `hash.json`, overwriting the old file would break existing saved links
1. Double check the `defaults` object in `data.json`, or copy the `defaults` from the original data set if it is still valid
1. In the FactorioLab repository, run the command `npm run process-mod abc` where `abc` is the folder name for the data
   - This command adds the average color to each icon in the data set, which is used in the Flow view
1. Run the application and load the data set, then refresh the page
   - An object will be logged to the browser console indicating the new `hash` for this data set
   - Copy that object and overwrite the existing `hash.json` for this data set, this should only append ids
1. If the calculator fails to find a solution within five seconds, update the `disabledRecipes`
   - A suggested default for this will also be logged to the browser console

## Localizing a data set

1. Ensure the Factorio language is set to the language you want to use for localization
1. Start a new game
1. A message should be logged indicating the output has been written to `%APPDATA%\Factorio\script-output\factoriolab-export`
   - A locale export includes `i18n\lang.json`, where `lang` is the language code
1. Copy this folder and its contents to the appropriate folder in the [FactorioLab](https://github.com/factoriolab/factoriolab) repository under `src\data`
1. Run the application and load the data set, then choose the language you localized to verify the localized data works as expected

## Why instrument mode?

Running in instrument mode is technically optional but strongly recommended and required if submitting a PR to FactorioLab.

FactorioLab Export uses instrument mode to check icon data for cases where icons will be rendered at unexpected sizes in the game, to ensure that the generated sprite sheet sizes the icons appropriately. In certain cases icons can bleed out of the expected size or can be scaled in unexpected ways that can only be detected in the data stage. FactorioLab Export runs these checks in the `instrument-after-data.lua` file to ensure that it has the most up to date icon information from all loaded mods.

Unfortunately, the Factorio Lua runtime exposes no method to determine what size a sprite will be rendered to when using `LuaRendering.draw_sprite`. By checking the icons in the data stage, FactorioLab Export can predict the size and use the `scale` parameter to ensure all the icons are the desired size.
