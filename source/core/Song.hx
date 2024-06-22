package core;

class Song
{
    public var name:String;

    public var tempo:Float;

    public var speed:Float;

    public var notes:Array<SimpleNote>;

    public var events:Array<SimpleEvent>;

    public function new():Void
    {

    }

    public static function fromSimple(input:SimpleSong):Song
    {
        var output:Song = new Song();

        output.name = input.name;

        output.tempo = input.tempo;

        output.speed = input.speed;

        output.notes = input.notes;

        output.events = input.events;

        return output;
    }

    public static function toSimple(input:Song):SimpleSong
    {
        var output:SimpleSong =
        {
            name: input.name,
            
            tempo: input.tempo,
            
            speed: input.speed,
            
            notes: input.notes,

            events: input.events
        };

        return output;
    }
}

typedef SimpleEvent =
{
    var time:Float;

    var name:String;

    var value:Dynamic;
};

typedef SimpleNote =
{
    var time:Float;

    var speed:Float;

    var direction:Int;

    var lane:Int;
};

typedef SimpleSong =
{
    var name:String;

    var tempo:Float;

    var speed:Float;

    var notes:Array<SimpleNote>;

    var events:Array<SimpleEvent>;
};