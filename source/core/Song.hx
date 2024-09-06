package core;

import tools.formats.charts.StandardFormat.StandardEvent;
import tools.formats.charts.StandardFormat.StandardNote;
import tools.formats.charts.StandardFormat.StandardSong;
import tools.formats.charts.StandardFormat.StandardTimeChange;

class Song
{
    public var name:String;

    public var tempo:Float;

    public var speed:Float;

    public var notes:Array<StandardNote>;

    public var events:Array<StandardEvent>;

    public var timeChanges:Array<StandardTimeChange>;

    public static function fromStandard(input:StandardSong):Song
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