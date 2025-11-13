package data;

import util.TimingUtil;

using StringTools;

class Chart
{
    public static function decodeData(v:ChartData):Chart
    {
        var chart:Chart = new Chart();

        chart.name = v.name;

        chart.scrollSpeed = v.scrollSpeed;

        chart.notes = v.notes;

        chart.events = v.events;

        chart.timingPoints = v.timingPoints;

        chart.spectator = v.spectator;

        chart.opponent = v.opponent;

        chart.player = v.player;
        
        return chart;
    }

    public var name:String;

    public var tempo:Float;

    public var scrollSpeed:Float;

    public var notes:Array<NoteData>;

    public var events:Array<EventData>;

    public var timingPoints:Array<TimingPointData>;
    
    public var spectator:String;

    public var opponent:String;

    public var player:String;

    public function new():Void
    {
        name = "Test";

        tempo = 150.0;

        scrollSpeed = 1.6;

        notes = new Array<NoteData>();

        events = new Array<EventData>();

        timingPoints = new Array<TimingPointData>();

        spectator = "";

        opponent = "baldi-face-front";

        player = "bf-face-left";
    }
}

typedef ChartData =
{
    var name:String;

    var tempo:Float;

    var scrollSpeed:Float;

    var notes:Array<NoteData>;

    var events:Array<EventData>;

    var timingPoints:Array<TimingPointData>;

    var spectator:String;

    var opponent:String;

    var player:String;
}

typedef EventData = TimedObject &
{
    var name:String;

    var value:Dynamic;
}

typedef NoteData = TimedObject &
{
    var direction:Int;

    var length:Float;

    var lane:Int;

    var kind:NoteKindData;
}

typedef TimingPointData = TimedObject &
{
    var tempo:Float;

    var beatsPerMeasure:Int;
}

@:structInit
class NoteKindData
{
    public var type:String;
    
    public var altAnimation:Bool;

    public var noAnimation:Bool;

    public var specSing:Bool;

    public var charIds:Array<Int>;
}