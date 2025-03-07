package core;

import flixel.FlxG;

class Options
{
    public static var autoPause(get, set):Bool;

    @:noCompletion
    static function get_autoPause():Bool
    {
        return FlxG.save.data.options.autoPause ??= true;
    }

    @:noCompletion
    static function set_autoPause(_autoPause:Bool):Bool
    {
        FlxG.save.data.options.autoPause = _autoPause;

        return autoPause;
    }

    public static var fullscreen(get, set):Bool;

    @:noCompletion
    static function get_fullscreen():Bool
    {
        return FlxG.save.data.options.fullscreen ??= true;
    }

    @:noCompletion
    static function set_fullscreen(_fullscreen:Bool):Bool
    {
        FlxG.save.data.options.fullscreen = _fullscreen;

        return fullscreen;
    }

    public static var gpuCaching(get, set):Bool;

    @:noCompletion
    static function get_gpuCaching():Bool
    {
        return FlxG.save.data.options.gpuCaching ??= true;
    }

    @:noCompletion
    static function set_gpuCaching(_gpuCaching:Bool):Bool
    {
        FlxG.save.data.options.gpuCaching = _gpuCaching;

        return gpuCaching;
    }

    public static var soundStreaming(get, set):Bool;

    @:noCompletion
    static function get_soundStreaming():Bool
    {
        return FlxG.save.data.options.soundStreaming ??= true;
    }

    @:noCompletion
    static function set_soundStreaming(_soundStreaming:Bool):Bool
    {
        FlxG.save.data.options.soundStreaming = _soundStreaming;

        return soundStreaming;
    }
    
    public static var persistentCache(get, set):Bool;

    @:noCompletion
    static function get_persistentCache():Bool
    {
        return FlxG.save.data.options.persistentCache ??= true;
    }
    
    @:noCompletion
    static function set_persistentCache(_persistentCache:Bool):Bool
    {
        FlxG.save.data.options.persistentCache = _persistentCache;

        return _persistentCache;
    }

    public static var controls(get, set):Map<String, Int>;

    @:noCompletion
    static function get_controls():Map<String, Int>
    {
        return FlxG.save.data.options.controls ??= ["NOTE:LEFT" => 65, "NOTE:DOWN" => 83, "NOTE:UP" => 87, "NOTE:RIGHT" => 68];
    }

    @:noCompletion
    static function set_controls(_controls:Map<String, Int>):Map<String, Int>
    {
        FlxG.save.data.options.controls = _controls;

        return controls;
    }

    public static var downscroll(get, set):Bool;

    @:noCompletion
    static function get_downscroll():Bool
    {
        return FlxG.save.data.options.downscroll ??= false;
    }

    @:noCompletion
    static function set_downscroll(_downscroll:Bool):Bool
    {
        FlxG.save.data.options.downscroll = _downscroll;

        return downscroll;
    }

    public static var middlescroll(get, set):Bool;

    @:noCompletion
    static function get_middlescroll():Bool
    {
        return FlxG.save.data.options.middlescroll ??= false;
    }

    @:noCompletion
    static function set_middlescroll(_middlescroll:Bool):Bool
    {
        FlxG.save.data.options.middlescroll = _middlescroll;

        return middlescroll;
    }

    public static var ghostTapping(get, set):Bool;

    @:noCompletion
    static function get_ghostTapping():Bool
    {
        return FlxG.save.data.options.ghostTapping ??= false;
    }

    @:noCompletion
    static function set_ghostTapping(_ghostTapping:Bool):Bool
    {
        FlxG.save.data.options.ghostTapping = _ghostTapping;

        return ghostTapping;
    }

    public static var gameModifiers(get, set):Map<String, Dynamic>;

    @:noCompletion
    static function get_gameModifiers():Map<String, Dynamic>
    {
        return FlxG.save.data.options.gameModifiers ??= new Map<String, Dynamic>();
    }

    @:noCompletion
    static function set_gameModifiers(_gameModifiers:Map<String, Dynamic>):Map<String, Dynamic>
    {
        FlxG.save.data.options.gameModifiers = _gameModifiers;

        return gameModifiers;
    }

    public static function init():Void
    {
        FlxG.save.data.options ??= {};
    }
}