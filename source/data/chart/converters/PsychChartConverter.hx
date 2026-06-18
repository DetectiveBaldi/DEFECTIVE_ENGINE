package data.chart.converters;

import haxe.Json;

import openfl.utils.Assets;

import flixel.util.FlxStringUtil;

import core.Paths;

import data.Chart;

import util.TimingUtil;

using StringTools;

using util.ArrayUtil;

class PsychChartConverter
{
    public static function buildFromFiles(chartPath:String, eventsPath:String):Chart
    {
        var output:Chart = new Chart();

        var raw:Dynamic = Json.parse(Assets.getText(chartPath));

        var rawEvents:Dynamic = null;

        if (Paths.exists(eventsPath))
            rawEvents = Json.parse(Assets.getText(eventsPath));

        var section:Dynamic = raw.notes[0];

        output.name = raw.song;

        output.scrollSpeed = raw.speed;
        
        var time:Float = 0.0;

        var tempo:Float = raw.bpm;

        var beatsPerMeasure:Int = section.sectionBeats ?? 4;

        output.timingPoints.push({time: 0.0, tempo: tempo, beatsPerMeasure: beatsPerMeasure});

        var character:String = "";

        for (i in 0 ... raw.notes.length)
        {
            section = raw.notes[i];

            var _section:PsychSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... section.sectionNotes.length)
                    {
                        var note:Array<Dynamic> = section.sectionNotes[j];

                        {time: note[0], direction: note[1], length: note[2], type: note[3]}
                    }
                ],

                sectionBeats: section.sectionBeats,

                mustHitSection: section.mustHitSection,

                altAnim: section.altAnim,

                gfSection: section.gfSection,

                bpm: section.bpm,

                changeBPM: section.changeBPM,
            };

            character = _section.mustHitSection ? "player" : "opponent";

            output.events.push({time: time, name: "SetCamFocus", value: {x: 0.0, y: 0.0, charType: character,
                duration: -1.0, ease: "linear"}});

            var beatLength:Float = 60.0 / tempo * 1000.0;

            if (_section.changeBPM)
            {
                tempo = _section.bpm;

                beatLength = 60.0 / tempo * 1000.0;

                output.timingPoints.push({time: time, tempo: tempo, beatsPerMeasure: Math.round(_section.sectionBeats)});
            }

            time += beatLength * _section.sectionBeats;

            for (j in 0 ... _section.sectionNotes.length)
            {
                var note:PsychNote = _section.sectionNotes[j];

                var type:String = note.type ?? "";

                var kind:NoteKindData = {type: note.type, altAnimation: false, noAnimation: false, specSing: false, charIds: null}

                if (_section.altAnim || type == "Alt Animation")
                    kind.altAnimation = true;

                if (type == "No Animation")
                    kind.noAnimation = true;

                if (_section.gfSection || type == "GF Sing")
                    kind.specSing = true;

                output.notes.push({time: note.time, direction: note.direction % 4, lane: 1 - Math.floor(note.direction * 0.25),
                    length: Math.max(note.length - beatLength * 0.25, 0.0), kind: kind});
            }
        }

        output.spectator = raw.gfVersion;

        output.opponent = raw.player2;

        output.player = raw.player1;

        return output;
    }
}

typedef PsychSection =
{
    var sectionNotes:Array<PsychNote>;

    var sectionBeats:Float;

    var mustHitSection:Bool;

    var altAnim:Bool;

    var gfSection:Bool;

    var bpm:Float;

    var changeBPM:Bool;
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

    var type:String;
};