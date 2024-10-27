package core;

import flixel.FlxBasic;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal.FlxTypedSignal;

import game.Chart.ParsedTimeChange;

/**
 * A class which handles musical timing events throughout the game. It is the heart of `game.GameState`.
 */
class Conductor extends FlxBasic
{
    public var decimalStep(get, never):Float;

    @:noCompletion
    function get_decimalStep():Float
    {
        return ((time - timeChange.time) / (crotchet * 0.25)) + timeChange.step;
    }

    public var decimalBeat(get, never):Float;

    @:noCompletion
    function get_decimalBeat():Float
    {
        return decimalStep * 0.25;
    }

    public var decimalSection(get, never):Float;

    @:noCompletion
    function get_decimalSection():Float
    {
        return decimalBeat * 0.25;
    }
    
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

    public var time:Float;

    public var timeChange:ParsedTimeChange;

    public var timeChanges:Array<ParsedTimeChange>;

    public function new():Void
    {
        super();

        visible = false;

        stepHit = new FlxTypedSignal<(step:Int)->Void>();

        beatHit = new FlxTypedSignal<(beat:Int)->Void>();

        sectionHit = new FlxTypedSignal<(section:Int)->Void>();

        tempo = 150.0;

        time = 0.0;

        timeChange = {time: 0.0, tempo: 150.0, step: 0.0};

        timeChanges = new Array<ParsedTimeChange>();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        var lastStep:Int = step;

        var lastBeat:Int = beat;

        var lastSection:Int = section;

        time += elapsed * 1000.0;

        var i:Int = timeChanges.length - 1;

        while (i >= 0.0)
        {
            var _timeChange:ParsedTimeChange = timeChanges[i];

            if (tempo != _timeChange.tempo)
            {
                if (time >= _timeChange.time)
                {
                    timeChange.step += (_timeChange.time - timeChange.time) / (crotchet * 0.25);

                    timeChange.time = _timeChange.time;

                    timeChange.tempo = _timeChange.tempo;

                    tempo = timeChange.tempo;

                    break;
                }
            }

            i--;
        }

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

        stepHit.destroy();

        stepHit = null;

        beatHit.destroy();

        beatHit = null;

        sectionHit.destroy();

        sectionHit = null;
    }

    public function findTimeChangeAt(_tempo:Float, _time:Float):ParsedTimeChange
    {
        var _timeChange:ParsedTimeChange = {tempo: _tempo, time: 0.0, step: 0.0};

        for (i in 0 ... timeChanges.length)
        {
            var __timeChange:ParsedTimeChange = timeChanges[i];

            if (_time >= __timeChange.time)
                _timeChange = __timeChange;
        }

        return _timeChange;
    }
}