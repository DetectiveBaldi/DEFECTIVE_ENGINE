## Defective Engine
A small, simple Friday Night Funkin' engine.

### Compiling
To compile, complete the following steps:
- First, install [Haxe](https://haxe.org/).
- Then, install the following libraries:
  - lime (`haxelib install lime`)
  - openfl (`haxelib install openfl`)
  - flixel (`haxelib install flixel`)
  - flixel-addons (`haxelib install flixel-addons`)
  - flixel-ui (`haxelib install flixel-ui`)
- Finally, build the game using `haxelib run lime build :target:`.

Defective Engine currently supports the following targets:
- HashLink
- HTML5
- Neko
- Windows

### Chart Formats
The `tools.formats` package contains some helpful classes for converting charts to the Defective format.