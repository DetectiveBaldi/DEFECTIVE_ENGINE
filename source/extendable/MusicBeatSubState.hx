package extendable;

import flixel.FlxSubState;

import core.Conductor;

/**
 * An extended `flixel.FlxSubState` which, when created, initializes a single `core.Conductor` instance.
 */
class MusicBeatSubState extends FlxSubState
{
    public var conductor:Conductor;

    override function create():Void
    {
        super.create();

        conductor = new Conductor();

        conductor.stepHit.add(stepHit);

        conductor.beatHit.add(beatHit);
        
        conductor.sectionHit.add(sectionHit);

        add(conductor);
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