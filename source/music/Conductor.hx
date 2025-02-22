package music;

import flixel.FlxBasic;

import flixel.util.FlxDestroyUtil;

import flixel.util.FlxSignal.FlxTypedSignal;

import data.Chart.RawTimeChange;

/**
 * A class which handles musical timing events throughout the game. It is the heart of `game.PlayState`.
 */
class Conductor extends FlxBasic
{
    public var step(get, never):Int;

    @:noCompletion
    function get_step():Int
    {
        return Math.floor(((time - timeChange.time) / stepLength) + timeChange.step);
    }

    public var beat(get, never):Int;

    @:noCompletion
    function get_beat():Int
    {
        return Math.floor(step * 0.25);
    }

    public var measure(get, never):Int;

    @:noCompletion
    function get_measure():Int
    {
        return Math.floor(beat * 0.25);
    }

    public var onStepHit:FlxTypedSignal<(step:Int)->Void>;

    public var onBeatHit:FlxTypedSignal<(beat:Int)->Void>;

    public var onMeasureHit:FlxTypedSignal<(measure:Int)->Void>;

    public var tempo:Float;

    public var stepLength(get, never):Float;

    @:noCompletion
    function get_stepLength():Float
    {
        return 60.0 / tempo * 0.25 * 1000.0;
    }

    public var beatLength(get, never):Float;

    @:noCompletion
    function get_beatLength():Float
    {
        return stepLength * 4.0;
    }

    public var time:Float;

    public var timeChange:RawTimeChange;

    public var timeChanges:Array<RawTimeChange>;

    public function new():Void
    {
        super();

        visible = false;

        onStepHit = new FlxTypedSignal<(step:Int)->Void>();

        onBeatHit = new FlxTypedSignal<(beat:Int)->Void>();

        onMeasureHit = new FlxTypedSignal<(measure:Int)->Void>();

        tempo = 100.0;

        time = 0.0;

        timeChange = {time: 0.0, tempo: 100.0, step: 0.0};

        timeChanges = new Array<RawTimeChange>();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        var _step:Int = step;

        var _beat:Int = beat;

        var _measure:Int = measure;

        time += elapsed * 1000.0;

        var i:Int = timeChanges.length - 1;

        while (i >= 0)
        {
            var _timeChange = timeChanges[i];
            
            if (time < _timeChange.time)
            {
                i--;

                continue;
            }

            if (tempo != _timeChange.tempo)
            {
                var _time:Float = timeChange.time;

                timeChange.time = _timeChange.time;

                timeChange.tempo = _timeChange.tempo;

                timeChange.step += (timeChange.time - _time) / stepLength;

                tempo = timeChange.tempo;
            }
            
            break;
        }

        if (step != _step)
            onStepHit.dispatch(step);

        if (beat != _beat)
            onBeatHit.dispatch(beat);

        if (measure != _measure)
            onMeasureHit.dispatch(measure);
    }

    override function destroy():Void
    {
        super.destroy();

        onStepHit = cast FlxDestroyUtil.destroy(onStepHit);

        onBeatHit = cast FlxDestroyUtil.destroy(onBeatHit);

        onMeasureHit = cast FlxDestroyUtil.destroy(onMeasureHit);

        timeChange = null;

        timeChanges = null;
    }

    public function getTimeChange(_tempo:Float, _time:Float):RawTimeChange
    {
        var timeChange:RawTimeChange = {tempo: _tempo, time: 0.0, step: 0.0};

        for (i in 0 ... timeChanges.length)
        {
            var _timeChange:RawTimeChange = timeChanges[i];

            if (_time >= _timeChange.time)
                timeChange = _timeChange;
        }

        return timeChange;
    }
}