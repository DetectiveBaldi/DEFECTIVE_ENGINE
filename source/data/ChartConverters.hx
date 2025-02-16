package data;

import haxe.Json;

import sys.FileSystem;

import core.Assets;
import core.Paths;

import util.TimedObjectUtil;

import util.TimedObjectUtil.RawTimedObject;
import util.TimedObjectUtil.TimedObject;

using StringTools;

using util.ArrayUtil;

class ChartConverters
{
    public static function build(path:String):Chart
    {
        var rawMetaPath:String = path + (path.endsWith("/") ? "meta" : "/meta");

        if (FileSystem.exists(Paths.json(rawMetaPath)))
        {
            var rawChartPath:String = (path.endsWith("/") ? path : '${path}/') + FileSystem.readDirectory(path).oldest((_path:String) -> _path.startsWith("chart")).replace(".json", "");

            var diff:String = rawChartPath.contains("-") ? rawChartPath.split("-").newest() : "normal";

            return FunkinConverter.build(rawChartPath, rawMetaPath, diff);
        }
        else
        {
            var rawChartPath:String = path + (path.endsWith("/") ? "chart" : "/chart");

            var rawChart:Dynamic = Json.parse(Assets.getText(Paths.json(rawChartPath)));

            if (Reflect.hasField(rawChart, "format"))
                return PsychConverter.build(rawChartPath);
            else
                return Chart.build(rawChartPath);
        }
    }
}

class FunkinConverter
{
    public static function build(chartPath:String, metaPath:String, diff:String):Chart
    {
        var output:Chart = new Chart();

        var rawChart:Dynamic = Json.parse(Assets.getText(Paths.json(chartPath)));

        var notes:Array<FunkinNote> = Reflect.field(rawChart.notes, diff);

        TimedObjectUtil.sortRaw(notes);

        var rawMeta:Dynamic = Json.parse(Assets.getText(Paths.json(metaPath)));

        var timeChanges:Array<FunkinTimeChange> = rawMeta.timeChanges;

        TimedObjectUtil.sortRaw(timeChanges);

        output.name = rawMeta.songName;

        output.tempo = timeChanges[0].bpm;

        output.scrollSpeed = Reflect.field(rawChart.scrollSpeed, diff);

        for (i in 0 ... notes.length)
        {
            var note:FunkinNote = notes[i];

            output.notes.push({time: note.t, direction: note.d % 4, lane: 1 - Math.floor(note.d * 0.25), length: note.l});
        }

        for (i in 1 ... timeChanges.length)
        {
            var timeChange:FunkinTimeChange = timeChanges[i];

            output.timeChanges.push({time: timeChange.t, tempo: timeChange.bpm, step: 0.0});
        }

        sys.FileSystem.createDirectory("assets/data/game/FunkinConverter/");

        sys.FileSystem.createDirectory('assets/data/game/FunkinConverter/${output.name}/');

        sys.io.File.saveContent('assets/data/game/FunkinConverter/${output.name}.json', Json.stringify({name: output.name, tempo: output.tempo, scrollSpeed: output.scrollSpeed, notes: output.notes, events: output.events, timeChanges: output.timeChanges}));

        return output;
    }
}

class PsychConverter
{
    public static function build(path:String):Chart
    {
        var output:Chart = new Chart();

        var raw:Dynamic = Json.parse(Assets.getText(Paths.json(path)));

        output.name = raw.song;

        output.tempo = raw.bpm;

        output.scrollSpeed = raw.speed;

        for (i in 0 ... raw.notes.length)
        {
            var section:Dynamic = raw.notes[i];

            var _section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... section.sectionNotes.length)
                    {
                        var note:Array<Dynamic> = section.sectionNotes[j];

                        {time: note[0], direction: note[1], length: note[2]}
                    }
                ],

                sectionBeats: section.sectionBeats,

                mustHitSection: section.mustHitSection,

                changeBPM: section.changeBPM,

                bpm: section.bpm
            };
            
            TimedObjectUtil.sort(_section.sectionNotes);

            for (j in 0 ... _section.sectionNotes.length)
            {
                var note:PsychNote = _section.sectionNotes[j];

                output.notes.push({time: note.time, direction: note.direction % 4, lane: 1 - Math.floor(note.direction * 0.25), length: note.length});
            }
        }

        var time:Float = 0.0;

        var tempo:Float = output.tempo;

        for (i in 0 ... raw.notes.length)
        {
            var section:Dynamic = raw.notes[i];

            var _section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... section.sectionNotes.length)
                    {
                        var note:Array<Dynamic> = section.sectionNotes[j];

                        {time: note[0], direction: note[1], length: note[2]}
                    }
                ],

                sectionBeats: section.sectionBeats,

                mustHitSection: section.mustHitSection,

                changeBPM: section.changeBPM,

                bpm: section.bpm
            };

            TimedObjectUtil.sort(_section.sectionNotes);

            var beatLength:Float = (60.0 / tempo * 1000.0);

            if (_section.changeBPM)
            {
                tempo = _section.bpm;

                beatLength = (60.0 / tempo * 1000.0);

                output.timeChanges.push({time: time, tempo: tempo, step: 0.0});
            }

            time += beatLength * (Math.round(_section.sectionBeats * 4.0) * 0.25);
        }

        sys.FileSystem.createDirectory("assets/data/game/PsychConverter/");

        sys.FileSystem.createDirectory('assets/data/game/PsychConverter/${output.name}/');

        sys.io.File.saveContent('assets/data/game/PsychConverter/${output.name}.json', Json.stringify({name: output.name, tempo: output.tempo, scrollSpeed: output.scrollSpeed, notes: output.notes, events: output.events, timeChanges: output.timeChanges}));

        return output;
    }
}

typedef FunkinEvent = RawTimedObject &
{
    var e:String;

    var v:Dynamic;
};

typedef FunkinNote = RawTimedObject &
{
    var d:Int;

    var l:Float;

    var k:String;
};

typedef FunkinTimeChange = RawTimedObject &
{
    var b:Float;

    var bpm:Float;

    var n:Int;

    var d:Int;

    var bt:Array<Int>;
};

typedef PsychSection =
{
    var sectionNotes:Array<PsychNote>;

    var sectionBeats:Float;

    var mustHitSection:Bool;

    var changeBPM:Bool;

    var bpm:Float;
};

typedef PsychEvent = TimedObject &
{
    var name:String;

    var value1:String;

    var value2:String;
};

typedef PsychNote = TimedObject &
{
    var direction:Int;

    var length:Float;
};