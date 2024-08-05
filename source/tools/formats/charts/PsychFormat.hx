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

        output.name = chart.song.song;

        output.tempo = chart.song.bpm;

        output.speed = chart.song.speed;

        for (i in 0 ... chart.song.notes.length)
        {
            var section:Dynamic = chart.song.notes[i];

            var section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... section.sectionNotes.length)
                    {
                        var note:Array<Dynamic> = section.sectionNotes[j];

                        {time: note[0], direction: note[1], length: note[2] > 0.0 ? note[2] : 0.0};
                    }
                ],

                sectionBeats: section.sectionBeats,

                mustHitSection: section.mustHitSection,

                changeBPM: section.changeBPM,

                bpm: section.bpm
            };

            for (j in 0 ... section.sectionNotes.length)
            {
                var note:PsychNote = section.sectionNotes[j];

                output.notes.push({time: note.time, speed: 1, direction: note.direction % 4, lane: 1 - Math.floor((section.mustHitSection ? note.direction : (note.direction >= 4) ? note.direction - 4 : note.direction + 4) * 0.25), length: note.length});
            }
        }

        for (i in 0 ... chart.song.events.length)
        {
            var event:Array<Dynamic> = chart.song.events[i];

            for (j in 0 ... event[1].length)
            {
                output.events.push({time: event[0], name: event[1][j][0], value: {value1: event[1][j][1], value2: event[1][j][2]}});
            }
        }
        
        output.timeChanges.push({time: 0.0, tempo: output.tempo, step: 0.0, beat: 0.0, section: 0.0});

        var time:Float = 0.0;

        var tempo:Float = chart.song.bpm;

        for (i in 0 ... chart.song.notes.length)
        {
            var section:Dynamic = chart.song.notes[i];

            var section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... section.sectionNotes.length)
                    {
                        var note:Array<Dynamic> = section.sectionNotes[j];

                        {time: note[0], direction: note[1], length: note[2] > 0.0 ? note[2] : 0.0};
                    }
                ],

                sectionBeats: section.sectionBeats,

                mustHitSection: section.mustHitSection,

                changeBPM: section.changeBPM,

                bpm: section.bpm
            };

            if (section.changeBPM)
            {
                output.timeChanges.push({time: time, tempo: section.bpm, step: 0.0, beat: 0.0, section: 0.0});

                tempo = section.bpm;
            }

            time += ((60.0 / tempo) * 1000.0) * ((Math.round(section.sectionBeats * 4.0)) * 0.25);
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