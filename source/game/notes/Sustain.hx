package game.notes;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.util.FlxColor;

import core.Assets;
import core.Paths;

class Sustain extends FlxSprite
{
    public var note:Note;

    public var trail:SustainTrail;

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

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var length:Float = note.length;

        if (note.status == HIT)
            length -= note.strumline.conductor.time - note.time;

        var expectedHeight:Float = (length * 0.45 * note.strumline.scrollSpeed);

        setGraphicSize(frameWidth * 0.7, expectedHeight);

        updateHitbox();

        x = note.getMidpoint().x - width * 0.5;

        y = note.y + note.height * 0.5;

        if (note.strumline.downscroll)
            y -= expectedHeight;

        trail.x = getMidpoint().x - trail.width * 0.5;

        trail.y = y + expectedHeight;

        if (note.strumline.downscroll)
            trail.y -= expectedHeight + trail.height;

        trail.y -= 2.0 * (note.strumline.downscroll ? -1.0 : 1.0);

        if (note.status == MISSED)
        {
            color = 0xFFD3D3D3;

            alpha = 0.5;
        }
        else
        {
            color = FlxColor.WHITE;

            alpha = 1.0;
        }

        trail.color = color;

        trail.alpha = alpha;
    }
}