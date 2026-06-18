package data;

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

    /**
     * Creates a path that links to a properly translated level class.
     * @return String
     */
    public function getClassPath():String
    {
        var path:String = "game.levels";

        if (week != null)
            path += '.${week.toString()}';

        if (difficulty != "Normal")
            path += '.diff_${difficulty.toLowerCase()}';

        path += '.${toString()}';

        return path;
    }

    /**
     * Returns a translated level name we can can use when evaluating class paths. For example, the name
     * "The Level with Multiple Words" would translate to "TheLWMWL".
     * @return String
     */
    public function toString():String
    {
        var s:Array<String> = name.split(" ");

        for (i in 1 ... s.length)
        {
            var ss:String = s[i];

            s[i] = ss.charAt(0).toUpperCase();
        }

        return '${s.join("")}L';
    }
}