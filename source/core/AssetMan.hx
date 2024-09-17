package core;

import openfl.media.Sound;

import flixel.graphics.FlxGraphic;

class AssetMan
{
    public static var graphics(default, null):Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

    public static var sounds(default, null):Map<String, Sound> = new Map<String, Sound>();

    public static function graphic(path:String):FlxGraphic
    {
        if (graphics.exists(path))
            return graphics[path];

        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(#if html5 openfl.utils.Assets.getBitmapData(path) #else openfl.display.BitmapData.fromFile(path) #end );

        #if (!hl && !html5)
            graphic.bitmap.disposeImage();
        #end

        graphic.persist = true;

        graphic.destroyOnNoUse = false;

        graphics[path] = graphic;

        return graphics[path];
    }

    public static function sound(path:String):Sound
    {
        if (sounds.exists(path))
            return sounds[path];

        sounds[path] = #if html5 openfl.utils.Assets.getSound(path) #else openfl.media.Sound.fromFile(path) #end ;

        return sounds[path];
    }

    public static function text(path:String):String
    {
        return #if html5 openfl.utils.Assets.getText #else sys.io.File.getContent #end (path);
    }
}