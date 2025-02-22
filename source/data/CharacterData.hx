package data;

import haxe.Json;

import core.Assets;
import core.Paths;

class CharacterData
{
    public static var list:Map<String, RawCharacterData> = new Map<String, RawCharacterData>();

    public static function get(path:String):RawCharacterData
    {
        if (exists(path))
            return list[path];

        list[path] = Json.parse(Assets.getText(Paths.json('assets/data/game/Character/${path}')));

        return list[path];
    }

    public static function exists(path:String):Bool
    {
        return list.exists(path);
    }
}

typedef RawCharacterData =
{
    var name:String;
    
    var format:String;

    var png:String;

    var xml:String;

    var ?antialiasing:Bool;

    var ?scale:{?x:Float, ?y:Float};

    var ?flipX:Bool;

    var ?flipY:Bool;

    var animations:Array<AnimationData>;

    var danceSteps:Array<String>;

    var ?danceInterval:Float;

    var ?singDuration:Float;
}