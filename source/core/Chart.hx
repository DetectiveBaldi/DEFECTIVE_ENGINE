package core;

import haxe.Json;

import core.AssetMan;

class Chart
{
    public var name:String;

    public var tempo:Float;

    public var speed:Float;

    public var notes:Array<ParsedNote>;

    public var events:Array<ParsedEvent>;

    public var timeChanges:Array<ParsedTimeChange>;

    public static function build(path:String):Chart
    {
        var output:Chart = new Chart();

        var parsed:ParsedChart = Json.parse(AssetMan.text(path));

        output.name = parsed.name;

        output.tempo = parsed.tempo;

        output.speed = parsed.speed;

        output.notes = parsed.notes;

        output.events = parsed.events;

        output.timeChanges = parsed.timeChanges;

        return output;
    }

    public function new():Void
    {
        name = "Test";

        tempo = 150.0;

        speed = 1.6;

        notes = new Array<ParsedNote>();

        events = new Array<ParsedEvent>();

        timeChanges = [{tempo: tempo, time: 0.0, step: 0.0, beat: 0.0, section: 0.0}];
    }
}

typedef ParsedChart =
{
    var name:String;

    var tempo:Float;

    var speed:Float;

    var notes:Array<ParsedNote>;

    var events:Array<ParsedEvent>;

    var timeChanges:Array<ParsedTimeChange>;
};

typedef ParsedNote =
{
    var time:Float;

    var speed:Float;

    var direction:Int;

    var lane:Int;

    var length:Float;
};

typedef ParsedEvent =
{
    var time:Float;

    var name:String;

    var value:Dynamic;
};

typedef ParsedTimeChange =
{
    var tempo:Float;
    
    var time:Float;

    var ?step:Float;

    var ?beat:Float;

    var ?section:Float;
};