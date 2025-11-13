package game.notes;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import core.AssetCache;
import core.Paths;

class SustainTrail extends FlxSprite
{
    public var sustain:Sustain;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        frames = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic("game/notes/Note/default"),
            Paths.image(Paths.xml("game/notes/Note/default")));
        
        for (i in 0 ... Note.DIRECTIONS.length)
        {
            var direction:String = Note.DIRECTIONS[i].toLowerCase();

            animation.addByPrefix('${direction}HoldTail', '${direction}HoldTail0', 24.0, false);
        }
    }
}