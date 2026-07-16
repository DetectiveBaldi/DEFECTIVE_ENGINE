package core;

import data.AxisData;

import flixel.FlxG;

class Options
{
    static var _defaultKeybinds:Map<String, Array<Int>>;

    public static var defaultKeybinds(get, never):Map<String, Array<Int>>;

    @:noCompletion
    static function get_defaultKeybinds():Map<String, Array<Int>>
    {
        if (_defaultKeybinds == null)
        {
            _defaultKeybinds =
            [
                "ui left" => [65, 37],

                "ui right" => [68, 39],

                "ui up" => [87, 38],

                "ui down" => [83, 40],

                "ui back" => [27, -1],

                "ui accept" => [13, 32],

                "volume up" => [187, 107],

                "volume down" => [189, 109],

                "volume mute" => [48, 96],

                "editors character" => [56, -1]
            ];
        }

        return _defaultKeybinds;
    }

    public static var keybinds(get, set):Map<String, Array<Int>>;

    @:noCompletion
    static function get_keybinds():Map<String, Array<Int>>
    {
        var copy:Map<String, Array<Int>> = SaveManager.options.data.keybinds;

        if (copy == null)
        {
            copy = new Map<String, Array<Int>>();

            for (k => v in defaultKeybinds)
                copy[k] = v.copy();

            SaveManager.options.data.keybinds = copy;
        }

        return copy;
    }

    @:noCompletion
    static function set_keybinds(v:Map<String, Array<Int>>):Map<String, Array<Int>>
    {
        SaveManager.options.data.keybinds = v;

        return keybinds;
    }

    public static var noteKeybinds(get, set):Map<Int, Array<Array<Int>>>;

    @:noCompletion
    static function get_noteKeybinds():Map<Int, Array<Array<Int>>>
    {
        return SaveManager.options.data.noteKeybinds ??= new Map<Int, Array<Array<Int>>>();
    }

    @:noCompletion
    static function set_noteKeybinds(v:Map<Int, Array<Array<Int>>>):Map<Int, Array<Array<Int>>>
    {
        SaveManager.options.data.noteKeybinds = v;

        return noteKeybinds;
    }

    public static var autoPause(get, set):Bool;

    @:noCompletion
    static function get_autoPause():Bool
    {
        return SaveManager.options.data.autoPause ??= true;
    }

    @:noCompletion
    static function set_autoPause(v:Bool):Bool
    {
        SaveManager.options.data.autoPause = v;

        return autoPause;
    }

    public static var frameRate(get, set):Int;

    @:noCompletion
    static function get_frameRate():Int
    {
        return SaveManager.options.data.frameRate ??= 60;
    }

    static function set_frameRate(v:Int):Int
    {
        SaveManager.options.data.frameRate = v;

        return frameRate;
    }

    public static var flashingLights(get, set):Bool;

    @:noCompletion
    static function get_flashingLights():Bool
    {
        return SaveManager.options.data.flashingLights ??= true;
    }

    @:noCompletion
    static function set_flashingLights(v:Bool):Bool
    {
        SaveManager.options.data.flashingLights = v;

        return flashingLights;
    }

    public static var shaders(get, set):Bool;

    @:noCompletion
    static function get_shaders():Bool
    {
        return SaveManager.options.data.shaders ??= true;
    }

    @:noCompletion
    static function set_shaders(v:Bool):Bool
    {
        SaveManager.options.data.shaders = v;

        return shaders;
    }

    public static var gpuCaching(get, set):Bool;

    @:noCompletion
    static function get_gpuCaching():Bool
    {
        return #if FEATURE_GPU_CACHING SaveManager.options.data.gpuCaching ??= true #else false #end ;
    }

    @:noCompletion
    static function set_gpuCaching(v:Bool):Bool
    {
        SaveManager.options.data.gpuCaching = v;

        return gpuCaching;
    }

    public static var soundStreaming(get, set):Bool;

    @:noCompletion
    static function get_soundStreaming():Bool
    {
        return #if FEATURE_SOUND_STREAMING SaveManager.options.data.soundStreaming ??= true #else false #end ;
    }

    @:noCompletion
    static function set_soundStreaming(v:Bool):Bool
    {
        SaveManager.options.data.soundStreaming = v;

        return soundStreaming;
    }

    public static var ratingPopupOffset(get, set):AxisData;

    @:noCompletion
    static function get_ratingPopupOffset():AxisData
    {
        return SaveManager.options.data.ratingPopupOffset ?? {x: 0.0, y: 0.0}
    }

    static function set_ratingPopupOffset(v:AxisData):AxisData
    {
        SaveManager.options.data.ratingPopupOffset = v;

        return ratingPopupOffset;
    }

    public static var comboPopupOffset(get, set):AxisData;

    @:noCompletion
    static function get_comboPopupOffset():AxisData
    {
        return SaveManager.options.data.comboPopupOffset ?? {x: 0.0, y: 0.0}
    }

    static function set_comboPopupOffset(v:AxisData):AxisData
    {
        SaveManager.options.data.comboPopupOffset = v;

        return comboPopupOffset;
    }

    public static var stackScorePopups(get, set):Bool;

    @:noCompletion
    static function get_stackScorePopups():Bool
    {
        return SaveManager.options.data.stackScorePopups ??= true;
    }

    @:noCompletion
    static function set_stackScorePopups(v:Bool):Bool
    {
        SaveManager.options.data.stackScorePopups = v;

        return stackScorePopups;
    }

    public static var downscroll(get, set):Bool;

    @:noCompletion
    static function get_downscroll():Bool
    {
        return SaveManager.options.data.downscroll ??= false;
    }

    @:noCompletion
    static function set_downscroll(v:Bool):Bool
    {
        SaveManager.options.data.downscroll = v;

        return downscroll;
    }

    public static var middlescroll(get, set):Bool;

    @:noCompletion
    static function get_middlescroll():Bool
    {
        return SaveManager.options.data.middlescroll ??= false;
    }

    @:noCompletion
    static function set_middlescroll(v:Bool):Bool
    {
        SaveManager.options.data.middlescroll = v;

        return middlescroll;
    }

    public static var noteSplashOpacity(get, set):Float;

    @:noCompletion
    static function get_noteSplashOpacity():Float
    {
        return SaveManager.options.data.noteSplashOpacity ??= 0.7;
    }

    @:noCompletion
    static function set_noteSplashOpacity(v:Float):Float
    {
        SaveManager.options.data.noteSplashOpacity = v;

        return noteSplashOpacity;
    }

    public static var ghostTapping(get, set):Bool;

    @:noCompletion
    static function get_ghostTapping():Bool
    {
        return SaveManager.options.data.ghostTapping ??= true;
    }

    @:noCompletion
    static function set_ghostTapping(v:Bool):Bool
    {
        SaveManager.options.data.ghostTapping = v;

        return ghostTapping;
    }

    public static var botplay(get, set):Bool;

    @:noCompletion
    static function get_botplay():Bool
    {
        return SaveManager.options.data.botplay ??= false;
    }

    @:noCompletion
    static function set_botplay(v:Bool):Bool
    {
        SaveManager.options.data.botplay = v;

        return botplay;
    }

    public static function keysJustPressed(name:String):Bool
    {
        var keys:Array<Int> = keybinds[name];

        for (i in 0 ... keys.length)
        {
            var key:Int = keys[i];

            if (key == -1.0)
                continue;

            if (FlxG.keys.checkStatus(key, JUST_PRESSED))
                return true;
        }

        return false;
    }

    public static function keysPressed(name:String):Bool
    {
        var keys:Array<Int> = keybinds[name];

        for (i in 0 ... keys.length)
        {
            var key:Int = keys[i];

            if (key == -1.0)
                continue;

            if (FlxG.keys.checkStatus(key, PRESSED))
                return true;
        }

        return false;
    }

    public static function keysJustReleased(name:String):Bool
    {
        var keys:Array<Int> = keybinds[name];

        for (i in 0 ... keys.length)
        {
            var key:Int = keys[i];

            if (key == -1.0)
                continue;

            if (FlxG.keys.checkStatus(key, JUST_RELEASED))
                return true;
        }

        return false;
    }

    public static function keysIndexJustPressed(name:String, index:Int = 0):Bool
    {
        var keys:Array<Int> = keybinds[name];

        var key:Int = keys[index];

        if (key == -1.0)
            return false;

        return FlxG.keys.checkStatus(key, JUST_PRESSED);
    }

    public static function keysIndexPressed(name:String, index:Int = 0):Bool
    {
        var keys:Array<Int> = keybinds[name];

        var key:Int = keys[index];

        if (key == -1.0)
            return false;

        return FlxG.keys.checkStatus(key, PRESSED);
    }
}