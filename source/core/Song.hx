package core;

import tools.formats.charts.ClassicFormat.ClassicEvent;
import tools.formats.charts.ClassicFormat.ClassicNote;
import tools.formats.charts.ClassicFormat.ClassicSong;
import tools.formats.charts.ClassicFormat.ClassicTimeChange;

class Song
{
    public var name:String;

    public var tempo:Float;

    public var speed:Float;

    public var notes:Array<ClassicNote>;

    public var events:Array<ClassicEvent>;

    public var timeChanges:Array<ClassicTimeChange>;

    public static function fromClassic(input:ClassicSong):Song
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