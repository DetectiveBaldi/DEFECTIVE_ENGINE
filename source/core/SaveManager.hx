package core;

import haxe.ds.StringMap;

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

    /**
     * Called in `InitState`. This function can be used to migrate outdated options and high score data.
     */
    public static function mergeData():Void
    {
        saveOptions();

        saveHighScores();
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