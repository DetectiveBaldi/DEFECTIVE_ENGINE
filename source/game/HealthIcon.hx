package game;

import flixel.FlxSprite;

import core.AssetCache;

using StringTools;

class HealthIcon extends FlxSprite
{
    public var isPixel:Bool;

    public function new(name:String):Void
    {
        super(0.0, 0.0);

        setIcon(name);
    }

    public function setIcon(name:String):Void
    {
        isPixel = name.contains("-pixel");

        loadGraphic(AssetCache.getGraphic('game/HealthIcon/${name}'), true, isPixel ? 32 : 150, isPixel ? 32 : 150);

        animation.add("idle", [0, 1], 0.0, false);

        animation.play("idle");

        antialiasing = !isPixel;

        setGraphicSize(150.0, 150.0);

        updateHitbox();
    }
}