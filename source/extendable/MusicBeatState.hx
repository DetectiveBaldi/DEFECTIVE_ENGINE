package extendable;

import flixel.FlxState;

import core.Conductor;

class MusicBeatState extends FlxState
{
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

        Conductor.current.stepHit.remove(stepHit);

        Conductor.current.beatHit.remove(beatHit);
        
        Conductor.current.sectionHit.remove(sectionHit);
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