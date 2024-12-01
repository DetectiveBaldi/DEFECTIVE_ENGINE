package core;

import flixel.FlxG;

import flixel.input.keyboard.FlxKey;

class Options
{
    public static var autoPause(get, set):Bool;

    @:noCompletion
    static function get_autoPause():Bool
    {
        return FlxG.save.data.options.autoPause ??= false;
    }

    @:noCompletion
    static function set_autoPause(_autoPause:Bool):Bool
    {
        FlxG.save.data.options.autoPause = _autoPause;

        return autoPause;
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

    public static var keybinds(get, set):Map<String, Array<Int>>;

    @:noCompletion
    static function get_keybinds():Map<String, Array<Int>>
    {
        return FlxG.save.data.options.keybinds ??= ["NOTE:LEFT" => [65, 37], "NOTE:DOWN" => [83, 40], "NOTE:UP" => [87, 38], "NOTE:RIGHT" => [68, 39]];
    }

    @:noCompletion
    static function set_keybinds(_keybinds:Map<String, Array<Int>>):Map<String, Array<Int>>
    {
        FlxG.save.data.options.keybinds = _keybinds;

        return keybinds;
    }

    @:noCompletion

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