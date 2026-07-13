package data;

import game.HighScore;

@:structInit
class WeekData
{
    public static var list:Array<WeekData> = new Array<WeekData>();

    public var name:String;

    public var difficulty:String;

    public var levels:Array<LevelData>;

    public function new(name:String):Void
    {
        this.name = name;

        this.difficulty = "Normal";

        levels = new Array<LevelData>();
    }

    /**
     * Returns a translated week name that we can use when evaluating class paths. For example, the name
     * "The Week with Multiple Words" would translate to "theweekwithmultiplewordsw".
     * @return String
     */
    public function toString():String
    {
        return '${name.split(" ").join("").toLowerCase()}w';
    }
}