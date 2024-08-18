package core;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxSoundAsset;

class AssetManager
{
    public static var graphics(default, null):Map<String, FlxGraphicAsset> = new Map<String, FlxGraphicAsset>();

    public static var sounds(default, null):Map<String, FlxSoundAsset> = new Map<String, FlxSoundAsset>();

    public static function exists(key:String):Bool
    {
        return #if html5 openfl.utils.Assets.exists #else sys.FileSystem.exists #end (key);
    }

    public static function graphic(key:String):FlxGraphicAsset
    {
        if (graphics.exists(key))
        {
            return graphics[key];
        }

        graphics[key] = #if html5 key #else openfl.display.BitmapData.fromFile(key) #end ;

        return graphics[key];
    }

    public static function sound(key:String):FlxSoundAsset
    {
        if (sounds.exists(key))
        {
            return sounds[key];
        }

        sounds[key] = #if html5 key #else openfl.media.Sound.fromFile(key) #end ;

        return sounds[key];
    }

    public static function text(key:String):String
    {
        return #if html5 openfl.utils.Assets.getText #else sys.io.File.getContent #end (key);
    }
}