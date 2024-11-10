package game;

import haxe.Json;

import flixel.FlxSprite;

import flixel.util.FlxColor;

import core.AssetMan;
import core.Paths;

class HealthIcon extends FlxSprite
{
    public static function findConfig(path:String):HealthIconConfig
    {
        return Json.parse(AssetMan.text(Paths.json(path)));
    }

    public var config(default, set):HealthIconConfig;

    @:noCompletion
    function set_config(config:HealthIconConfig):HealthIconConfig
    {
        loadGraphic(AssetMan.graphic(Paths.png(config.png)));

        antialiasing = config.antialiasing ?? true;

        scale.set(config.scale?.x ?? 1.0, config.scale?.y ?? 1.0);

        updateHitbox();

        return this.config = config;
    }

    public function new(x:Float = 0.0, y:Float = 0.0, config:HealthIconConfig):Void
    {
        super(x, y);

        active = false;

        this.config = config;
    }
}

typedef HealthIconConfig =
{
    var png:String;

    var ?antialiasing:Bool;

    var ?scale:{?x:Float, ?y:Float};
};