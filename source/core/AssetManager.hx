package core;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxSoundAsset;

#if html5
    import openfl.utils.Assets;
#else
    import sys.io.File;

    import openfl.display.BitmapData;

    import openfl.media.Sound;
#end

class AssetManager
{
    public static var graphics(default, null):Map<String, FlxGraphicAsset> = new Map<String, FlxGraphicAsset>();

    public static var sounds(default, null):Map<String, FlxSoundAsset> = new Map<String, FlxSoundAsset>();

    public static function graphic(path:String):FlxGraphicAsset
    {
        graphics[path] = #if html5 path #else BitmapData.fromFile(path) #end ;

        return graphics[path];
    }

    public static function sound(path:String):FlxSoundAsset
    {
        sounds[path] = #if html5 path #else Sound.fromFile(path) #end ;

        return sounds[path];
    }

    public static function text(path:String):String
    {
        return #if html5 Assets.getText #else File.getContent #end (path);
    }
}