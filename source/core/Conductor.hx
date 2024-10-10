package core;

import flixel.FlxBasic;

import flixel.util.FlxSignal.FlxTypedSignal;

import game.Chart.ParsedTimeChange;

/**
 * A class which handles musical timing events throughout the game. It is the heart of `game.GameState`.
 */
class Conductor extends FlxBasic
{
    public var decimalStep:Float;

    public var decimalBeat:Float;

    public var decimalSection:Float;
    
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

    public function new():Void
    {
        super();

        visible = false;

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

    override function update(elapsed:Float):Void
    {
        time += elapsed * 1000.0;

        if (time < 0.0)
            return;
        
        var lastStep:Int = step;

        var lastBeat:Int = beat;

        var lastSection:Int = section;

        var i:Int = timeChanges.length - 1;

        while (i >= 0.0)
        {
            var _timeChange:ParsedTimeChange = timeChanges[i];

            if (time >= _timeChange.time)
            {
                timeChange.step += (_timeChange.time - timeChange.time) / (crotchet * 0.25);

                timeChange.beat = timeChange.step * 0.25;

                timeChange.section = timeChange.section * 0.25;

                timeChange.tempo = _timeChange.tempo;
                
                timeChange.time = _timeChange.time;

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

    override function destroy():Void
    {
        super.destroy();
        
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

    public function findTimeChangeAt(_time:Float):ParsedTimeChange
    {
        var _timeChange:ParsedTimeChange = timeChanges[0];

        var i:Int = 1;

        while (i < timeChanges.length - 1.0)
        {
            var __timeChange:ParsedTimeChange = timeChanges[i];

            if (__timeChange.time < _time)
                break;

            _timeChange = __timeChange;

            i++;
        }

        return _timeChange;
    }
}