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
    public static var graphics:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

    public static var sounds:Map<String, Sound> = new Map<String, Sound>();

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
     * Removes the specified graphic from the cache. Frees some VRAM.
     * @param path The file path of the graphic you want to remove.
     */
    public static function removeGraphic(path:String):Void
    {
        if (!graphics.exists(path))
            return;

        var graphic:FlxGraphic = graphics[path];

        @:privateAccess
            graphic.bitmap.__texture.dispose();

        FlxG.bitmap.remove(graphic);

        graphics.remove(path);
    }

    /**
     * Caches an `openfl.media.Sound`. Then, it is returned.
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
     * Removes the specified sound from the sound cache. Frees some RAM.
     * @param path The file path of the sound you want to remove.
     */
    public static function removeSound(path:String):Void
    {
        if (!sounds.exists(path))
            return;

        var sound:Sound = sounds[path];

        sound.close();

        Assets.cache.removeSound(path);

        sounds.remove(path);
    }

    /**
     * Gets the content of the specified text file. Then, it is returned
     * @param path The file path of the text you want to recieve content from.
     * @return `String`
     */
    public static function text(path:String):String
    {
        return #if html5 Assets.getText #else sys.io.File.getContent #end (path);
    }

    /**
     * Clears each item from the graphic and sound caches. Frees some RAM and VRAM.
     */
    public static function clearCache():Void
    {
        for (key => value in graphics)
            removeGraphic(key);

        for (key => value in sounds)
            removeSound(key);
    }
}
