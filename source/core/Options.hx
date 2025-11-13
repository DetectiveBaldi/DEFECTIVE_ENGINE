package core;

import flixel.FlxG;

import flixel.math.FlxMath;

class Options
{
    public static var autoPause(get, set):Bool;

    @:noCompletion
    static function get_autoPause():Bool
    {
        return SaveManager.options.data.autoPause ??= true;
    }

    @:noCompletion
    static function set_autoPause(_autoPause:Bool):Bool
    {
        SaveManager.options.data.autoPause = _autoPause;

        return autoPause;
    }

    public static var frameRate(get, set):Int;

    @:noCompletion
    static function get_frameRate():Int
    {
        return SaveManager.options.data.frameRate ??= 60;
    }

    static function set_frameRate(_frameRate:Int):Int
    {
        SaveManager.options.data.frameRate = _frameRate;

        return frameRate;
    }

    public static var flashingLights(get, set):Bool;

    @:noCompletion
    static function get_flashingLights():Bool
    {
        return SaveManager.options.data.flashingLights ??= true;
    }

    @:noCompletion
    static function set_flashingLights(_flashingLights:Bool):Bool
    {
        SaveManager.options.data.flashingLights = _flashingLights;

        return flashingLights;
    }

    public static var shaders(get, set):Bool;

    @:noCompletion
    static function get_shaders():Bool
    {
        return SaveManager.options.data.shaders ??= true;
    }

    @:noCompletion
    static function set_shaders(_shaders:Bool):Bool
    {
        SaveManager.options.data.shaders = _shaders;

        return shaders;
    }

    public static var controls(get, set):Map<String, Array<Int>>;

    @:noCompletion
    static function get_controls():Map<String, Array<Int>>
    {
        return SaveManager.options.data.controls ??= 
        [
            "NOTE:LEFT" => [65, 37],

            "NOTE:DOWN" => [83, 40],
            
            "NOTE:UP" => [87, 38],
            
            "NOTE:RIGHT" => [68, 39]
        ];
    }

    @:noCompletion
    static function set_controls(_controls:Map<String, Array<Int>>):Map<String, Array<Int>>
    {
        SaveManager.options.data.controls = _controls;

        return controls;
    }

    public static var downscroll(get, set):Bool;

    @:noCompletion
    static function get_downscroll():Bool
    {
        return SaveManager.options.data.downscroll ??= false;
    }

    @:noCompletion
    static function set_downscroll(_downscroll:Bool):Bool
    {
        SaveManager.options.data.downscroll = _downscroll;

        return downscroll;
    }

    public static var ghostTapping(get, set):Bool;

    @:noCompletion
    static function get_ghostTapping():Bool
    {
        return SaveManager.options.data.ghostTapping ??= true;
    }

    @:noCompletion
    static function set_ghostTapping(_ghostTapping:Bool):Bool
    {
        SaveManager.options.data.ghostTapping = _ghostTapping;

        return ghostTapping;
    }

    public static var botplay(get, set):Bool;

    @:noCompletion
    static function get_botplay():Bool
    {
        return SaveManager.options.data.botplay ??= false;
    }

    @:noCompletion
    static function set_botplay(_botplay:Bool):Bool
    {
        SaveManager.options.data.botplay = _botplay;

        return botplay;
    }

    public static var discordRPC(get, set):Bool;

    @:noCompletion
    static function get_discordRPC():Bool
    {
        return #if (FEATURE_DISCORD_HANDLER) SaveManager.options.data.discordRPC ??= true #else false #end;
    }

    @:noCompletion
    static function set_discordRPC(_discordRPC:Bool):Bool
    {
        SaveManager.options.data.discordRPC = _discordRPC;

        return discordRPC;
    }

    public static var gpuCaching(get, set):Bool;

    @:noCompletion
    static function get_gpuCaching():Bool
    {
        return #if FEATURE_GPU_CACHING SaveManager.options.data.gpuCaching ??= false #else false #end ;
    }

    @:noCompletion
    static function set_gpuCaching(_gpuCaching:Bool):Bool
    {
        SaveManager.options.data.gpuCaching = _gpuCaching;

        return gpuCaching;
    }

    public static var soundStreaming(get, set):Bool;

    @:noCompletion
    static function get_soundStreaming():Bool
    {
        return #if FEATURE_SOUND_STREAMING SaveManager.options.data.soundStreaming ??= false #else false #end ;
    }

    @:noCompletion
    static function set_soundStreaming(_soundStreaming:Bool):Bool
    {
        SaveManager.options.data.soundStreaming = _soundStreaming;

        return soundStreaming;
    }
}