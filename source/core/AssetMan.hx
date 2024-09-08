package core;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxSoundAsset;

#if html5
    import openfl.utils.Assets;
#else
    import sys.io.File;

    import openfl.display.BitmapData;

    import openfl.media.Sound;

    import flixel.graphics.FlxGraphic;
#end

class AssetMan
{
    public static var graphics(default, null):Map<String, FlxGraphicAsset> = new Map<String, FlxGraphicAsset>();

    public static var sounds(default, null):Map<String, FlxSoundAsset> = new Map<String, FlxSoundAsset>();

    public static function graphic(path:String):FlxGraphicAsset
    {
        if (graphics.exists(path))
            return graphics[path];

        #if !html5
            var graphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path));

            graphic.persist = true;

            graphic.destroyOnNoUse = false;
        #end

        graphics[path] = #if html5 path #else graphic #end ;

        return graphics[path];
    }

    public static function sound(path:String):FlxSoundAsset
    {
        if (sounds.exists(path))
            return sounds[path];

        sounds[path] = #if html5 path #else Sound.fromFile(path) #end ;

        return sounds[path];
    }

    public static function text(path:String):String
    {
        return #if html5 Assets.getText #else File.getContent #end (path);
    }
}