package game.notes;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;

using tools.ObjectHelpers;

class Sustain extends FlxSprite
{
    public var note:Note;

    public var trail:SustainTrail;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var length:Float = note.length;

        if (note.status == HIT)
            length -= note.strumline.conductor.time - note.time;

        var sustainHeight:Float = Math.max(0.0, length * 0.45 * note.strumline.scrollSpeed);

        setGraphicSize(frameWidth * note.scale.x, sustainHeight);

        updateHitbox();

        setPosition(this.getCenterX(note), note.y + note.height * 0.5);

        if (note.strum.downscroll)
            y -= sustainHeight;

        trail.setPosition(trail.getCenterX(this), y + sustainHeight);

        if (note.strum.downscroll)
            trail.y -= sustainHeight + trail.height;

        trail.y -= 2.0 * (note.strum.downscroll ? -1.0 : 1.0);

        alpha = note.alpha;

        trail.alpha = alpha;
    }

    public function addAnimations():Void
    {
        var frames:Array<FlxFrame> = new Array<FlxFrame>();

        @:privateAccess
        animation.findByPrefix(frames, "leftHoldPiece");

        var shortPrefix:Bool = frames.length == 0.0;

        for (i in 0 ... Note.DIRECTIONS.length)
        {
            var direction:String = Note.DIRECTIONS[i].toLowerCase();
            
            animation.addByPrefix('${direction}HoldPiece', shortPrefix ? "defaultHoldPiece0" : '${direction}HoldPiece0', 24.0, false);
        }
    }
}