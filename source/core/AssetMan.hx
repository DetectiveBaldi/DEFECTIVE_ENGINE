package core;

import openfl.media.Sound;

import openfl.utils.Assets;

import flixel.FlxG;

import flixel.graphics.FlxGraphic;

/**
 * A class which handles the caching and storing of graphics and sounds.
 */
class AssetMan
{
    public static var graphics(default, null):Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

    public static var sounds(default, null):Map<String, Sound> = new Map<String, Sound>();

    public static var texts(default, null):Map<String, String> = new Map<String, String>();

    /**
     * Caches a `flixel.graphics.FlxGraphic`, and, if possible, uploads it to the GPU. Then, it is returned.
     * If the requested file path already exists in the cache, it will NOT be renewed.
     * @param path The file path of the graphic you want to cache.
     * @return `flixel.graphics.FlxGraphic`
     */
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

    /**
     * Caches a `openfl.media.Sound`. Then, it is returned.
     * If the requested file path already exists in the cache, it will NOT be renewed.
     * @param path The file path of the sound you want to cache.
     * @return `openfl.media.Sound`
     */
    public static function sound(path:String):Sound
    {
        if (sounds.exists(path))
            return sounds[path];

        sounds[path] = #if html5 Assets.getSound(path) #else openfl.media.Sound.fromFile(path) #end ;

        return sounds[path];
    }

    /**
     * Returns the content of a specified text file.
     * If the requested file path already exists in the cache, it will NOT be renewed.
     * @param path The file path of the text you want to recieve content from.
     * @return `String`
     */
     public static function text(path:String):String
    {
        if (texts.exists(path))
            return texts[path];

        texts[path] = #if html5 Assets.getText #else sys.io.File.getContent #end (path);

        return texts[path];
    }

    /**
     * Clears each item from the graphic, sound, and text caches. Frees some RAM and VRAM.
     */
    public static function clearCache():Void
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

        for (key => value in sounds)
        {
            value.close();

            Assets.cache.removeSound(key);
        }

        sounds.clear();

        texts.clear();
    }
}