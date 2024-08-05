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
        return (60.0 / tempo) * 1000.0;
    }

    public var time:Float;

    public var timeChange:SimpleTimeChange;

    public var timeChanges:Array<SimpleTimeChange>;

    public static function load():Void
    {
        Conductor.current = new Conductor();
    }

    public function new():Void
    {
        decimalStep = -1.0;

        decimalBeat = -1.0;

        decimalSection = -1.0;

        stepHit = new FlxSignal();

        beatHit = new FlxSignal();

        sectionHit = new FlxSignal();

        tempo = 150.0;

        time = 0.0;

        timeChange = {time: 0.0, tempo: 150.0, step: 0.0, beat: 0.0, section: 0.0};

        timeChanges = new Array<SimpleTimeChange>();
    }

    public function calculate():Void
    {
        var lastStep:Int = step;

        var lastBeat:Int = beat;

        var lastSection:Int = section;

        if (timeChanges.length != 0)
        {
            var timeChange:SimpleTimeChange = timeChanges[0];

            if (time >= timeChange.time)
            {
                this.timeChange.step += (timeChange.time - this.timeChange.time) / (crotchet * 0.25);

                this.timeChange.beat = this.timeChange.step * 0.25;

                this.timeChange.section = this.timeChange.section * 0.25;

                this.timeChange.tempo = timeChange.tempo;

                this.timeChange.time = timeChange.time;

                tempo = timeChange.tempo;
                
                timeChanges.shift();
            }
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

        tempo = 150.0;

        time = 0.0;

        timeChange = {time: 0.0, tempo: 150.0, step: 0.0, beat: 0.0, section: 0.0};

        timeChanges = new Array<SimpleTimeChange>();
    }
}