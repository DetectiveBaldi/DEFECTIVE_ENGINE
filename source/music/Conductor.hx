package music;

import haxe.Rest;

import flixel.FlxBasic;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal.FlxTypedSignal;

import data.Chart.TimingPointData;
import interfaces.IBeatDispatcher;

using tools.ArrayTools;
using tools.TimeSortTools;

class Conductor extends FlxBasic
{
    public var decStep:Float;

    @:noCompletion
    function get_decStep():Float
    {
        return getStepAt(time);
    }

    public var decBeat:Float;

    @:noCompletion
    function get_decBeat():Float
    {
        return getBeatAt(time);
    }

    public var decMeasure:Float;

    @:noCompletion
    function get_decMeasure():Float
    {
        return getMeasureAt(time);
    }

    public var step:Int;

    @:noCompletion
    function get_step():Int
    {
        return Math.floor(decStep);
    }

    public var beat:Int;

    @:noCompletion
    function get_beat():Int
    {
        return Math.floor(decBeat);
    }

    public var measure:Int;

    @:noCompletion
    function get_measure():Int
    {
        return Math.floor(decMeasure);
    }

    public var onStepHit:FlxTypedSignal<(step:Int)->Void>;

    public var onBeatHit:FlxTypedSignal<(beat:Int)->Void>;

    public var onMeasureHit:FlxTypedSignal<(measure:Int)->Void>;

    public var tempo(get, set):Float;

    @:noCompletion
    function get_tempo():Float
    {
        return timingPoint.tempo;
    }

    @:noCompletion
    function set_tempo(val:Float):Float
    {
        timingPoint.tempo = val;

        return tempo;
    }

    public var beatsPerMeasure(get, set):Int;

    @:noCompletion
    function get_beatsPerMeasure():Int
    {
        return timingPoint.beatsPerMeasure;
    }

    @:noCompletion
    function set_beatsPerMeasure(val:Int):Int
    {
        timingPoint.beatsPerMeasure = val;

        return beatsPerMeasure;
    }

    public var stepLength(get, never):Float;

    @:noCompletion
    function get_stepLength():Float
    {
        return timingPoint.stepLength;
    }

    public var beatLength(get, never):Float;

    @:noCompletion
    function get_beatLength():Float
    {
        return timingPoint.beatLength;
    }

    public var measureLength(get, never):Float;

    @:noCompletion
    function get_measureLength():Float
    {
        return timingPoint.measureLength;
    }

    public var time:Float;

    public var timingPoints:Array<TimingPoint>;

    public var timingPoint(get, never):TimingPoint;
    
    @:noCompletion
    function get_timingPoint():TimingPoint
    {
        return getTimingPointAtTime(time);
    }

    public function new():Void
    {
        super();

        visible = false;

        decStep = 0.0;

        decBeat = 0.0;

        decMeasure = 0.0;

        step = 0;

        beat = 0;

        measure = 0;

        onStepHit = new FlxTypedSignal<(step:Int)->Void>();

        onBeatHit = new FlxTypedSignal<(beat:Int)->Void>();

        onMeasureHit = new FlxTypedSignal<(measure:Int)->Void>();

        time = 0.0;

        timingPoints = new Array<TimingPoint>();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        time += 1000.0 * elapsed;
    }

    override function destroy():Void
    {
        super.destroy();

        onStepHit = cast FlxDestroyUtil.destroy(onStepHit);

        onBeatHit = cast FlxDestroyUtil.destroy(onBeatHit);

        onMeasureHit = cast FlxDestroyUtil.destroy(onMeasureHit);

        timingPoints = null;
    }

    public function getStepAt(time:Float):Float
    {
        return getBeatAt(time) * 4.0;
    }

    public function getBeatAt(time:Float):Float
    {
        var t:TimingPoint = timingPoint;

        return t.beatOffset + (time - t.time) / beatLength;
    }

    public function getMeasureAt(time:Float):Float
    {
        var t:TimingPoint = timingPoint;

        return t.measureOffset + (time - t.time) / measureLength;
    }

    public function stepToTime(step:Float):Float
    {
        return beatToTime(step) * 0.25;
    }

    public function beatToTime(beat:Float):Float
    {
        var t:TimingPoint = timingPoint;

        return t.time + beatLength * (beat - t.beatOffset);
    }

    public function measureToTime(measure:Float):Float
    {
        var t:TimingPoint = timingPoint;

        return t.time + measureLength * (measure - t.measureOffset);
    }

    public function updateSteps():Void
    {
        var lastStep:Int = step;

        var lastBeat:Int = beat;

        var lastMeasure:Int = measure;

        decStep = getStepAt(time);

        decBeat = getBeatAt(time);

        decMeasure = getMeasureAt(time);

        step = Math.floor(decStep);

        beat = Math.floor(decBeat);

        measure = Math.floor(decMeasure);

        if (step != lastStep)
            onStepHit.dispatch(step);

        if (beat != lastBeat)
            onBeatHit.dispatch(beat);

        if (measure != lastMeasure) 
            onMeasureHit.dispatch(measure);
    }

    public function addListeners(dispatcher:IBeatDispatcher):Void
    {
        onStepHit.add(dispatcher.stepHit);

        onBeatHit.add(dispatcher.beatHit);

        onMeasureHit.add(dispatcher.measureHit);
    }

    public function removeListeners(dispatcher:IBeatDispatcher):Void
    {
        onStepHit.remove(dispatcher.stepHit);

        onBeatHit.remove(dispatcher.beatHit);

        onMeasureHit.remove(dispatcher.measureHit);
    }
    
    public function getTimingPointAtTime(time:Float):TimingPoint
    {
        var t:TimingPoint = timingPoints[0];

        for (i in 1 ... timingPoints.length)
        {
            var tt:TimingPoint = timingPoints[i];

            if (time < tt.time)
                break;

            t = tt;
        }

        return t;
    }

    public function getTimingPointAtBeat(beat:Float):TimingPoint
    {
        var t:TimingPoint = timingPoints[0];

        for (i in 1 ... timingPoints.length)
        {
            var tt:TimingPoint = timingPoints[i];

            if (beat < tt.beatOffset)
                break;

            t = tt;
        }

        return t;
    }

    public function setTimingPoints(v:Array<TimingPointData>):Void
    {
        for (i in 0 ... v.length)
        {
            var t:TimingPointData = v[i];

            timingPoints.push(TimingPoint.build(t));
        }

        var timeOffset:Float = 0.0;

        var beatOffset:Float = 0.0;

        var measureOffset:Float = 0.0;

        var lastTempo:Float = 0.0;

        var lastBeatsPerMeasure:Int = 0;

        for (timingPoint in timingPoints)
        {
            if (timingPoint.time == 0.0)
            {
                lastTempo = timingPoint.tempo;

                lastBeatsPerMeasure = timingPoint.beatsPerMeasure;

                continue;
            }

            var beatDifference:Float = (timingPoint.time - timeOffset) / (60.0 / lastTempo * 1000.0);

            measureOffset += beatDifference / lastBeatsPerMeasure;

            beatOffset += beatDifference;

            timeOffset = timingPoint.time;

            lastTempo = timingPoint.tempo;

            lastBeatsPerMeasure = timingPoint.beatsPerMeasure;

            timingPoint.beatOffset = beatOffset;

            timingPoint.measureOffset = measureOffset;
        }
    }
}