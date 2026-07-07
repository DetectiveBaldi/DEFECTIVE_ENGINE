package game;

import flixel.FlxSprite;

import core.AssetCache;

using StringTools;

class HealthIcon extends FlxSprite
{
    public var characterId:String;

    public var isPixel:Bool;

    public function new(char:String):Void
    {
        super(0.0, 0.0);

        setCharacter(char);
    }

    public function setCharacter(char:String):Void
    {
        characterId = char;

        isPixel = char.contains("-pixel");

        loadGraphic(AssetCache.getGraphic('game/HealthIcon/${char}'), true, isPixel ? 32 : 150, isPixel ? 32 : 150);

        animation.add("idle", [0, 1], 0.0, false);

        animation.play("idle");

        antialiasing = !isPixel;

        setGraphicSize(150.0, 150.0);

        updateHitbox();
    }
}