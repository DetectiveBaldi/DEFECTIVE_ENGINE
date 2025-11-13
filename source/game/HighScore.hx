package game;

import flixel.FlxG;

import core.SaveManager;

import data.PlayStats;

class HighScore
{
    public static var weeks(get, never):Map<String, Map<String, WeekScore>>;

    @:noCompletion
    static function get_weeks():Map<String, Map<String, WeekScore>>
    {
        return SaveManager.highScores.data.weeks ??= new Map<String, Map<String, WeekScore>>();
    }
    
    public static var levels(get, never):Map<String, Map<String, LevelScore>>;

    @:noCompletion
    static function get_levels():Map<String, Map<String, LevelScore>>
    {
        return SaveManager.highScores.data.levels ??= new Map<String, Map<String, LevelScore>>();
    }

    public static function getBlankWeek():WeekScore
    {
        return {score: 0, misses: 0, accuracy: 0.0}
    }

    public static function isWeekHighScore(name:String, diff:String, score:Int):Bool
    {
        return score > getWeekScore(name, diff).score;
    }

    public static function getWeekScore(name:String, diff:String):WeekScore
    {
        return (weeks[name] ??= new Map<String, WeekScore>())[diff] ?? getBlankWeek();
    }

    public static function setWeekScore(name:String, diff:String, score:WeekScore):Void
    {
        (weeks[name] ??= new Map<String, WeekScore>())[diff] = score;
    }

    public static function resetWeekScore(name:String, diff:String):Void
    {
        setWeekScore(name, diff, getBlankWeek());
    }

    public static function getBlankLevel():LevelScore
    {
        return getBlankWeek();
    }

    public static function isLevelHighScore(name:String, diff:String, score:Int):Bool
    {
        return score > getLevelScore(name, diff).score;
    }

    public static function getLevelScore(name:String, diff:String):LevelScore
    {
        return (levels[name] ??= new Map<String, LevelScore>())[diff] ?? getBlankLevel();
    }

    public static function setLevelScore(name:String, diff:String, score:LevelScore):Void
    {
        (levels[name] ??= new Map<String, LevelScore>())[diff] = score;
    }

    public static function resetLevelScore(name:String, diff:String):Void
    {
        setLevelScore(name, diff, getBlankLevel());
    }
}

typedef WeekScore =
{
    public var score:Int;

    public var misses:Int;

    public var accuracy:Float;
}

typedef LevelScore = WeekScore