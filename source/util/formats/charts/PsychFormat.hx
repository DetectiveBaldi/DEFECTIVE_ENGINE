package util.formats.charts;

import haxe.Json;

import core.AssetMan;
import core.Chart;

class PsychFormat
{
    public static function build(path:String):Chart
    {
        var output:Chart = new Chart();

        var parsed:Dynamic = Json.parse(AssetMan.text(path));

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

        for (i in 0 ... parsed.song.events.length)
        {
            for (j in 0 ... parsed.song.events[i][1].length)
            {
                var event:PsychEvent = {time: cast (parsed.song.events[i][0], Float), name: cast (parsed.song.events[i][1][j][0], String), value1: cast (parsed.song.events[i][1][j][1], String), value2: cast (parsed.song.events[i][1][j][2], String)};
                
                output.events.push({time: event.time, name: event.name, value: {value1: event.value1, value2: event.value2}});
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