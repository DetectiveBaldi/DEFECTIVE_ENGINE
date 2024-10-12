package game;

import haxe.Json;

import core.AssetMan;
import core.Paths;

import util.TimingUtil;

import util.TimingUtil.SimpleTimedObject;
import util.TimingUtil.TimedObject;

class FunkConverter
{
    public static function build(chartPath:String, metaPath:String, level:String):Chart
    {
        var output:Chart = new Chart();

        var parsedChart:Dynamic = Json.parse(AssetMan.text(Paths.json(chartPath)));

        var notes:Array<FunkNote> = Reflect.field(parsedChart.notes, level);

        TimingUtil.sortSimple(notes);

        var parsedMeta:Dynamic = Json.parse(AssetMan.text(Paths.json(metaPath)));

        var timeChanges:Array<FunkTimeChange> = parsedMeta.timeChanges;

        TimingUtil.sortSimple(timeChanges);

        output.name = parsedMeta.songName;

        output.tempo = timeChanges.shift().bpm;

        output.speed = Reflect.field(parsedChart.scrollSpeed, level);

        for (i in 0 ... notes.length)
        {
            var note:FunkNote = notes[i];

            output.notes.push({time: note.t, speed: 1.0, direction: note.d % 4, lane: 1 - Math.floor(note.d * 0.25), length: note.l});
        }

        for (i in 0 ... timeChanges.length)
        {
            var timeChange:FunkTimeChange = timeChanges[i];

            output.timeChanges.push({time: timeChange.t, tempo: timeChange.bpm, step: 0.0, beat: 0.0, section: 0.0});
        }

        return output;
    }
}

class PsychConverter
{
    public static function build(path:String):Chart
    {
        var output:Chart = new Chart();

        var parsed:Dynamic = Json.parse(AssetMan.text(Paths.json(path)));

        output.name = parsed.song.song;

        output.tempo = parsed.song.bpm;

        output.speed = parsed.song.speed;

        for (i in 0 ... parsed.song.notes.length)
        {
            var section:Dynamic = parsed.song.notes[i];

            var _section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... section.sectionNotes.length)
                    {
                        var note:Array<Dynamic> = section.sectionNotes[j];

                        {time: note[0], direction: note[1], length: cast note[2]}
                    }
                ],

                sectionBeats: section.sectionBeats,

                mustHitSection: section.mustHitSection,

                changeBPM: section.changeBPM,

                bpm: section.bpm
            };
            
            TimingUtil.sort(_section.sectionNotes);

            for (j in 0 ... _section.sectionNotes.length)
            {
                var note:PsychNote = _section.sectionNotes[j];

                output.notes.push({time: note.time, speed: 1.0, direction: note.direction % 4, lane: 1 - Math.floor((_section.mustHitSection ? note.direction : (note.direction >= 4.0) ? note.direction - 4 : note.direction + 4) * 0.25), length: note.length});
            }
        }

        var time:Float = 0.0;

        var tempo:Float = 0.0;

        for (i in 0 ... parsed.song.notes.length)
        {
            var section:Dynamic = parsed.song.notes[i];

            var _section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... section.sectionNotes.length)
                    {
                        var note:Array<Dynamic> = section.sectionNotes[j];

                        {time: note[0], direction: note[1], length: cast note[2]}
                    }
                ],

                sectionBeats: section.sectionBeats,

                mustHitSection: section.mustHitSection,

                changeBPM: section.changeBPM,

                bpm: section.bpm
            };

            TimingUtil.sort(_section.sectionNotes);

            time += (((1.0 / tempo) * 60.0) * 1000.0) * (Math.round(_section.sectionBeats * 4.0) * 0.25);

            if (_section.changeBPM)
            {
                tempo = _section.bpm;

                output.timeChanges.push({time: time, tempo: tempo, step: 0.0, beat: 0.0, section: 0.0});
            }
        }

        return output;
    }
}

typedef FunkNote = SimpleTimedObject &
{
    var d:Int;

    var l:Float;

    var k:String;
};

typedef FunkEvent = SimpleTimedObject &
{
    var e:String;

    var v:Dynamic;
};

typedef FunkTimeChange = SimpleTimedObject &
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

typedef PsychNote = TimedObject &
{
    var direction:Int;

    var length:Float;
};

typedef PsychEvent = TimedObject &
{
    var name:String;

    var value1:String;

    var value2:String;
};