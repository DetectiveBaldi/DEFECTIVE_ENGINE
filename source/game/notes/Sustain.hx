package game.notes;

import flixel.FlxCamera;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;

import flixel.util.FlxColor;

import core.AssetCache;
import core.Paths;

class Sustain extends FlxSprite
{
    public var note:Note;

    public var trail:SustainTrail;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        frames = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic("game/notes/Note/default"),
            Paths.image(Paths.xml("game/notes/Note/default")));

        for (i in 0 ... Note.DIRECTIONS.length)
        {
            var direction:String = Note.DIRECTIONS[i].toLowerCase();

            animation.addByPrefix('${direction}HoldPiece', '${direction}HoldPiece0', 24.0, false);
        }
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var length:Float = note.length;

        if (note.status == HIT)
            length -= note.strumline.conductor.time - note.time;

        var sustainHeight:Float = Math.max(length * 0.45 * note.strumline.scrollSpeed, 0.0);

        setGraphicSize(frameWidth * 0.7, sustainHeight);

        updateHitbox();

        setPosition(note.getMidpoint().x - width * 0.5, note.y + note.height * 0.5);

        if (note.strum.downscroll)
            y -= sustainHeight;

        trail.setPosition(getMidpoint().x - trail.width * 0.5, y + sustainHeight);

        if (note.strum.downscroll)
            trail.y -= sustainHeight + trail.height;

        trail.y -= 2.0 * (note.strum.downscroll ? -1.0 : 1.0);

        alpha = note.alpha;

        trail.alpha = alpha;
    }
}