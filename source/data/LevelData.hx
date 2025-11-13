package data;

import flixel.util.typeLimit.NextState;

import game.PlayState;

using util.StringUtil;

using StringTools;

@:structInit
class LevelData
{
    public static var list:Array<LevelData> = new Array<LevelData>();

    public var week:WeekData;

    public var name:String;

    public var difficulty:String;

    public function new(week:WeekData, name:String, difficulty:String = "Normal"):Void
    {
        this.week = week;

        this.name = name;

        this.difficulty = difficulty;
    }

    public function encodeName():String
    {
        var split:Array<String> = name.split(" ");

        for (i in 1 ... split.length)
        {
            var s:String = split[i];

            split[i] = s.charAt(0).toUpperCase();
        }

        return '${split.join("")}L';
    }

    public function copy():LevelData
    {
        var level:LevelData = {week: week, name: name, difficulty: difficulty}

        return level;
    }

    public function getClassPath(sep:String = "/"):String
    {
        var path:String = "game/levels";

        if (week != null)
            path += '/${week.encodeName()}';

        if (difficulty != "Normal")
            path += '/diff_${difficulty.toLowerCase()}';

        path += '/${encodeName()}';

        return path.replace("/", sep);
    }
}