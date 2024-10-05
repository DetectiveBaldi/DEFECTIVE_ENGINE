package game;

import haxe.Json;

import core.AssetMan;
import core.Paths;

class FunkConverter
{
    public static function build(chartPath:String, metaPath:String, difficulty:String):Chart
    {
        var output:Chart = new Chart();

        var parsedChart:Dynamic = Json.parse(AssetMan.text(Paths.json(chartPath)));

        var parsedMeta:Dynamic = Json.parse(AssetMan.text(Paths.json(metaPath)));

        output.name = parsedMeta.songName;

        output.tempo = parsedMeta.timeChanges[0].bpm;

        output.speed = Reflect.field(parsedChart.scrollSpeed, difficulty);

        var notes:Array<FunkNote> = Reflect.field(parsedChart.notes, difficulty);

        for (i in 0 ... notes.length)
        {
            var note:FunkNote = notes[i];

            output.notes.push({time: note.t, speed: 1.0, direction: note.d % 4, lane: 1 - Math.floor(note.d * 0.25), length: note.l});
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

            for (j in 0 ... _section.sectionNotes.length)
            {
                var note:PsychNote = _section.sectionNotes[j];

                output.notes.push({time: note.time, speed: 1.0, direction: note.direction % 4, lane: 1 - Math.floor((_section.mustHitSection ? note.direction : (note.direction >= 4.0) ? note.direction - 4 : note.direction + 4) * 0.25), length: note.length});
            }
        }

        output.timeChanges.resize(0);
        
        output.timeChanges.push({time: 0.0, tempo: output.tempo, step: 0.0, beat: 0.0, section: 0.0});

        var tempo:Float = output.tempo;

        var time:Float = 0.0;

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

            if (_section.changeBPM)
            {
                tempo = _section.bpm;

                output.timeChanges.push({tempo: tempo, time: time, step: 0.0, beat: 0.0, section: 0.0});
            }
            
            time += (((1.0 / tempo) * 60.0) * 1000.0) * (Math.round(_section.sectionBeats * 4.0) * 0.25);
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

typedef PsychSection =
{
    var sectionNotes:Array<PsychNote>;

    var sectionBeats:Float;

    var mustHitSection:Bool;

    var changeBPM:Bool;

    var bpm:Float;
};

typedef PsychNote =
{
    var time:Float;

    var direction:Int;

    var length:Float;
};

typedef PsychEvent =
{
    var time:Float;

    var name:String;

    var value1:String;

    var value2:String;
};