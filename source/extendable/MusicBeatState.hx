package extendable;

import flixel.FlxState;

import core.Conductor;

/**
 * A `flixel.FlxState` with implemented support for a `core.Conductor`.
 */
class MusicBeatState extends FlxState
{
    public var conductor:Conductor;

    override function create():Void
    {
        super.create();

        conductor = new Conductor();

        conductor.stepHit.add(stepHit);

        conductor.beatHit.add(beatHit);
        
        conductor.sectionHit.add(sectionHit);
    }

    override function destroy():Void
    {
        super.destroy();

        conductor.reset();
    }

    public function stepHit(step:Int):Void
    {

    }

    public function beatHit(beat:Int):Void
    {

    }

    public function sectionHit(section:Int):Void
    {

    }
}