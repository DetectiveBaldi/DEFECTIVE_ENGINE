package game;

import flixel.FlxSprite;

import core.AssetCache;

using StringTools;

class HealthIcon extends FlxSprite
{
    public var character:String;

    /**
     * Returns true if an `game.HealthIcon.character` ends in "-pixel". In that case, `game.HealthIcon.width`/`height` return `32`/`32` instead of `150`/`150` and
     * `game.HealthIcon.antialiasing` is set to `false`.
     */
    public var isPixel(default, null):Bool;

    public function new(character:String):Void
    {
        super(0.0, 0.0);

        setCharacter(character);
    }

    public function setCharacter(char:String):Void
    {
        character = char;

        isPixel = char.contains("-pixel");

        loadGraphic(AssetCache.getGraphic('game/HealthIcon/${char}'), true, isPixel ? 32 : 150, isPixel ? 32 : 150);

        animation.add("idle", [0, 1], 0.0, false);

        animation.play("idle");

        antialiasing = !isPixel;

        setGraphicSize(150.0, 150.0);

        updateHitbox();
    }
}