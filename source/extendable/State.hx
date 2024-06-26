package extendable;

import flixel.FlxState;

import core.Conductor;

class State extends FlxState
{
    public function new():Void
    {
        super();
    }

    override function create():Void
    {
        super.create();

        Conductor.current.stepHit.add(stepHit);

        Conductor.current.beatHit.add(beatHit);

        Conductor.current.sectionHit.add(sectionHit);
    }

    override function destroy():Void
    {
        super.destroy();

        Conductor.current.reset();
    }

    public function stepHit():Void
    {

    }

    public function beatHit():Void
    {

    }

    public function sectionHit():Void
    {

    }
}