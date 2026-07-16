# Defective Engine
![Defective](resources/icon-512.png)

## What is Defective Engine?
Defective Engine is a custom Friday Night Funkin' engine that offers an efficient source code modding experience.

## Credits
- [Detective Baldi](https://x.com/DetectiveBaldi): Programming
- [KayipKux](https://x.com/KayipKux): Artist and composer
- [BerryBoggle](https://www.youtube.com/@Berry_): Artist and composer
- [Sword352](https://github.com/Sword352): Programming help
- [The Funkin' Crew Inc.](https://github.com/FunkinCrew): Created the original game

## Features
Organized source code with many powerful tools:
- Simple week and level loading
- Individual level classes (Think of Psych or Codename Engine's "song" scripts, but much more powerful!)
- Chart conversion for multiple engines

Several optimizations:
- Notes, sustains, sustain tails, and note splashes are all recycled, which avoids creating tons of new instances.
- Sustains are now rendered as 2 sprites (the "piece" and the "tail") instead of dozens of separated ones.

Other:
- Multiple opponents, players, and spectators
- More than 2 strumlines
- More (and less) than 4 keys
- Character editor
- Options menu
- Support for several targets (cpp, hl, html5)

## Building
Follow these steps to build the game:
1. Install [Haxe](https://haxe.org/).
2. Install the required libraries by running the following commands:
   - `hxcpp`: `haxelib git hxcpp https://github.com/HaxeFoundation/hxcpp`
   - `lime`: `haxelib install lime`
   - `openfl`: `haxelib install openfl`
   - `flixel`: `haxelib install flixel`
   - `flixel-addons`: `haxelib install flixel-addons`
   - `haxeui-core`: `haxelib git haxeui-core https://github.com/haxeui/haxeui-core`
   - `haxeui-flixel`: `haxelib git haxeui-flixel https://github.com/haxeui/haxeui-flixel`
3. Build the game by running the following command in a command prompt: `haxelib run lime build target` (replace "target" with your desired target, like cpp, hl, or html5).

## Contributing
Bug reports and feature requests through the issues tab are welcomed! Pull requests are fine too, however preferably they are small in size (bug fixes or quick optimizations). Otherwise, please create your proposal as an issue to gather feedback.

## Notice
Defective Engine is still in early development. The engine is already very capable, although, if you plan to develop a mod, there are a couple of things to take into consideration:
- I use many placeholder levels to test development features, which you would want to remove if you make a mod. All of the current placeholders will be replaced with a coherent modding example once the engine nears a full release.
- The engine is not super beginner friendly! There isn't a ton of documentation right now and you can cause a LOT of confusing crashes if you don't know what you are doing! Error handling and documentation will be significantly improved in the near future.