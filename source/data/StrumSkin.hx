package data;

import haxe.Json;

import core.Assets;
import core.Paths;

import data.NoteSkin.RawNoteSkin;

class StrumSkin
{
    public static var list:Map<String, RawStrumSkin> = new Map<String, RawStrumSkin>();

    public static function get(path:String):RawStrumSkin
    {
        if (exists(path))
            return list[path];

        list[path] = Json.parse(Assets.getText(Paths.json('assets/data/game/notes/Strum/${path}')));

        return list[path];
    }

    public static function exists(path:String):Bool
    {
        return list.exists(path);
    }
}

typedef RawStrumSkin = RawNoteSkin;