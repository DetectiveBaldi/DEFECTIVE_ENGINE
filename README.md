## Credits
- [Detective Baldi](https://x.com/DetectiveBaldi): Programming
- [KayipKux](https://x.com/KayipKux): Artist
- [Berry](https://x.com/berryreal_): Concept Designer

## Building
To build the game, follow these steps:

1. First, install [Haxe](https://haxe.org/).
2. Next, install the required libraries by running the following commands in a command prompt:
   - `lime`: `haxelib install lime`
   - `openfl`: `haxelib install openfl`
   - `flixel`: `haxelib git flixel https://github.com/HaxeFlixel/flixel --skip-dependencies`
   - `flixel-addons`: `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons`
   - `haxeui-core`: `haxelib git haxeui-core https://github.com/haxeui/haxeui-core`
   - `haxeui-flixel`: `haxelib git haxeui-flixel https://github.com/haxeui/haxeui-flixel --skip-dependencies`
3. Then, run `haxelib run lime build :target:` in the command prompt to build the game.