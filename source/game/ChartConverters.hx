package game;

import haxe.Json;

import core.AssetMan;
import core.Paths;

class FunkConverter
{
    public var chartPath:String;

    public var metaPath:String;

    public function new(chartPath:String, metaPath:String):Void
    {
        this.chartPath = chartPath;

        this.metaPath = metaPath;
    }

    public function build(level:String):Chart
    {
        var output:Chart = new Chart();

        var parsedChart:Dynamic = Json.parse(AssetMan.text(Paths.json(chartPath)));

        var parsedMeta:Dynamic = Json.parse(AssetMan.text(Paths.json(metaPath)));

        output.name = parsedMeta.songName;

        output.tempo = parsedMeta.timeChanges[0].bpm;

        output.speed = Reflect.field(parsedChart.scrollSpeed, level);

        for (i in 0 ... Reflect.field(parsedChart.notes, level).length)
        {
            var note:FunkNote = Reflect.field(parsedChart.notes, level)[i];

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
    public var path:String;

    public function new(path:String):Void
    {
        this.path = path;
    }

    public function build():Chart
    {
        var output:Chart = new Chart();

        var parsed:Dynamic = Json.parse(AssetMan.text(Paths.json(path)));

        output.name = parsed.song.song;

        output.tempo = parsed.song.bpm;

        output.speed = parsed.song.speed;

        for (i in 0 ... parsed.song.notes.length)
        {
            var section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... parsed.song.notes[i].sectionNotes.length)
                        {time: cast (parsed.song.notes[i].sectionNotes[j][0], Float), direction: cast (parsed.song.notes[i].sectionNotes[j][1], Int), length: cast (parsed.song.notes[i].sectionNotes[j][2], Float)}
                ],

                sectionBeats: parsed.song.notes[i].sectionBeats,

                mustHitSection: parsed.song.notes[i].mustHitSection,

                changeBPM: parsed.song.notes[i].changeBPM,

                bpm: parsed.song.notes[i].bpm
            };

            for (j in 0 ... section.sectionNotes.length)
            {
                var note:PsychNote = section.sectionNotes[j];

                output.notes.push({time: note.time, speed: 1.0, direction: note.direction % 4, lane: 1 - Math.floor((section.mustHitSection ? note.direction : (note.direction >= 4.0) ? note.direction - 4 : note.direction + 4) * 0.25), length: note.length});
            }
        }

        output.timeChanges.resize(0);
        
        output.timeChanges.push({time: 0.0, tempo: output.tempo, step: 0.0, beat: 0.0, section: 0.0});

        var tempo:Float = output.tempo;

        var time:Float = 0.0;

        for (i in 0 ... parsed.song.notes.length)
        {
            var section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... parsed.song.notes[i].sectionNotes.length)
                        {time: cast (parsed.song.notes[i].sectionNotes[j][0], Float), direction: cast (parsed.song.notes[i].sectionNotes[j][1], Int), length: cast (parsed.song.notes[i].sectionNotes[j][2], Float)}
                ],

                sectionBeats: parsed.song.notes[i].sectionBeats,

                mustHitSection: parsed.song.notes[i].mustHitSection,

                changeBPM: parsed.song.notes[i].changeBPM,

                bpm: parsed.song.notes[i].bpm
            };

            if (section.changeBPM)
            {
                tempo = section.bpm;

                output.timeChanges.push({tempo: tempo, time: time, step: 0.0, beat: 0.0, section: 0.0});
            }
            
            time += (((1.0 / tempo) * 60.0) * 1000.0) * (Math.round(section.sectionBeats * 4.0) * 0.25);
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