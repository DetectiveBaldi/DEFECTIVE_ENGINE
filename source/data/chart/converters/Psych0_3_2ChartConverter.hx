package data.chart.converters;

import haxe.Json;

import openfl.utils.Assets;

import core.Paths;
import data.Chart;
import data.chart.NoteTypeSwaps;
import tools.TimeSortTools;

using StringTools;

class Psych0_3_2ChartConverter
{
    static var _noteTypeSwaps:Map<String, String> = null;

    public static var noteTypeSwaps(get, never):Map<String, String>;

    @:noCompletion
    static function get_noteTypeSwaps():Map<String, String>
    {
        if (_noteTypeSwaps == null)
            _noteTypeSwaps = NoteTypeSwaps.buildFromFile(Paths.data(Paths.json("data/chart/converters/Psych0_3_2ChartConverter/note-type-swaps")));

        return _noteTypeSwaps;
    }

    public static function buildFromFiles(chartPath:String, eventsPath:String):Chart
    {
        var output:Chart = new Chart();

        var raw:Dynamic = Json.parse(Assets.getText(chartPath));

        var rawEvents:Dynamic = null;

        if (Paths.exists(eventsPath))
            rawEvents = Json.parse(Assets.getText(eventsPath));
        
        raw = raw.song;

        var section:Dynamic = raw.notes[0];

        output.name = raw.song;
        
        var time:Float = 0.0;

        var tempo:Float = raw.bpm;

        var beatsPerMeasure:Int = section.sectionBeats ?? 4;

        output.timingPoints.push({time: 0.0, tempo: tempo, beatsPerMeasure: beatsPerMeasure});

        var mania:Int = raw.mania;

        var keyCount:Int = 4;

        if (mania == 1)
            keyCount = 6;

        if (mania == 2)
            keyCount = 7;

        if (mania == 3)
            keyCount = 9;

        output.keyCount = keyCount;

        output.scrollSpeed = raw.speed;

        var character:String = "";

        for (i in 0 ... raw.notes.length)
        {
            section = raw.notes[i];

            var _section:Psych0_3_2Section =
            {
                sectionNotes:
                [
                    for (j in 0 ... section.sectionNotes.length)
                    {
                        var note:Array<Dynamic> = section.sectionNotes[j];

                        {time: note[0], direction: note[1], length: note[2], type: note[3]}
                    }
                ],

                lengthInSteps: section.lengthInSteps ?? 16,

                typeOfSection: section.typeOfSection,

                mustHitSection: section.mustHitSection,

                bpm: section.bpm,

                changeBPM: section.changeBPM,

                altAnim: section.altAnim
            };

            character = _section.mustHitSection ? "player" : "opponent";

            output.events.push({time: time, name: "SetCamFocus", value: {x: 0.0, y: 0.0, charType: character,
                duration: -1.0, ease: "linear"}});

            var beatLength:Float = 60.0 / tempo * 1000.0;

            if (_section.changeBPM)
            {
                tempo = _section.bpm;

                beatLength = 60.0 / tempo * 1000.0;

                output.timingPoints.push({time: time, tempo: tempo, beatsPerMeasure: Math.round(_section.lengthInSteps * 0.25)});
            }

            time += beatLength * (_section.lengthInSteps * 0.25);

            for (j in 0 ... _section.sectionNotes.length)
            {
                var note:Psych0_3_2Note = _section.sectionNotes[j];

                var type:String = Std.string(note.type);

                if (noteTypeSwaps.exists(type))
                    type = noteTypeSwaps[type];
                else
                    type = "";

                var kind:NoteKindData = {type: type, altAnimation: false, noAnimation: false, specSing: false, charIds: null}

                if (_section.altAnim || type == "1")
                    kind.altAnimation = true;

                output.notes.push({time: note.time, direction: note.direction % keyCount,  lane: ((note.direction > keyCount - 1)
                    ? !_section.mustHitSection : _section.mustHitSection) ? 1 : 0, length: Math.max(note.length - beatLength * 0.25, 0.0), kind: kind});
            }
        }

        output.spectator = raw.player3;

        output.opponent = raw.player2;

        output.player = raw.player1;

        return output;
    }
}

typedef Psych0_3_2Section =
{
    var sectionNotes:Array<Psych0_3_2Note>;

    var lengthInSteps:Float;

    var typeOfSection:Int;

    var mustHitSection:Bool;

    var changeBPM:Bool;

    var bpm:Float;

    var altAnim:Bool;
};

typedef Psych0_3_2Event = TimedObject &
{
    var name:String;

    var value1:String;

    var value2:String;
};

typedef Psych0_3_2Note = TimedObject &
{
    var direction:Int;

    var length:Float;

    var type:Int;
};