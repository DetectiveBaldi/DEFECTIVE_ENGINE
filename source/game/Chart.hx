package game;

import haxe.Json;

import core.AssetMan;
import core.Paths;

import util.TimingUtil.TimedObject;

class Chart
{
    public static function build(path:String):Chart
    {
        var output:Chart = new Chart();

        var parsed:ParsedChart = Json.parse(AssetMan.text(Paths.json(path)));

        output.id = parsed.id;

        output.tempo = parsed.tempo;

        output.speed = parsed.speed;

        output.notes = parsed.notes;

        output.events = parsed.events;

        output.timeChanges = parsed.timeChanges;

        return output;
    }

    /**
     * A unique `String` identifier for `this` `Chart`. Used in several areas.
     */
    public var id:String;

    public var tempo:Float;

    public var speed:Float;

    public var notes:Array<ParsedNote>;

    public var events:Array<ParsedEvent>;

    public var timeChanges:Array<ParsedTimeChange>;

    public function new():Void
    {
        id = "Test";

        tempo = 150.0;

        speed = 1.6;

        notes = new Array<ParsedNote>();

        events = new Array<ParsedEvent>();

        timeChanges = new Array<ParsedTimeChange>();
    }
}

typedef ParsedChart =
{
    var id:String;

    var tempo:Float;

    var speed:Float;

    var notes:Array<ParsedNote>;

    var events:Array<ParsedEvent>;

    var timeChanges:Array<ParsedTimeChange>;
};

typedef ParsedNote = TimedObject &
{
    var speed:Float;

    var direction:Int;

    var lane:Int;

    var length:Float;
};

typedef ParsedEvent = TimedObject &
{
    var name:String;

    var value:Dynamic;
};

typedef ParsedTimeChange = TimedObject &
{
    var tempo:Float;

    var step:Float;
};