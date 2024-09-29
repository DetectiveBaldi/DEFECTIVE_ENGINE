package core;

import flixel.FlxG;

class Settings
{
    public static var audioStreaming:Bool;

    public static var downScroll:Bool;

    public static var middleScroll:Bool;

    public static function init():Void
    {
        audioStreaming = false;

        downScroll = false;

        middleScroll = false;

        if (FlxG.save.data.settings == null)
        {
            FlxG.save.data.settings = {audioStreaming: audioStreaming, downScroll: downScroll, middleScroll: middleScroll};

            FlxG.save.flush();
        }
    }

    public static function load():Void
    {
        var fields:Array<String> = Reflect.fields(FlxG.save.data.settings);

        for (i in 0 ... fields.length)
            Reflect.setProperty(Settings, fields[i], Reflect.field(FlxG.save.data.settings, fields[i]));
    }

    public static function save():Void
    {
        var fields:Array<String> = Type.getClassFields(Settings);

        for (i in 0 ... fields.length)
        {
            if (Reflect.isFunction(Reflect.getProperty(Settings, fields[i])))
                continue;

            Reflect.setField(FlxG.save.data.settings, fields[i], Reflect.getProperty(Settings, fields[i]));
        }

        FlxG.save.flush();
    }
}