package data.chart.converters;

import haxe.Json;

import openfl.utils.Assets;

import core.Paths;
import data.Chart;
import data.chart.NoteTypeSwaps;
import tools.TimeSortTools;

using StringTools;

class LeatherChartConverter
{
    static var _noteTypeSwaps:Map<String, String> = null;

    public static var noteTypeSwaps(get, never):Map<String, String>;

    @:noCompletion
    static function get_noteTypeSwaps():Map<String, String>
    {
        if (_noteTypeSwaps == null)
            _noteTypeSwaps = NoteTypeSwaps.buildFromFile(Paths.data(Paths.json("data/chart/converters/LeatherChartConverter/note-type-swaps")));

        return _noteTypeSwaps;
    }

    public static function buildFromFiles(chartPath:String, eventsPath:String):Chart
    {
        var output:Chart = new Chart();

        var raw:Dynamic = Json.parse(Assets.getText(chartPath));

        var rawEvents:Dynamic = null;

        if (Paths.exists(eventsPath))
            rawEvents = Json.parse(Assets.getText(eventsPath));

        // Less typing
        raw = raw.song;

        var section:Dynamic = raw.notes[0];

        output.name = raw.song;

        output.scrollSpeed = raw.speed;
        
        var time:Float = 0.0;

        var tempo:Float = raw.bpm;

        var beatsPerMeasure:Int = section.sectionBeats ?? 4;

        output.timingPoints.push({time: 0.0, tempo: tempo, beatsPerMeasure: beatsPerMeasure});

        var keyCount:Int = raw.keyCount;
        
        output.keyCount = keyCount;

        var character:String = "";

        for (i in 0 ... raw.notes.length)
        {
            section = raw.notes[i];

            var _section:LeatherSection =
            {
                sectionNotes:
                [
                    for (j in 0 ... section.sectionNotes.length)
                    {
                        var note:Array<Dynamic> = section.sectionNotes[j];

                        {time: note[0], direction: note[1], length: note[2], charIds: note[3], type: note[4]}
                    }
                ],

                lengthInSteps: section.lengthInSteps ?? 16,

                typeOfSection: section.typeOfSection,

                mustHitSection: section.mustHitSection,

                bpm: section.bpm,

                changeBPM: section.changeBPM,

                altAnim: section.altAnim,

                timeScale: section.timeScale,

                changeTimeScale: section.changeTimeScale
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
                var note:LeatherNote = _section.sectionNotes[j];

                var type:String = note.type;

                var typeLower:String = type?.toLowerCase();

                if (typeLower == "caution" || typeLower == "death" || typeLower == "hurt")
                    type = typeLower;
                else
                {
                    if (noteTypeSwaps.exists(type))
                        type = noteTypeSwaps[type];
                    else
                        type = "";
                }

                var kind:NoteKindData = {type: type, altAnimation: false, noAnimation: false, specSing: false, charIds: null}

                if (note.charIds != null)
                {
                    kind.charIds = new Array<Int>();
                    
                    if (note.charIds is Int)
                        kind.charIds.push(note.charIds);
                    else
                        kind.charIds = note.charIds;
                }

                if (_section.altAnim)
                    kind.altAnimation = true;

                output.notes.push({time: note.time, direction: note.direction % keyCount,  lane: ((note.direction > keyCount - 1)
                    ? !_section.mustHitSection : _section.mustHitSection) ? 1 : 0, length: Math.max(note.length - beatLength * 0.25, 0.0), kind: kind});
            }
        }

        output.spectator = raw.gf;

        output.opponent = raw.player2;

        output.player = raw.player1;

        return output;
    }
}

typedef LeatherSection =
{
    var sectionNotes:Array<LeatherNote>;

    var lengthInSteps:Float;

    var typeOfSection:Int;

    var mustHitSection:Bool;

    var changeBPM:Bool;

    var bpm:Float;

    var altAnim:Bool;

    var timeScale:Array<Int>;

    var changeTimeScale:Bool;
};

typedef LeatherEvent = TimedObject &
{
    var name:String;

    var value1:String;

    var value2:String;
};

typedef LeatherNote = TimedObject &
{
    var direction:Int;

    var length:Float;

    var charIds:Dynamic;

    var type:String;
};