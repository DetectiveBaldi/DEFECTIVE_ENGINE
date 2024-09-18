package util.formats.charts;

import haxe.Json;

import core.AssetMan;
import core.Chart;

class FunkFormat
{
    public static function build(chartPath:String, metaPath:String, level:String):Chart
    {
        var output:Chart = new Chart();

        var parsedChart:Dynamic = Json.parse(AssetMan.text(chartPath));

        var parsedMeta:Dynamic = Json.parse(AssetMan.text(metaPath));

        output.name = parsedMeta.songName;

        output.tempo = parsedMeta.timeChanges[0].bpm;

        output.speed = Reflect.field(parsedChart.scrollSpeed, level);

        for (i in 0 ... Reflect.field(parsedChart.notes, level).length)
        {
            var note:FunkNote = Reflect.field(parsedChart.notes, level)[i];

            output.notes.push({time: note.t, speed: 1.0, direction: note.d % 4, lane: 1 - Math.floor(note.d * 0.25), length: note.l});
        }

        for (i in 0 ... parsedChart.events.length)
        {
            var event:FunkEvent = parsedChart.events[i];

            output.events.push({time: event.t, name: event.e, value: event.v});
        }

        output.timeChanges.resize(0);

        for (i in 0 ... parsedMeta.timeChanges.length)
        {
            var timeChange:FunkTimeChange = parsedMeta.timeChanges[i];

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