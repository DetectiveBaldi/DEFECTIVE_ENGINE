package core;

import tools.formats.charts.BasicFormat.BasicEvent;
import tools.formats.charts.BasicFormat.BasicNote;
import tools.formats.charts.BasicFormat.BasicSong;
import tools.formats.charts.BasicFormat.BasicTimeChange;

class Song
{
    public var name:String;

    public var tempo:Float;

    public var speed:Float;

    public var notes:Array<BasicNote>;

    public var events:Array<BasicEvent>;

    public var timeChanges:Array<BasicTimeChange>;

    public static function fromBasic(input:BasicSong):Song
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