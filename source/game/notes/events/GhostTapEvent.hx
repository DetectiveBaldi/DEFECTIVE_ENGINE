package game.notes.events;

import core.Options;

class GhostTapEvent
{
    public var direction:Int;

    public var ghostTapping:Bool;

    public function new():Void
    {

    }

    public function reset(_direction:Int):Void
    {
        direction = _direction;
        
        ghostTapping = Options.ghostTapping;
    }
}