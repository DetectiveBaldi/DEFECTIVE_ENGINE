package core;

import openfl.media.Sound;

import openfl.utils.Assets;

import flixel.FlxG;

import flixel.graphics.FlxGraphic;

import core.Preferences;

/**
 * A class which handles the caching and storing of graphics and sounds.
 */
class AssetMan
{
    public static var graphics:Map<String, FlxGraphic>;

    public static var sounds:Map<String, Sound>;

    public static function init():Void
    {
        graphics = new Map<String, FlxGraphic>();

        sounds = new Map<String, Sound>();  
    }

    /**
     * Caches a `flixel.graphics.FlxGraphic` and returns it.
     * If possible, the graphic will be uploaded to the GPU to reduce RAM usage.
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
            if (Preferences.gpuCaching)
                graphic.bitmap.disposeImage();
        #end

        graphic.persist = true;

        graphics[path] = graphic;

        return graphics[path];
    }

    /**
     * Removes the specified graphic from the cache.
     * @param path The file path of the graphic you want to remove.
     */
    public static function removeGraphic(path:String):Void
    {
        if (!graphics.exists(path))
            return;

        var graphic:FlxGraphic = graphics[path];

        if (graphic.useCount > 0.0)
            return;

        #if (!hl && !html5)
            if (Preferences.gpuCaching)
            {
                @:privateAccess
                    graphic.bitmap.__texture.dispose();
            }
        #end

        FlxG.bitmap.remove(graphic);

        graphics.remove(path);
    }

    /**
     * Clears each item from the graphic cache.
     */
    public static function clearGraphics():Void
    {
        for (key => value in graphics)
            removeGraphic(key);
    }

    /**
     * Caches an `openfl.media.Sound` and returns it.
     * If possible, the sound will be streamed to reduce RAM usage.
     * If the requested file path already exists in the cache, it will NOT be renewed.
     * @param path The file path of the sound you want to cache.
     * @return `openfl.media.Sound`
     */
    public static function sound(path:String):Sound
    {
        if (sounds.exists(path))
            return sounds[path];

        var output:Sound;

        #if hl
            output = Sound.fromFile(path);
        #else
            #if html5
                output = Assets.getSound(path);
            #else
                output = lime.media.vorbis.VorbisFile.fromFile(path) == null ? Sound.fromFile(path) : Sound.fromAudioBuffer(lime.media.AudioBuffer.fromVorbisFile(lime.media.vorbis.VorbisFile.fromFile(path)));
            #end
        #end

        sounds[path] = output;

        return sounds[path];
    }

    /**
     * Removes the specified sound from the sound cache.
     * @param path The file path of the sound you want to remove.
     */
    public static function removeSound(path:String):Void
    {
        if (!sounds.exists(path))
            return;

        var sound:Sound = sounds[path];

        for (i in 0 ... FlxG.sound.list.length)
        {
            @:privateAccess
            {
                if (FlxG.sound.list.members[i]._sound == sound)
                    return;
            }
        }

        sound.close();

        Assets.cache.removeSound(path);

        sounds.remove(path);
    }

    /**
     * Clears each item from the sound cache.
     */
    public static function clearSounds():Void
    {
        for (key => value in graphics)
            removeGraphic(key);
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
     * Clears each item from the graphic and sound caches.
     */
    public static function clearCache():Void
    {
        clearGraphics();

        clearSounds();
    }
}