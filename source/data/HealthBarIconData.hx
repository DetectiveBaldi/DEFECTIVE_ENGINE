package data;

import haxe.Json;

import core.Assets;
import core.Paths;

class HealthBarIconData
{
    public static var list:Map<String, RawHealthBarIconData> = new Map<String, RawHealthBarIconData>();

    public static function get(path:String):RawHealthBarIconData
    {
        if (exists(path))
            return list[path];

        list[path] = Json.parse(Assets.getText(Paths.json(path)));

        return list[path];
    }

    public static function exists(path:String):Bool
    {
        return list.exists(path);
    }
}

typedef RawHealthBarIconData =
{
    var png:String;

    var ?antialiasing:Bool;

    var ?scale:{?x:Float, ?y:Float};

    var ?healthBarColor:String;
}