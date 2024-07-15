package tools.formats;

import haxe.Json;

import openfl.net.FileReference;

import core.Song.SimpleEvent;
import core.Song.SimpleNote;
import core.Song.SimpleSong;
import core.Song.SimpleTimeChange;

class FunkFormat
{
    public static function build(chartPath:String, metaPath:String, ?level:String = "normal"):SimpleSong
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

        var chart:Dynamic = Json.parse(#if html5 openfl.utils.Assets.getText(chartPath) #else sys.io.File.getContent(chartPath) #end);

        var meta:Dynamic = Json.parse(#if html5 openfl.utils.Assets.getText(metaPath) #else sys.io.File.getContent(metaPath) #end);

        output.name = meta.songName;

        output.tempo = meta.timeChanges[0].bpm;

        output.speed = Reflect.field(chart.scrollSpeed, level);

        var notes:Array<FunkNote> = Reflect.field(chart.notes, level);

        for (i in 0 ... notes.length)
        {
            var note:FunkNote = notes[i];

            output.notes.push({time: note.t, speed: 1, direction: note.d % 4, lane: 1 - Math.floor(note.d * 0.25), length: note.l});
        }

        var events:Array<FunkEvent> = chart.events;

        for (i in 0 ... events.length)
        {
            var event:FunkEvent = events[i];

            output.events.push({time: event.t, name: event.e, value: event.v});
        }

        var timeChanges:Array<FunkTimeChange> = meta.timeChanges;

        for (i in 0 ... timeChanges.length)
        {
            var timeChange:FunkTimeChange = timeChanges[i];

            output.timeChanges.push({time: timeChange.t, tempo: timeChange.bpm, step: 0.0, beat: 0.0, section: 0.0});
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