package tools.formats.charts;

import haxe.Json;

import core.AssetManager;

import tools.formats.charts.StandardFormat.StandardEvent;
import tools.formats.charts.StandardFormat.StandardNote;
import tools.formats.charts.StandardFormat.StandardSong;
import tools.formats.charts.StandardFormat.StandardTimeChange;

class PsychFormat
{
    public static function build(chartPath:String):StandardSong
    {
        var output:StandardSong =
        {
            name: "Test",

            tempo: 150.0,

            speed: 1.0,

            notes: new Array<StandardNote>(),

            events: new Array<StandardEvent>(),

            timeChanges: new Array<StandardTimeChange>()
        };

        var chart:Dynamic = Json.parse(AssetManager.text(chartPath));

        output.name = chart.song.song;

        output.tempo = chart.song.bpm;

        output.speed = chart.song.speed;

        for (i in 0 ... chart.song.notes.length)
        {
            var section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... chart.song.notes[i].sectionNotes.length)
                    {
                        {time: cast (chart.song.notes[i].sectionNotes[j][0], Float), direction: cast (chart.song.notes[i].sectionNotes[j][1], Int), length: cast (chart.song.notes[i].sectionNotes[j][2], Float)};
                    }
                ],

                sectionBeats: chart.song.notes[i].sectionBeats,

                mustHitSection: chart.song.notes[i].mustHitSection,

                changeBPM: chart.song.notes[i].changeBPM,

                bpm: chart.song.notes[i].bpm
            };

            for (j in 0 ... section.sectionNotes.length)
            {
                var note:PsychNote = section.sectionNotes[j];

                output.notes.push({time: note.time, speed: 1.0, direction: note.direction % 4, lane: 1 - Math.floor((section.mustHitSection ? note.direction : (note.direction >= 4.0) ? note.direction - 4 : note.direction + 4) * 0.25), length: note.length});
            }
        }

        for (i in 0 ... chart.song.events.length)
        {
            for (j in 0 ... chart.song.events[i][1].length)
            {
                var event:PsychEvent = {time: cast (chart.song.events[i][0], Float), name: cast (chart.song.events[i][1][j][0], String), value1: cast (chart.song.events[i][1][j][1], String), value2: cast (chart.song.events[i][1][j][2], String)};

                output.events.push({time: event.time, name: event.name, value: {value1: event.value1, value2: event.value2}});
            }
        }
        
        output.timeChanges.push({time: 0.0, tempo: output.tempo, step: 0.0, beat: 0.0, section: 0.0});

        var tempo:Float = output.tempo;

        var time:Float = 0.0;

        for (i in 0 ... chart.song.notes.length)
        {
            var section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... chart.song.notes[i].sectionNotes.length)
                    {
                        {time: cast (chart.song.notes[i].sectionNotes[j][0], Float), direction: cast (chart.song.notes[i].sectionNotes[j][1], Int), length: cast (chart.song.notes[i].sectionNotes[j][2], Float)};
                    }
                ],

                sectionBeats: chart.song.notes[i].sectionBeats,

                mustHitSection: chart.song.notes[i].mustHitSection,

                changeBPM: chart.song.notes[i].changeBPM,

                bpm: chart.song.notes[i].bpm
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