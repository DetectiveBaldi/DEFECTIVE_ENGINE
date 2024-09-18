package extendable;

import flixel.FlxSubState;

import core.Conductor;

class MusicBeatSubState extends FlxSubState
{
    public var conductor(default, null):Conductor;

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

        conductor.stepHit.remove(stepHit);

        conductor.beatHit.remove(beatHit);
        
        conductor.sectionHit.remove(sectionHit);
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