package game;

import haxe.Json;

import core.Assets;
import core.Paths;

import util.TimingUtil.TimedObject;

class Chart
{
    public static function build(path:String):Chart
    {
        var output:Chart = new Chart();

        var loaded:LoadedChart = Json.parse(Assets.text(Paths.json(path)));

        output.name = loaded.name;

        output.tempo = loaded.tempo;

        output.speed = loaded.speed;

        output.notes = loaded.notes;

        output.events = loaded.events;

        output.timeChanges = loaded.timeChanges;

        return output;
    }

    /**
     * A unique `String` identifier for `this` `Chart`. Used in several areas of the application.
     */
    public var name:String;

    public var tempo:Float;

    public var speed:Float;

    public var notes:Array<LoadedNote>;

    public var events:Array<LoadedEvent>;

    public var timeChanges:Array<LoadedTimeChange>;

    public function new():Void
    {
        name = "Test";

        tempo = 150.0;

        speed = 1.6;

        notes = new Array<LoadedNote>();

        events = new Array<LoadedEvent>();

        timeChanges = new Array<LoadedTimeChange>();
    }
}

typedef LoadedChart =
{
    var name:String;

    var tempo:Float;

    var speed:Float;

    var notes:Array<LoadedNote>;

    var events:Array<LoadedEvent>;

    var timeChanges:Array<LoadedTimeChange>;
};

typedef LoadedNote = TimedObject &
{
    var speed:Float;

    var direction:Int;

    var lane:Int;

    var length:Float;
};

typedef LoadedEvent = TimedObject &
{
    var name:String;

    var value:Dynamic;
};

typedef LoadedTimeChange = TimedObject &
{
    var tempo:Float;

    var step:Float;
};