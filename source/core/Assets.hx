package core;

import haxe.io.Bytes;

import sys.io.File;

import lime.media.AudioBuffer;

import lime.media.vorbis.VorbisFile;

import openfl.display.BitmapData;

import openfl.media.Sound;

import flixel.FlxG;

import flixel.graphics.FlxGraphic;

import core.Options;

class Assets
{
    public static var persistentCache:Bool;

    public static var graphics:Map<String, FlxGraphic>;

    public static var sounds:Map<String, Sound>;

    public static var byteSets:Map<String, Bytes>;

    public static function init():Void
    {
        persistentCache = Options.persistentCache;
        
        FlxG.signals.preStateSwitch.add(() -> 
        {
            if (!persistentCache)
                clearCaches();
        });

        graphics = new Map<String, FlxGraphic>();

        sounds = new Map<String, Sound>();

        byteSets = new Map<String, Bytes>();
    }

    /**
     * Caches a `flixel.graphics.FlxGraphic` and returns it.
     * If the requested file path already exists in the cache, it will NOT be renewed.
     * @param path The file path of the graphic you want to cache.
     * @param gpuCaching Specifies whether this graphic should be uploaded to the GPU to reduce RAM usage.
     * @return `flixel.graphics.FlxGraphic`
     */
    public static function getGraphic(path:String, gpuCaching:Bool = true):FlxGraphic
    {
        if (graphics.exists(path))
            return graphics[path];

        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromBytes(getByteSet(path)));

        #if (cpp && windows)
            if (Options.gpuCaching && gpuCaching)
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

        FlxG.bitmap.remove(graphic);

        graphic = null;

        graphics.remove(path);

        removeByteSet(path);
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
     * If the requested file path already exists in the cache, it will NOT be renewed.
     * @param path The file path of the sound you want to cache.
     * @param soundStreaming Specifies whether this sound should be streamed to reduce RAM usage.
     * @return `openfl.media.Sound`
     */
    public static function getSound(path:String, soundStreaming:Bool = true):Sound
    {
        if (sounds.exists(path))
            return sounds[path];

        var output:Sound;

        if (Options.soundStreaming && soundStreaming)
            output = Sound.fromAudioBuffer(AudioBuffer.fromVorbisFile(VorbisFile.fromBytes(getByteSet(path))));
        else
            output = Sound.fromAudioBuffer(AudioBuffer.fromBytes(getByteSet(path)));

        sounds[path] = output;

        return sounds[path];
    }

    /**
     * Removes the specified sound from the cache.
     * @param path The file path of the sound you want to remove.
     */
    public static function removeSound(path:String):Void
    {
        if (!sounds.exists(path))
            return;

        var sound:Sound = sounds[path];
        
        sound.close();

        openfl.utils.Assets.cache.removeSound(path);

        sound = null;

        sounds.remove(path);

        removeByteSet(path);
    }

    /**
     * Clears each item from the sound cache.
     */
    public static function clearSounds():Void
    {
        for (key => value in sounds)
            removeSound(key);
    }

    public static function getByteSet(path:String):Bytes
    {
        if (byteSets.exists(path))
            return byteSets[path];

        byteSets[path] = File.getBytes(path);

        return byteSets[path];
    }

    public static function removeByteSet(path:String):Void
    {
        if (!byteSets.exists(path))
            return;

        var byteSet:Bytes = byteSets[path];

        byteSet = null;

        byteSets.remove(path);
    }

    public static function clearByteSets():Void
    {
        for (key => value in byteSets)
            removeByteSet(key);
    }
    
    public static function clearCaches():Void
    {
        clearGraphics();

        clearSounds();

        clearByteSets();
    }

    /**
     * Gets the content of the specified text file. Then, it is returned
     * @param path The file path of the text you want to recieve content from.
     * @return `String`
     */
    public static function getText(path:String):String
    {
        return getByteSet(path).toString();
    }
}