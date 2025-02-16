package data;

import haxe.Json;

import core.Assets;
import core.Paths;

class NotePopSkin
{
    public static var list:Map<String, RawNotePopSkin> = new Map<String, RawNotePopSkin>();

    public static function get(path:String):RawNotePopSkin
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

typedef RawNotePopSkin =
{
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;

    var animations:Array<AnimData>;
}