package core;

import flixel.util.FlxSignal;

import core.Song.SimpleTimeChange;

class Conductor
{
    public static var current(default, null):Conductor;

    public var decimalStep(default, null):Float;

    public var decimalBeat(default, null):Float;

    public var decimalSection(default, null):Float;
    
    public var step(get, never):Int;

    @:noCompletion
    function get_step():Int
    {
        return Math.floor(decimalStep);
    }

    public var beat(get, never):Int;

    @:noCompletion
    function get_beat():Int
    {
        return Math.floor(decimalBeat);
    }

    public var section(get, never):Int;

    @:noCompletion
    function get_section():Int
    {
        return Math.floor(decimalSection);
    }

    public var stepHit:FlxSignal;

    public var beatHit:FlxSignal;

    public var sectionHit:FlxSignal;

    public var tempo:Float;

    public var crotchet(get, never):Float;

    @:noCompletion
    function get_crotchet():Float
    {
        return (60 / tempo) * 1000;
    }

    public var time:Float;

    public var timeChange:SimpleTimeChange;

    public var timeChanges:Array<SimpleTimeChange>;

    public function new():Void
    {
        decimalStep = -1.0;

        decimalBeat = -1.0;

        decimalSection = -1.0;

        stepHit = new FlxSignal();

        beatHit = new FlxSignal();

        sectionHit = new FlxSignal();

        tempo = 100.0;

        time = 0.0;

        timeChanges = [{time: 0.0, tempo: 100.0}];
    }

    public static function load():Void
    {
        Conductor.current = new Conductor();
    }

    public function calculate():Void
    {
        var lastStep:Int = step;

        var lastBeat:Int = beat;

        var lastSection:Int = section;

        while (timeChanges[0] != null && time >= timeChanges[0].time)
        {
            timeChange.step += (timeChanges[0].time - timeChange.time) / (crotchet * 0.25);

            timeChange.beat = timeChange.step * 0.25;

            timeChange.section = timeChange.section * 0.25;

            timeChange.time = timeChanges[0].time;

            tempo = timeChanges[0].tempo;
            
            timeChanges.shift();
        }

        decimalStep = ((time - timeChange.time) / (crotchet * 0.25)) + timeChange.step;

        decimalBeat = decimalStep * 0.25;

        decimalSection = decimalBeat * 0.25;

        if (step != lastStep)
        {
            stepHit.dispatch();
        }

        if (beat != lastBeat)
        {
            beatHit.dispatch();
        }

        if (section != lastSection)
        {
            sectionHit.dispatch();
        }
    }

    public function reset():Void
    {
        decimalStep = -1.0;

        decimalBeat = -1.0;

        decimalSection = -1.0;

        stepHit = new FlxSignal();

        beatHit = new FlxSignal();

        sectionHit = new FlxSignal();

        tempo = 100.0;

        time = 0.0;

        timeChange = null;

        timeChanges = [{time: 0.0, tempo: 100.0}];
    }
}