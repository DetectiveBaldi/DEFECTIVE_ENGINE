package data;

using util.ArrayUtil;

class Playlist
{
    public static function init():Void
    {
        var level:LevelData = {week: null, name: "Unbeatable"}

        LevelData.list.push(level);
    }
}