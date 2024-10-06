package extendable;

import haxe.ui.backend.flixel.UISubState;

import core.Conductor;

/**
 * An extended `haxe.ui.backend.flixel.UISubState` which, when created, initializes a single `core.Conductor` instance.
 */
class MusicBeatSubState extends UISubState
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