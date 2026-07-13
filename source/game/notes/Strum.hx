package game.notes;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetCache;
import core.Options;
import core.Paths;

using StringTools;

class Strum extends FlxSprite
{
    public var direction:Int;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        antialiasing = true;

        reset(x, y);
    }

    public function getStrumFrames():FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(AssetCache.getGraphic("game/notes/Strum/default", false),
            Paths.image(Paths.xml("game/notes/Strum/default")));
    }

    public function addAnimations():Void
    {
        for (i in 0 ... Note.DIRECTIONS.length)
        {
            var directionString:String = Note.DIRECTIONS[i].toLowerCase();

            animation.addByPrefix('${directionString}Static', '${directionString}Static0', 24.0, false);

            animation.addByPrefix('${directionString}Press', '${directionString}Press0', 24.0, false);
            
            animation.addByPrefix('${directionString}Confirm', '${directionString}Confirm0', 24.0, false);
        }
    }
}