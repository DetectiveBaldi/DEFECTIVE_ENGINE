package game.notes;

import flixel.FlxSprite;

import flixel.graphics.frames.FlxFrame;

class SustainTrail extends FlxSprite
{
    public var sustain:Sustain;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super(x, y);
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
            
            animation.addByPrefix('${direction}HoldTail', shortPrefix ? "defaultHoldTail0" : '${direction}HoldTail0', 24.0, false);
        }
    }
}