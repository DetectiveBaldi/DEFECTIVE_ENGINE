package core;

import flixel.FlxG;

class Preferences
{
    public static var gpuCaching:Bool;

    public static var soundStreaming:Bool;

    public static var downScroll:Bool;

    public static var middleScroll:Bool;

    public static var ghostTapping:Bool;

    public static var gameModifiers:Map<String, Any>;

    public static function init():Void
    {
        gpuCaching = true;

        soundStreaming = false;

        downScroll = false;

        middleScroll = false;

        ghostTapping = true;

        gameModifiers = new Map<String, Any>();

        gameModifiers["shuffle"] = false;
        
        if (FlxG.save.data.preferences == null)
        {
            FlxG.save.data.preferences = {gpuCaching: gpuCaching, soundStreaming: soundStreaming, downScroll: downScroll, middleScroll: middleScroll, ghostTapping: ghostTapping, gameModifiers: gameModifiers};

            FlxG.save.flush();
        }
    }

    public static function load():Void
    {
        var fields:Array<String> = Reflect.fields(FlxG.save.data.preferences);

        for (i in 0 ... fields.length)
        {
            var field:String = fields[i];

            if (!Type.getClassFields(Preferences).contains(field))
                continue;

            Reflect.setProperty(Preferences, field, Reflect.field(FlxG.save.data.preferences, field));
        }
    }

    public static function save():Void
    {
        var fields:Array<String> = Type.getClassFields(Preferences);

        for (i in 0 ... fields.length)
        {
            var field:String = fields[i];

            if (!Reflect.fields(FlxG.save.data.preferences).contains(field))
                continue;

            Reflect.setField(FlxG.save.data.preferences, field, Reflect.getProperty(Preferences, field));
        }

        FlxG.save.flush();
    }
}