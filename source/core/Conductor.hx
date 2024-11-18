package core;

import flixel.FlxBasic;

import flixel.util.FlxSignal.FlxTypedSignal;

import game.Chart.LoadedTimeChange;

/**
 * A class which handles musical timing events throughout the game. It is the heart of `game.GameState`.
 */
class Conductor extends FlxBasic
{
    public var unsafeStep(get, never):Float;

    @:noCompletion
    function get_unsafeStep():Float
    {
        return ((time - timeChange.time) / (crotchet * 0.25)) + timeChange.step;
    }

    public var unsafeBeat(get, never):Float;

    @:noCompletion
    function get_unsafeBeat():Float
    {
        return unsafeStep * 0.25;
    }

    public var unsafeSection(get, never):Float;

    @:noCompletion
    function get_unsafeSection():Float
    {
        return unsafeBeat * 0.25;
    }
    
    public var step(get, never):Int;

    @:noCompletion
    function get_step():Int
    {
        return Math.floor(unsafeStep);
    }

    public var beat(get, never):Int;

    @:noCompletion
    function get_beat():Int
    {
        return Math.floor(unsafeBeat);
    }

    public var section(get, never):Int;

    @:noCompletion
    function get_section():Int
    {
        return Math.floor(unsafeSection);
    }

    public var stepHit:FlxTypedSignal<(step:Int)->Void>;

    public var beatHit:FlxTypedSignal<(beat:Int)->Void>;

    public var sectionHit:FlxTypedSignal<(section:Int)->Void>;

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

        stepHit = new FlxTypedSignal<(step:Int)->Void>();

        beatHit = new FlxTypedSignal<(beat:Int)->Void>();

        sectionHit = new FlxTypedSignal<(section:Int)->Void>();

        tempo = 150.0;

        time = 0.0;

        timeChange = {time: 0.0, tempo: 150.0, step: 0.0};

        timeChanges = new Array<LoadedTimeChange>();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        var lastStep:Int = step;

        var lastBeat:Int = beat;

        var lastSection:Int = section;

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
                var lastTime:Float = timeChange.time;

                timeChange.time = _timeChange.time;

                timeChange.tempo = _timeChange.tempo;

                timeChange.step += (timeChange.time - lastTime) / (crotchet * 0.25);

                tempo = timeChange.tempo;
            }
            
            break;
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