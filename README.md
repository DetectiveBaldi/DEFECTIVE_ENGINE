## Defective Engine
A small, simple Friday Night Funkin' engine.

### Compiling
To compile, complete the following steps:
- First, install [Haxe](https://haxe.org/).
- Then, install the following libraries:
  - lime (`haxelib install lime`)
  - openfl (`haxelib install openfl`)
  - flixel (`haxelib git flixel https://github.com/HaxeFlixel/flixel`)
- Finally, build the game using `haxelib run lime build :target:`.

Defective Engine currently supports the following targets:
- HashLink
- HTML5
- Neko
- Windows

### Chart Formats
The `tools.formats.charts` package contains some helpful classes for converting charts to the Defective Engine format.