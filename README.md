## Defective Engine
A Friday Night Funkin' engine.

### Building
To build the game, follow these steps:
- First, install [Haxe](https://haxe.org/).
- Next, to install the required libraries, run the following commands in a command prompt:
  - lime: `haxelib install lime`
  - openfl: `haxelib install openfl`
  - flixel: `haxelib git flixel https://github.com/HaxeFlixel/flixel`
  - flixel-addons: `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons`
  - haxeui-core: `haxelib git haxeui-core https://github.com/haxeui/haxeui-core`
  - haxeui-flixel: `haxelib git haxeui-flixel https://github.com/haxeui/haxeui-flixel`
- Then, run `haxelib run lime build :target:` in a command prompt to build the game.