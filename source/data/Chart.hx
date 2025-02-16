package data;

import haxe.Json;

import core.Assets;
import core.Paths;

import util.TimedObjectUtil.TimedObject;

class Chart
{
    public static function build(path:String):Chart
    {
        var output:Chart = new Chart();

        var raw:RawChart = Json.parse(Assets.getText(Paths.json(path)));

        output.name = raw.name;

        output.tempo = raw.tempo;

        output.scrollSpeed = raw.scrollSpeed;

        output.notes = raw.notes;

        output.events = raw.events;

        output.timeChanges = raw.timeChanges;

        return output;
    }

    /**
     * A unique `String` identifier for `this` `Chart`. Used in several areas of the application.
     */
    public var name:String;

    public var tempo:Float;

    public var scrollSpeed:Float;

    public var notes:Array<RawNote>;

    public var events:Array<RawEvent>;

    public var timeChanges:Array<RawTimeChange>;

    public function new():Void
    {
        name = "Test";

        tempo = 150.0;

        scrollSpeed = 1.6;

        notes = new Array<RawNote>();

        events = new Array<RawEvent>();

        timeChanges = new Array<RawTimeChange>();
    }
}

typedef RawChart =
{
    var name:String;

    var tempo:Float;

    var scrollSpeed:Float;

    var notes:Array<RawNote>;

    var events:Array<RawEvent>;

    var timeChanges:Array<RawTimeChange>;
}

typedef RawEvent = TimedObject &
{
    var name:String;

    var value:Dynamic;
}

typedef RawNote = TimedObject &
{
    var direction:Int;

    var lane:Int;

    var length:Float;
}

typedef RawTimeChange = TimedObject &
{
    var tempo:Float;

    var step:Float;
}