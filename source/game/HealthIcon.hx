package game;

import flixel.FlxSprite;

import flixel.graphics.FlxGraphic;

import flixel.system.FlxAssets.FlxGraphicAsset;

import core.AssetCache;

using StringTools;

class HealthIcon extends FlxSprite
{
    public var isPixel:Bool;

    public function new(path:String):Void
    {
        super(0.0, 0.0);

        updateGraphic(path);
    }

    public function updateGraphic(path:String):Void
    {
        isPixel = path.contains("-pixel");

        loadGraphic(AssetCache.getGraphic('game/HealthIcon/${path}'), true, isPixel ? 32 : 150, isPixel ? 32 : 150);

        animation.add("frames", [0, 1], 0.0, false);

        animation.play("frames");

        antialiasing = !isPixel;

        setGraphicSize(150.0, 150.0);

        updateHitbox();
    }
}