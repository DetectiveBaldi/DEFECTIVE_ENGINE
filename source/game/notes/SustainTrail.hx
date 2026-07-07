package game.notes;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;

using tools.ObjectHelpers;

class SustainTrail extends FlxSprite
{
    public var note:Note;

    public var sustain(get, never):Sustain;

    @:noCompletion
    function get_sustain():Sustain
    {
        return note.sustain;
    }

    public var downscroll(get, never):Bool;

    @:noCompletion
    function get_downscroll():Bool
    {
        return note.downscroll;
    }

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);

        antialiasing = true;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        scale.x = note.scale.x;

        scale.y = note.scale.y;

        updateHitbox();

        setPosition(this.getCenterX(sustain),  sustain.y + sustain.height);

        if (downscroll)
            y = sustain.y - height;

        alpha = sustain.alpha;
    }

    public function addAnimations():Void
    {
        var frames:Array<FlxFrame> = new Array<FlxFrame>();

        @:privateAccess
        animation.findByPrefix(frames, "leftHoldTail");

        var shortPrefix:Bool = frames.length == 0.0;

        for (i in 0 ... Note.DIRECTIONS.length)
        {
            var direction:String = Note.DIRECTIONS[i].toLowerCase();
            
            animation.addByPrefix('${direction}HoldTail', shortPrefix ? "holdTail0" : '${direction}HoldTail0', 24.0, false);
        }
    }
}