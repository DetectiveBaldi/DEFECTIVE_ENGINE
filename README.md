## Defective Engine
A Friday Night Funkin' engine.

### Compiling
To compile, follow these steps:
- First, install [Haxe](https://haxe.org/).
- Then, install the following libraries:
  - lime: Refer to the [Development Builds](https://github.com/openfl/lime?tab=readme-ov-file#development-builds).
  - openfl: Refer to the [Development Builds](https://github.com/openfl/openfl?tab=readme-ov-file#development-builds).
  - flixel: Run `haxelib git flixel https://github.com/HaxeFlixel/flixel` in a command prompt.
- Finally, run `haxelib run lime build :target:` in a command prompt to compile the game.

Defective Engine currently supports the following targets:
- HashLink
- HTML5
- Windows

### Chart Formats
The `game.ChartConverters` module contains some useful classes for converting charts to the Defective Engine format.
