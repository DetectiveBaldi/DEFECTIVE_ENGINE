package music;

import data.Chart.TimingPointData;

@:structInit
class TimingPoint
{
    public var time:Float;

    public var tempo:Float;

    public var beatsPerMeasure:Int;

    public var stepLength(get, never):Float;

    @:noCompletion
    function get_stepLength():Float
    {
        return beatLength * 0.25;
    }

    public var beatLength(get, never):Float;

    @:noCompletion
    function get_beatLength():Float
    {
        return 60.0 / tempo * 1000.0;
    }

    public var measureLength(get, never):Float;

    @:noCompletion
    function get_measureLength():Float
    {
        return beatLength * beatsPerMeasure;
    }

    public var beatOffset:Float;

    public var measureOffset:Float;

    public function new(time:Float, tempo:Float, beatsPerMeasure:Int):Void
    {
        this.time = time;

        this.tempo = tempo;

        this.beatsPerMeasure = beatsPerMeasure;

        beatOffset = 0.0;

        measureOffset = 0.0;
    }

    public static function decodeData(v:TimingPointData):TimingPoint
    {
        return {time: v.time, tempo: v.tempo, beatsPerMeasure: v.beatsPerMeasure}
    }
}