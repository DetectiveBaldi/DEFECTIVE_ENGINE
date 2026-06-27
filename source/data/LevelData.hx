package data;

using StringTools;

@:structInit
class LevelData
{
    public static var list:Array<LevelData> = new Array<LevelData>();

    public var week:WeekData;

    public var name:String;

    var _difficulty:String;

    public var difficulty(get, set):String;

    @:noCompletion
    function get_difficulty():String
    {
        return week?.difficulty ?? _difficulty ?? "Normal";
    }

    @:noCompletion
    function set_difficulty(difficulty:String):String
    {
        _difficulty = difficulty;

        return difficulty;
    }

    public function new(week:WeekData, name:String):Void
    {
        this.week = week;

        this.name = name;
    }

    /**
     * Returns a translated level path that links to a real class. For example, the name
     * "The Level with Multiple Words" would translate to "game.levels.TheLWMWL".
     * @return String
     */
    public function toString():String
    {
        var path:String = "game.levels";

        if (week != null)
            path += '.${week.toString()}';

        var nameSplit:Array<String> = name.split(" ");

        for (i in 1 ... nameSplit.length)
        {
            var word:String = nameSplit[i];

            nameSplit[i] = word.charAt(0).toUpperCase();
        }

        path += '.${nameSplit.join("")}';

        var difficulty:String = difficulty.split(" ").join("");

        if (difficulty != "Normal")
            path += '_${difficulty.toUpperCase()}';

        path += "L";

        return path;
    }
}