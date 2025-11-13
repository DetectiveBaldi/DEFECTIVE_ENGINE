package data;

import game.HighScore;

using util.ArrayUtil;

@:structInit
class WeekData
{
    public static var list:Array<WeekData> = new Array<WeekData>();

    public var name:String;

    public var nameSuffix:String;

    public var description:String;

    public var levels:Array<LevelData>;

    public var scoreRequirements:Map<String, Array<String>>;

    public function new(name:String, nameSuffix:String, description:String):Void
    {
        this.name = name;

        this.nameSuffix = nameSuffix;

        this.description = description;

        levels = new Array<LevelData>();

        scoreRequirements = new Map<String, Array<String>>();
    }

    public function encodeName():String
    {
        return '${name.split(" ").join("").toLowerCase()}w';
    }

    /**
     * Returns a surface-level copy of this `WeekData`. Level data is not recreated!
     * @return `WeekData`
     */
    public function copy():WeekData
    {
        var data:WeekData = {name: name, nameSuffix: nameSuffix, description: description}
        
        data.levels = levels.copy();

        data.scoreRequirements = scoreRequirements.copy();

        return data;
    }

    public function hasDifficulty(difficulty:String):Bool
    {
        return levels.first((lv:LevelData) -> lv.difficulty == difficulty) != null;
    }

    public function filterByDifficulty(difficulty:String):Array<LevelData>
    {
        return levels.filter((lv:LevelData) -> lv.difficulty == difficulty);
    }

    public function addScoreRequirement(name:String, difficulty:String):Void
    {
        var requirement:Array<String> = scoreRequirements[name] ??= new Array<String>();

        requirement.push(difficulty);
    }

    public function scoresValidated():Bool
    {
        for (key => val in scoreRequirements)
        {
            var name:String = key;

            for (i in 0 ... val.length)
            {
                var difficulty:String = val[i];

                if (HighScore.getWeekScore(name, difficulty).score == 0.0)
                    return false;
            }
        }

        return true;
    }
}