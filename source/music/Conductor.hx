package music;

import flixel.FlxBasic;

import flixel.util.FlxDestroyUtil;

import flixel.util.FlxSignal.FlxTypedSignal;

import data.Chart.TimingPointData;

using util.ArrayUtil;
using util.TimingUtil;

class Conductor
{
    public var decStep(get, never):Float;

    @:noCompletion
    function get_decStep():Float
    {
        return getStepAt(time);
    }

    public var decBeat(get, never):Float;

    @:noCompletion
    function get_decBeat():Float
    {
        return getBeatAt(time);
    }

    public var decMeasure(get, never):Float;

    @:noCompletion
    function get_decMeasure():Float
    {
        return getMeasureAt(time);
    }

    public var step(get, never):Int;

    @:noCompletion
    function get_step():Int
    {
        return Math.floor(decStep);
    }

    public var beat(get, never):Int;

    @:noCompletion
    function get_beat():Int
    {
        return Math.floor(decBeat);
    }

    public var measure(get, never):Int;

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
        onStepHit = new FlxTypedSignal<(step:Int)->Void>();

        onBeatHit = new FlxTypedSignal<(beat:Int)->Void>();

        onMeasureHit = new FlxTypedSignal<(measure:Int)->Void>();

        time = 0.0;

        timingPoints = new Array<TimingPoint>();
    }

    public function update(time:Float):Void
    {
        var lastStep:Int = step;

        var lastBeat:Int = beat;

        var lastMeasure:Int = measure;

        this.time = time;

        if (step != lastStep)
            onStepHit.dispatch(step);

        if (beat != lastBeat)
            onBeatHit.dispatch(beat);

        if (measure != lastMeasure)
            onMeasureHit.dispatch(measure);
    }

    public function destroy():Void
    {
        onStepHit = cast FlxDestroyUtil.destroy(onStepHit);

        onBeatHit = cast FlxDestroyUtil.destroy(onBeatHit);

        onMeasureHit = cast FlxDestroyUtil.destroy(onMeasureHit);

        timingPoints = null;
    }
    
    public function getTimingPointAtTime(time:Float):TimingPoint
    {
        var res:TimingPoint = timingPoints[0];

        for (i in 1 ... timingPoints.length)
        {
            var timingPoint:TimingPoint = timingPoints[i];

            if (time < timingPoint.time)
                break;

            res = timingPoint;
        }

        return res;
    }

    public function getTimingPointAtBeat(beat:Float):TimingPoint
    {
        var output:TimingPoint = timingPoints[0];

        for (i in 1 ... timingPoints.length)
        {
            var point:TimingPoint = timingPoints[i];

            if (beat < point.beatOffset)
                break;

            output = point;
        }

        return output;
    }

    public function getStepAt(time:Float):Float
    {
        return getBeatAt(time) * 4.0;
    }

    public function getBeatAt(time:Float):Float
    {
        var point:TimingPoint = timingPoint;

        return point.beatOffset + (time - point.time) / beatLength;
    }

    public function getMeasureAt(time:Float):Float
    {
        var point:TimingPoint = timingPoint;

        return point.measureOffset + (time - point.time) / measureLength;
    }

    public function stepToTime(step:Float):Float
    {
        return beatToTime(step) * 0.25;
    }

    public function beatToTime(beat:Float):Float
    {
        var point:TimingPoint = getTimingPointAtBeat(beat);

        return point.time + beatLength * (beat - point.beatOffset);
    }

    public function measureToTime(measure:Float):Float
    {
        var point:TimingPoint = timingPoint;

        return point.time + measureLength * (measure - point.measureOffset);
    }

    public function writeTimingPointData(list:Array<TimingPointData>):Void
    {
        for (i in 0 ... list.length)
            timingPoints.push(TimingPoint.decodeData(list[i]));
    }

    public function calibrateTimingPoints():Void
    {
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

interface IBeatDispatcher
{
    public var conductor:Conductor;

    public function stepHit(step:Int):Void;

    public function beatHit(beat:Int):Void;

    public function measureHit(measure:Int):Void;
}