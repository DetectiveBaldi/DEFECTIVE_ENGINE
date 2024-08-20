package core;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxSoundAsset;

class AssetManager
{
    public static var graphics(default, null):Map<String, FlxGraphicAsset> = new Map<String, FlxGraphicAsset>();

    public static var sounds(default, null):Map<String, FlxSoundAsset> = new Map<String, FlxSoundAsset>();

    public static function graphic(path:String):FlxGraphicAsset
    {
        if (graphics.exists(path))
        {
            return graphics[path];
        }

        graphics[path] = #if html5 path #else openfl.display.BitmapData.fromFile(path) #end ;

        return graphics[path];
    }

    public static function sound(path:String):FlxSoundAsset
    {
        if (sounds.exists(path))
        {
            return sounds[path];
        }

        sounds[path] = #if html5 path #else openfl.media.Sound.fromFile(path) #end ;

        return sounds[path];
    }

    public static function text(path:String):String
    {
        return #if html5 openfl.utils.Assets.getText #else sys.io.File.getContent #end (path);
    }
}