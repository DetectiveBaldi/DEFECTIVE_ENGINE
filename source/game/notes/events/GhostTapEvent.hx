package game.notes.events;

import core.Options;

class GhostTapEvent
{
    public var ghostTapping(get, never):Bool;

    @:noCompletion
    function get_ghostTapping():Bool
    {
        return Options.ghostTapping;
    }

    public var direction:Int;

    public function new():Void
    {
        direction = 0;
    }

    public function reset(direction:Int):Void
    {
        this.direction = direction;
    }
}