package core;

import flixel.FlxG;

class Options
{
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

        return _gpuCaching;
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
        FlxG.save.data.options.soundStreaming = soundStreaming;

        return _soundStreaming;
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

        return _downscroll;
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

        return _middlescroll;
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

        return _ghostTapping;
    }

    public static var gameModifiers(get, set):Map<String, Any>;

    @:noCompletion
    static function get_gameModifiers():Map<String, Any>
    {
        return FlxG.save.data.options.gameModifiers ??= new Map<String, Any>();
    }

    @:noCompletion
    static function set_gameModifiers(_gameModifiers:Map<String, Any>):Map<String, Any>
    {
        FlxG.save.data.options.gameModifiers = _gameModifiers;

        return _gameModifiers;
    }

    public static function init():Void
    {
        FlxG.save.data.options ??= {};
    }
}