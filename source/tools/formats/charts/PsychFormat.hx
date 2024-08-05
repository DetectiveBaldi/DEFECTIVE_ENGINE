package tools.formats.charts;

import haxe.Json;

import openfl.net.FileReference;

import core.Song.SimpleEvent;
import core.Song.SimpleNote;
import core.Song.SimpleSong;
import core.Song.SimpleTimeChange;

class PsychFormat
{
    public static function build(chartPath:String):SimpleSong
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

        output.name = cast (chart.song.song, String);

        output.tempo = cast (chart.song.bpm, Float);

        output.speed = cast (chart.song.speed, Float);

        for (i in 0 ... chart.song.notes.length)
        {
            var section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... cast chart.song.notes[i].sectionNotes.length)
                    {
                        {time: cast (chart.song.notes[i].sectionNotes[j][0], Float), direction: cast (chart.song.notes[i].sectionNotes[j][1], Int), length: cast (chart.song.notes[i].sectionNotes[j][2], Float)};
                    }
                ],

                sectionBeats: cast (chart.song.notes[i].sectionBeats, Float),

                mustHitSection: cast (chart.song.notes[i].mustHitSection, Bool),

                changeBPM: cast (chart.song.notes[i].changeBPM, Bool),

                bpm: cast (chart.song.notes[i].bpm, Float)
            };

            for (j in 0 ... section.sectionNotes.length)
            {
                var note:PsychNote = section.sectionNotes[j];

                output.notes.push({time: note.time, speed: 1, direction: note.direction % 4, lane: 1 - Math.floor((section.mustHitSection ? note.direction : (note.direction >= 4) ? note.direction - 4 : note.direction + 4) * 0.25), length: note.length});
            }
        }

        for (i in 0 ... chart.song.events.length)
        {
            for (j in 0 ... chart.song.events[i][1].length)
            {
                output.events.push({time: cast (chart.song.events[i][0], Float), name: cast (chart.song.events[i][1][j][0], String), value: {value1: chart.song.events[i][1][j][1], value2: chart.song.events[i][1][j][2]}});
            }
        }
        
        output.timeChanges.push({time: 0.0, tempo: output.tempo, step: 0.0, beat: 0.0, section: 0.0});

        var time:Float = 0.0;

        var tempo:Float = output.tempo;

        for (i in 0 ... chart.song.notes.length)
        {
            var section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... cast chart.song.notes[i].sectionNotes.length)
                    {
                        {time: cast (chart.song.notes[i].sectionNotes[j][0], Float), direction: cast (chart.song.notes[i].sectionNotes[j][1], Int), length: cast (chart.song.notes[i].sectionNotes[j][2], Float)};
                    }
                ],

                sectionBeats: cast (chart.song.notes[i].sectionBeats, Float),

                mustHitSection: cast (chart.song.notes[i].mustHitSection, Bool),

                changeBPM: cast (chart.song.notes[i].changeBPM, Bool),

                bpm: cast (chart.song.notes[i].bpm, Float)
            };

            if (section.changeBPM)
            {
                output.timeChanges.push({time: time, tempo: section.bpm, step: 0.0, beat: 0.0, section: 0.0});

                tempo = section.bpm;
            }

            time += (((1 / 150) * 60) * 1000.0) * (Math.round(section.sectionBeats * 4.0) * 0.25);
        }

        var fileReference:FileReference = new FileReference();

        fileReference.save(Json.stringify(output), "chart.json");

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