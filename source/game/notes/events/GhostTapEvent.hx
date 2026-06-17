package game.notes.events;

import core.Options;

class GhostTapEvent
{
    public var ghostTapping:Bool;

    public var direction:Int;

    public function new():Void
    {
        ghostTapping = Options.ghostTapping;
    }

    public function reset(d:Int):Void
    {
        direction = d;
    }
}