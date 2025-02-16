package game.notes;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.Assets;
import core.Paths;

class SustainTrail extends FlxSprite
{
    public var sustain:Sustain;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        frames = FlxAtlasFrames.fromSparrow(Assets.getGraphic(Paths.png("assets/images/game/notes/Note/default")), Paths.xml("assets/images/game/notes/Note/default"));

        for (i in 0 ... Note.DIRECTIONS.length)
        {
            animation.addByPrefix(Note.DIRECTIONS[i].toLowerCase(), Note.DIRECTIONS[i].toLowerCase() + "0", 24.0, false);

            animation.addByPrefix(Note.DIRECTIONS[i].toLowerCase() + "HoldPiece", Note.DIRECTIONS[i].toLowerCase() + "HoldPiece0", 24.0, false);
            
            animation.addByPrefix(Note.DIRECTIONS[i].toLowerCase() + "HoldTail", Note.DIRECTIONS[i].toLowerCase() + "HoldTail0", 24.0, false);
        }

        antialiasing = true;
    }
}