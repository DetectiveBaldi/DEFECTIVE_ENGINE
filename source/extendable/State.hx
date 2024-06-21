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

        Conductor.current.sectionHit.add(sectionHit);

        Conductor.current.beatHit.add(beatHit);

        Conductor.current.stepHit.add(stepHit);
    }

    override function destroy():Void
    {
        super.destroy();

        Conductor.current.reset();
    }

    public function sectionHit():Void
    {

    }

    public function beatHit():Void
    {

    }

    public function stepHit():Void
    {

    }
}