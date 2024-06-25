package tools.formats;

import haxe.Json;

import openfl.net.FileReference;

import core.Song.SimpleEvent;
import core.Song.SimpleNote;
import core.Song.SimpleSong;

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

            events: new Array<SimpleEvent>()
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

        output.tempo = meta.timeChanges[0].bpm;

        output.speed = Reflect.field(chart.scrollSpeed, difficulty);

        var noteIndex:Int = 0;

        var note:FunkNote = cast Reflect.field(chart.notes, difficulty)[noteIndex];

        while (note != null)
        {
            noteIndex++;

            output.notes.push({time: note.t, speed: 1, direction: note.d % 4, lane: 1 - Math.floor(note.d / 4.0)});

            note = cast Reflect.field(chart.notes, difficulty)[noteIndex];
        }

        var eventIndex:Int = 0;

        var event:FunkEvent = cast chart.events[eventIndex];

        while (event != null)
        {
            eventIndex++;

            output.events.push({time: event.t, name: event.e, value: event.v});

            event = cast chart.events[eventIndex];
        }

        var fileReference:FileReference = new FileReference();

        fileReference.save(Json.stringify(output), "chart.json");

        return output;
    }
}

typedef FunkEvent =
{
    var t:Float;

    var e:String;

    var v:Dynamic;
};

typedef FunkNote =
{
    var t:Float;

    var d:Int;

    var l:Float;

    var k:String;
};