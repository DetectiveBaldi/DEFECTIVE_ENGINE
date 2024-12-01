## Credits
- [Detective Baldi](https://x.com/DetectiveBaldi): Programming
- [KayipKux](https://x.com/KayipKux): Artist and Composer
- [Berry](https://x.com/berryreal_): Concept Designer

## Building
Follow these steps to build the game:

1. Install [Haxe](https://haxe.org/).
2. Install the required libraries by running the following commands:
   - `lime`: `haxelib install lime`
   - `openfl`: `haxelib install openfl`
   - `flixel`: `haxelib git flixel https://github.com/HaxeFlixel/flixel --skip-dependencies`
   - `flixel-addons`: `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons`
   - `haxeui-core`: `haxelib git haxeui-core https://github.com/haxeui/haxeui-core`
   - `haxeui-flixel`: `haxelib git haxeui-flixel https://github.com/haxeui/haxeui-flixel --skip-dependencies`
3. Build the game by running the following command in a command prompt (replace :target: with a specific target like html5, cpp, etc.):
   `haxelib run lime build :target:`