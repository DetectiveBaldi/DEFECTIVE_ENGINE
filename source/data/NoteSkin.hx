package data;

import haxe.Json;

import core.Assets;
import core.Paths;

class NoteSkin
{
    public static var list:Map<String, RawNoteSkin> = new Map<String, RawNoteSkin>();

    public static function get(path:String):RawNoteSkin
    {
        if (exists(path))
            return list[path];

        list[path] = Json.parse(Assets.getText(Paths.json('assets/data/game/notes/Note/${path}')));

        return list[path];
    }

    public static function exists(path:String):Bool
    {
        return list.exists(path);
    }
}

typedef RawNoteSkin =
{
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;
}