package core;

import openfl.display.BitmapData;

import openfl.media.Sound;

import openfl.utils.Assets;

import flixel.FlxG;
import flixel.FlxState;

import flixel.graphics.FlxGraphic;

import flixel.sound.FlxSound;

import core.Options;

using StringTools;

using util.ArrayUtil;

class AssetCache
{
    public static var lastState:Class<FlxState>;

    public static var graphics:Map<String, FlxGraphic>;

    public static var sounds:Map<String, Sound>;

    public static var music:Map<String, Sound>;

    public static function init():Void
    {
        graphics = new Map<String, FlxGraphic>();

        sounds = new Map<String, Sound>();

        music = new Map<String, Sound>();

        FlxG.signals.preStateSwitch.add(() -> lastState = Type.getClass(FlxG.state));

        FlxG.signals.preStateCreate.add((nextState:FlxState) -> {if (lastState != Type.getClass(nextState)) clearCaches();});
    }

    public static overload inline extern function getGraphic(path:String, gpuCaching:Bool = true):FlxGraphic
    {
        path = Paths.image(Paths.png(path));

        if (graphics.exists(path))
            return graphics[path];

        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(path, false));

        if (Options.gpuCaching && gpuCaching)
            graphic.bitmap.disposeImage();

        graphic.persist = true;

        graphics[path] = graphic;
        
        return graphic;
    }

    public static function removeGraphic(path:String):Void
    {
        if (!graphics.exists(path))
            return;

        var graphic:FlxGraphic = graphics[path];

        if (graphic.useCount > 0.0)
            return;

        FlxG.bitmap.remove(graphic);

        graphics.remove(path);
    }

    public static function getSound(path:String):Sound
    {
        path = Paths.sound(Paths.ogg(path));

        if (sounds.exists(path))
            return sounds[path];

        sounds[path] = Assets.getSound(path, false);

        return sounds[path];
    }

    public static function getMusic(path:String):Sound
    {
        path = Paths.music(Paths.ogg(path));

        if (music.exists(path))
            return music[path];

        if (Options.soundStreaming)
            music[path] = Assets.getMusic(path, false);
        else
            music[path] = Assets.getSound(path, false);

        return music[path];
    }

    public static function getSoundPath(sound:Sound):String
    {
        for (k => v in sounds)
            if (sound == v)
                return k;

        return null;
    }

    public static function getMusicPath(sound:Sound):String
    {
        for (k => v in music)
            if (sound == v)
                return k;

        return null;
    }

    public static function removeSound(path:String):Void
    {
        if (!sounds.exists(path))
            return;

        var sound:Sound = sounds[path];

        @:privateAccess
        if (FlxG.sound.defaultSoundGroup.sounds.first((usedSound:FlxSound) -> usedSound._sound == sound
            && usedSound.persist) != null)
                return;

        sound.close();

        sounds.remove(path);
    }

    public static function removeMusic(path:String):Void
    {
        if (!music.exists(path))
            return;

        var sound:Sound = music[path];

        @:privateAccess
        if (FlxG.sound.defaultSoundGroup.sounds.first((usedSound:FlxSound) -> usedSound._sound == sound
            && usedSound.persist) != null)
                return;

        sound.close();

        music.remove(path);
    }

    public static function clearCaches():Void
    {
        for (k => v in graphics)
            removeGraphic(k);

        for (k => v in sounds)
            removeSound(k);

        for (k => v in music)
            removeMusic(k);
    }
}