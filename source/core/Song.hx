package core;

class Song
{
    public var name:String;

    public var tempo:Float;

    public var speed:Float;

    public var notes:Array<SimpleNote>;

    public var events:Array<SimpleEvent>;

    public var timeChanges:Array<SimpleTimeChange>;

    public static function fromSimple(input:SimpleSong):Song
    {
        var output:Song = new Song();

        output.name = input.name;

        output.tempo = input.tempo;

        output.speed = input.speed;

        output.notes = input.notes;

        output.events = input.events;

        output.timeChanges = input.timeChanges;

        return output;
    }

    public function new():Void
    {

    }
}

typedef SimpleSong =
{
    var name:String;

    var tempo:Float;

    var speed:Float;

    var notes:Array<SimpleNote>;

    var events:Array<SimpleEvent>;

    var timeChanges:Array<SimpleTimeChange>;
};

typedef SimpleNote =
{
    var time:Float;

    var speed:Float;

    var direction:Int;

    var lane:Int;
};

typedef SimpleEvent =
{
    var time:Float;

    var name:String;

    var value:Dynamic;
};

typedef SimpleTimeChange =
{
    var time:Float;

    var tempo:Float;

    var ?step:Float;

    var ?beat:Float;

    var ?section:Float;
};