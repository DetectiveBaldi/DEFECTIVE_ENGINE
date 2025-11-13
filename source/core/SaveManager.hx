package core;

import flixel.FlxG;

import flixel.math.FlxMath;

import flixel.util.FlxSave;

class SaveManager
{
    public static var options:FlxSave;

    public static var highScores:FlxSave;

    public static function init():Void
    {
        options = new FlxSave();

        @:privateAccess
        options.bind(FlxSave.validate("options"));

        highScores = new FlxSave();

        @:privateAccess
        highScores.bind(FlxSave.validate("high-scores"));
    }

    public static function mergeData():Void
    {
        if (Reflect.hasField(FlxG.save.data, "scores"))
            Reflect.deleteField(FlxG.save.data, "scores");
        
        if (Reflect.hasField(FlxG.save.data, "options"))
        {
            options.mergeData(FlxG.save.data.options);

            var data:Dynamic = options.data;

            if (Reflect.hasField(data, "frameRate"))
            {
                var newVal:Int = Reflect.field(data, "frameRate");

                newVal = Math.round(newVal / 30.0) * 30;

                Reflect.setField(data, "frameRate", FlxMath.bound(newVal, 30, 240));
            }

            if (Reflect.hasField(data, "persistentCache"))
                Reflect.deleteField(data, "persistentCache");

            if (Reflect.hasField(data, "flashing"))
            {
                Reflect.setField(data, "flashingLights", Reflect.field(data, "flashing"));

                Reflect.deleteField(data, "flashing");
            }

            if (Reflect.hasField(data, "middlescroll"))
                Reflect.deleteField(data, "middlescroll");

            if (Reflect.hasField(data, "automatedInputs"))
            {
                Reflect.setField(data, "botplay", Reflect.field(data, "automatedInputs"));
                
                Reflect.deleteField(data, "automatedInputs");
            }

            Reflect.deleteField(FlxG.save.data, "options");
        }

        if (Reflect.hasField(FlxG.save.data, "highScores"))
        {
            highScores.mergeData(FlxG.save.data.highScores);

            Reflect.deleteField(FlxG.save.data, "highScores");
        }
    }

    public static function saveOptions():Void
    {
        options.flush();
    }

    public static function saveHighScores():Void
    {
        highScores.flush();
    }

    public static function eraseOptions():Void
    {
        options.erase();

        saveOptions();
    }

    public static function eraseHighScores():Void
    {
        highScores.erase();

        saveHighScores();
    }
}