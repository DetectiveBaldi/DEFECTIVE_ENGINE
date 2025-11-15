package data;

using util.ArrayUtil;

class Playlist
{
    public static function init():Void
    {
        var level:LevelData = {week: null, name: "High"}

        LevelData.list.push(level);

        level = {week: null, name: "Thorns"}

        LevelData.list.push(level);

        level = {week: null, name: "Senpai"}

        LevelData.list.push(level);

        level = {week: null, name: "Unbeatable"}

        LevelData.list.push(level);
    }
}