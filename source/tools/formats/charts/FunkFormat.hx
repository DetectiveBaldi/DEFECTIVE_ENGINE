package tools.formats.charts;

import haxe.Json;

import tools.formats.charts.BasicFormat.BasicEvent;
import tools.formats.charts.BasicFormat.BasicNote;
import tools.formats.charts.BasicFormat.BasicSong;
import tools.formats.charts.BasicFormat.BasicTimeChange;

class FunkFormat
{
    public static function build(chartPath:String, metaPath:String, ?level:String = "normal"):BasicSong
    {
        var output:BasicSong =
        {
            name: "Test",

            tempo: 150.0,

            speed: 1.0,

            notes: new Array<BasicNote>(),

            events: new Array<BasicEvent>(),

            timeChanges: new Array<BasicTimeChange>()
        };

        var chart:Dynamic = Json.parse(#if html5 openfl.utils.Assets.getText(chartPath) #else sys.io.File.getContent(chartPath) #end);

        var meta:Dynamic = Json.parse(#if html5 openfl.utils.Assets.getText(metaPath) #else sys.io.File.getContent(metaPath) #end);

        output.name = meta.songName;

        output.tempo = meta.timeChanges[0].bpm;

        output.speed = Reflect.field(chart.scrollSpeed, level);

        for (i in 0 ... Reflect.field(chart.notes, level).length)
        {
            var note:FunkNote = Reflect.field(chart.notes, level)[i];

            output.notes.push({time: note.t, speed: 1.0, direction: note.d % 4, lane: 1 - Math.floor(note.d * 0.25), length: note.l});
        }

        for (i in 0 ... chart.events.length)
        {
            var event:FunkEvent = chart.events[i];

            output.events.push({time: event.t, name: event.e, value: event.v});
        }

        for (i in 0 ... meta.timeChanges.length)
        {
            var timeChange:FunkTimeChange = meta.timeChanges[i];

            output.timeChanges.push({tempo: timeChange.bpm, time: timeChange.t, step: 0.0, beat: 0.0, section: 0.0});
        }

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