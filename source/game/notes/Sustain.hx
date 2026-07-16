package game.notes;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMath;

import game.notes.Note.NoteStatus;
import music.Conductor;

using tools.AlignTools;

class Sustain extends FlxSprite
{
    public var note:Note;

    public var conductor(get, never):Conductor;

    @:noCompletion
    function get_conductor():Conductor
    {
        return note.conductor;
    }

    public var downscroll(get, never):Bool;

    @:noCompletion
    function get_downscroll():Bool
    {
        return note.downscroll;
    }

    public function new():Void
    {
        super();

        antialiasing = true;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var animToPlay:String = '${note.animation.name}HoldPiece';

        if (animation.name != animToPlay)
            animation.play(animToPlay);

        var length:Float = note.renderLength;

        if (note.status == HIT)
            length -= conductor.time - note.renderTime;

        var newHeight:Float = Math.max(0.0, length * 0.45 * note.strumline.scrollSpeed);

        setGraphicSize(frameWidth * note.scale.x, newHeight);

        updateHitbox();

        setPosition(this.getCenterX(note), note.y + note.height * 0.5);

        if (downscroll)
            y -= newHeight;

        alpha = 1.0;
        
        if (!note.skipHit)
        {
            var status:NoteStatus = note.status;

            switch (status:NoteStatus)
            {
                case IDLE:
                    alpha = (conductor.time > note.time) ? FlxMath.remapToRange(conductor.time - note.time, 0.0, Rating.latestTiming, 1.0, 0.5) : 1.0;

                case HIT:
                    alpha = 1.0;

                case MISS:
                    alpha = 0.5;

                case FAILING:
                    alpha = FlxMath.remapToRange(note.unholdTime, 0.0, Rating.latestTiming, 1.0, 0.5);

                default:
            }
        }
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
            
            animation.addByPrefix('${direction}HoldPiece', shortPrefix ? "holdPiece0" : '${direction}HoldPiece0', 24.0);
        }
    }
}