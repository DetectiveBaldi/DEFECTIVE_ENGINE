package game;

import flixel.FlxSprite;

import core.Assets;
import core.Paths;

import data.HealthBarIconData.RawHealthBarIconData;

class HealthBarIcon extends FlxSprite
{
    public var config(default, set):RawHealthBarIconData;

    @:noCompletion
    function set_config(_config:RawHealthBarIconData):RawHealthBarIconData
    {
        config = _config;

        loadGraphic(Assets.getGraphic(Paths.png(config.png)));

        antialiasing = config.antialiasing ?? true;

        scale.set(config.scale?.x ?? 1.0, config.scale?.y ?? 1.0);

        updateHitbox();

        return config;
    }

    public function new(x:Float = 0.0, y:Float = 0.0, _config:RawHealthBarIconData):Void
    {
        super(x, y);

        active = false;

        config = _config;
    }
}