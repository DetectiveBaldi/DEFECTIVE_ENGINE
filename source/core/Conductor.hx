package core;

import flixel.util.FlxSignal.FlxTypedSignal;

import core.Chart.ParsedTimeChange;

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

    public var stepHit:FlxTypedSignal<(step:Int)->Void>;

    public var beatHit:FlxTypedSignal<(beat:Int)->Void>;

    public var sectionHit:FlxTypedSignal<(section:Int)->Void>;

    public var tempo:Float;

    public var crotchet(get, never):Float;

    @:noCompletion
    function get_crotchet():Float
    {
        return (60.0 / tempo) * 1000.0;
    }

    public var timeChange:ParsedTimeChange;

    public var timeChanges:Array<ParsedTimeChange>;

    public var time:Float;

    public static function load():Void
    {
        Conductor.current = new Conductor();
    }

    public function new():Void
    {
        decimalStep = -1.0;

        decimalBeat = -1.0;

        decimalSection = -1.0;

        stepHit = new FlxTypedSignal<(step:Int)->Void>();

        beatHit = new FlxTypedSignal<(beat:Int)->Void>();

        sectionHit = new FlxTypedSignal<(section:Int)->Void>();

        tempo = 150.0;

        timeChange = {tempo: tempo, time: 0.0, step: 0.0, beat: 0.0, section: 0.0};

        timeChanges = [{tempo: tempo, time: 0.0, step: 0.0, beat: 0.0, section: 0.0}];

        time = 0.0;
    }

    public function guage():Void
    {
        var lastStep:Int = step;

        var lastBeat:Int = beat;

        var lastSection:Int = section;

        var i:Int = timeChanges.length - 1;

        while (i >= 0.0)
        {
            if (time >= timeChanges[i].time)
            {
                timeChange.step += (timeChanges[i].time - timeChange.time) / (crotchet * 0.25);

                timeChange.beat = timeChange.step * 0.25;

                timeChange.section = timeChange.section * 0.25;

                timeChange.tempo = timeChanges[i].tempo;
                
                timeChange.time = timeChanges[i].time;

                tempo = timeChange.tempo;

                break;
            }

            i--;
        }

        decimalStep = ((time - timeChange.time) / (crotchet * 0.25)) + timeChange.step;

        decimalBeat = decimalStep * 0.25;

        decimalSection = decimalBeat * 0.25;

        if (step != lastStep)
            stepHit.dispatch(step);

        if (beat != lastBeat)
            beatHit.dispatch(beat);

        if (section != lastSection)
            sectionHit.dispatch(section);
    }

    public function reset():Void
    {
        decimalStep = -1.0;

        decimalBeat = -1.0;

        decimalSection = -1.0;

        stepHit = new FlxTypedSignal<(step:Int)->Void>();

        beatHit = new FlxTypedSignal<(beat:Int)->Void>();

        sectionHit = new FlxTypedSignal<(section:Int)->Void>();

        tempo = 150.0;

        timeChange = {tempo: tempo, time: 0.0, step: 0.0, beat: 0.0, section: 0.0};

        timeChanges = [{tempo: tempo, time: 0.0, step: 0.0, beat: 0.0, section: 0.0}];

        time = 0.0;
    }
}