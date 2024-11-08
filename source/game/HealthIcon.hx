package game;

import haxe.Json;

import flixel.FlxSprite;

import core.AssetMan;
import core.Paths;

class HealthIcon extends FlxSprite
{
    public static function findConfig(path:String):HealthIconTextureConfig
    {
        return Json.parse(AssetMan.text(Paths.json(path)));
    }

    public var textureConfig(default, set):HealthIconTextureConfig;

    @:noCompletion
    function set_textureConfig(textureConfig:HealthIconTextureConfig):HealthIconTextureConfig
    {
        loadGraphic(AssetMan.graphic(Paths.png(textureConfig.png)));

        antialiasing = textureConfig.antialiasing ?? true;

        scale.set(textureConfig.scale?.x ?? 1.0, textureConfig.scale?.y ?? 1.0);

        updateHitbox();

        return this.textureConfig = textureConfig;
    }

    public function new(x:Float = 0.0, y:Float = 0.0, textureConfig:HealthIconTextureConfig):Void
    {
        super(x, y);

        active = false;

        this.textureConfig = textureConfig;
    }
}

typedef HealthIconTextureConfig =
{
    var png:String;

    var ?antialiasing:Bool;

    var ?scale:{?x:Float, ?y:Float};
};