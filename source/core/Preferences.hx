package core;

import flixel.FlxG;

class Preferences
{
    #if (!hl && !html5)
        public static var gpuCaching:Bool;

        public static var audioStreaming:Bool;
    #end

    public static var downScroll:Bool;

    public static var middleScroll:Bool;

    public static function init():Void
    {
        #if (!hl && !html5)
            gpuCaching = true;

            audioStreaming = false;
        #end

        downScroll = false;

        middleScroll = false;

        if (FlxG.save.data.preferences == null)
        {
            FlxG.save.data.preferences = { #if (!hl && !html5) gpuCaching: gpuCaching, audioStreaming: audioStreaming, #end downScroll: downScroll, middleScroll: middleScroll};

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