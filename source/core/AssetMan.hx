package core;

import openfl.media.Sound;

import openfl.utils.Assets;

import flixel.FlxG;

import flixel.graphics.FlxGraphic;

class AssetMan
{
    public static var graphics(default, null):Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

    public static var sounds(default, null):Map<String, Sound> = new Map<String, Sound>();

    public static function graphic(path:String):FlxGraphic
    {
        if (graphics.exists(path))
            return graphics[path];

        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(#if html5 Assets.getBitmapData(path) #else openfl.display.BitmapData.fromFile(path) #end );

        #if (!hl && !html5)
            graphic.bitmap.disposeImage();

            graphic.bitmap.getTexture(FlxG.stage.context3D);
        #end

        graphic.persist = true;

        graphics[path] = graphic;

        return graphics[path];
    }

    public static function sound(path:String):Sound
    {
        if (sounds.exists(path))
            return sounds[path];

        sounds[path] = #if html5 Assets.getSound(path) #else openfl.media.Sound.fromFile(path) #end ;

        return sounds[path];
    }

    public static function disposeGraphics():Void
    {
        for (key => value in graphics)
        {
            @:privateAccess
                value.bitmap.__texture.dispose();
            
            value.bitmap.dispose();
            
            value.destroy();

            FlxG.bitmap.remove(value);
        }

        graphics.clear();
    }

    public static function disposeSounds():Void
    {
        for (key => value in sounds)
        {
            value.close();

            Assets.cache.removeSound(key);
        }

        sounds.clear();
    }

    public static function text(path:String):String
    {
        return #if html5 Assets.getText #else sys.io.File.getContent #end (path);
    }
}