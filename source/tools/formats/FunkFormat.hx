package tools.formats;

import haxe.Json;

import openfl.net.FileReference;

import core.Song.SimpleEvent;
import core.Song.SimpleNote;
import core.Song.SimpleSong;
import core.Song.SimpleTimeChange;

class FunkFormat
{
    public static function build(chartPath:String, metaPath:String, ?difficulty:String = "normal"):SimpleSong
    {
        var output:SimpleSong =
        {
            name: "Test",

            tempo: 150.0,

            speed: 1.0,

            notes: new Array<SimpleNote>(),

            events: new Array<SimpleEvent>(),

            timeChanges: new Array<SimpleTimeChange>()
        };

        #if html5
            var chart:Dynamic = Json.parse(openfl.utils.Assets.getText(chartPath));
        #else
            var chart:Dynamic = Json.parse(sys.io.File.getContent(chartPath));
        #end

        #if html5
            var meta:Dynamic = Json.parse(openfl.utils.Assets.getText(metaPath));
        #else
            var meta:Dynamic = Json.parse(sys.io.File.getContent(metaPath));
        #end

        output.name = meta.songName;

        output.tempo = meta.timeChanges.shift().bpm;

        output.speed = Reflect.field(chart.scrollSpeed, difficulty);

        while (Reflect.field(chart.notes, difficulty)[0] != null)
        {
            var note:FunkNote = cast Reflect.field(chart.notes, difficulty)[0];

            output.notes.push({time: note.t, speed: 1, direction: note.d % 4, lane: 1 - Math.floor(note.d * 0.25)});

            Reflect.field(chart.notes, difficulty).shift();
        }

        while (chart.events[0] != null)
        {
            var event:FunkEvent = cast chart.events[0];

            output.events.push({time: event.t, name: event.e, value: event.v});

            chart.events.shift();
        }

        while (meta.timeChanges[0] != null)
        {
            var timeChange:FunkTimeChange = cast meta.timeChanges[0];

            output.timeChanges.push({time: timeChange.t, tempo: timeChange.bpm});

            meta.timeChanges.shift();
        }

        var fileReference:FileReference = new FileReference();

        fileReference.save(Json.stringify(output), "chart.json");

        return output;
    }
}

typedef FunkNote =
{
    var t:Float;

    var d:Int;

    var l:Float;

    var k:String;
};

typedef FunkEvent =
{
    var t:Float;

    var e:String;

    var v:Dynamic;
};

typedef FunkTimeChange =
{
    var t:Float;

    var b:Float;

    var bpm:Float;

    var n:Int;

    var d:Int;

    var bt:Array<Int>;
};