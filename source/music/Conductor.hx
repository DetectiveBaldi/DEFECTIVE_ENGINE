package music;

import flixel.FlxBasic;

import flixel.util.FlxSignal.FlxTypedSignal;

import game.Chart.LoadedTimeChange;

/**
 * A class which handles musical timing events throughout the game. It is the heart of `game.GameState`.
 */
class Conductor extends FlxBasic
{
    public var step(get, never):Int;

    @:noCompletion
    function get_step():Int
    {
        return Math.floor(((time - timeChange.time) / (crotchet * 0.25)) + timeChange.step);
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

    public var crotchet(get, never):Float;

    @:noCompletion
    function get_crotchet():Float
    {
        return 60.0 / tempo * 1000.0;
    }

    public var time:Float;

    public var timeChange:LoadedTimeChange;

    public var timeChanges:Array<LoadedTimeChange>;

    public function new():Void
    {
        super();

        visible = false;

        onStepHit = new FlxTypedSignal<(step:Int)->Void>();

        onBeatHit = new FlxTypedSignal<(beat:Int)->Void>();

        onMeasureHit = new FlxTypedSignal<(measure:Int)->Void>();

        tempo = 150.0;

        time = 0.0;

        timeChange = {time: 0.0, tempo: 150.0, step: 0.0};

        timeChanges = new Array<LoadedTimeChange>();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        var oldStep:Int = step;

        var oldBeat:Int = beat;

        var oldMeasure:Int = measure;

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
                var oldTime:Float = timeChange.time;

                timeChange.time = _timeChange.time;

                timeChange.tempo = _timeChange.tempo;

                timeChange.step += (timeChange.time - oldTime) / (crotchet * 0.25);

                tempo = timeChange.tempo;
            }
            
            break;
        }

        if (step != oldStep)
            onStepHit.dispatch(step);

        if (beat != oldBeat)
            onBeatHit.dispatch(beat);

        if (measure != oldMeasure)
            onMeasureHit.dispatch(measure);
    }

    override function destroy():Void
    {
        super.destroy();

        onStepHit.destroy();

        onStepHit = null;

        onBeatHit.destroy();

        onBeatHit = null;

        onMeasureHit.destroy();

        onMeasureHit = null;
    }

    public function getTimeChange(tempo:Float, time:Float):LoadedTimeChange
    {
        var timeChange:LoadedTimeChange = {tempo: tempo, time: 0.0, step: 0.0};

        for (i in 0 ... timeChanges.length)
        {
            var _timeChange:LoadedTimeChange = timeChanges[i];

            if (time >= _timeChange.time)
                timeChange = _timeChange;
        }

        return timeChange;
    }
}