package data;

import haxe.Json;

import openfl.utils.Assets;

import flixel.util.FlxStringUtil;

import data.Chart;

import util.TimingUtil;

using StringTools;

using util.ArrayUtil;
using util.MathUtil;

class FunkinConverter
{
    public static function run(chartPath:String, metadataPath:String, difficulty:String):Chart
    {
        var output:Chart = new Chart();

        var rawMeta:Dynamic = Json.parse(Assets.getText(metadataPath));

        output.name = rawMeta.songName;

        var rawChart:Dynamic = Json.parse(Assets.getText(chartPath));

        output.scrollSpeed = Reflect.field(rawChart.scrollSpeed, difficulty);

        var events:Array<FunkinEvent> = rawChart.events;

        for (i in 0 ... events.length)
        {
            var ev:FunkinEvent = events[i];

            if (ev.e == "FocusCamera")
            {
                var charType:String = "";

                var charTypeInt:Int = ev.v.char ?? -1;

                if (charTypeInt == 0.0)
                    charType == "player";

                if (charTypeInt == 1.0)
                    charType == "opponent";

                if (charTypeInt == 2.0)
                    charType == "spectator";

                var x:Float = ev.v.x ?? 0.0;

                var y:Float = ev.v.y ?? 0.0;

                var duration:Float = ev.v.duration ?? 4.0;

                var ease:String = ev.v.ease ?? "classic";

                if (ease == "INSTANT")
                    duration = 0.0;

                if (ease == "classic")
                    duration = -1.0;

                output.events.push({time: ev.t, name: "SetCamFocus", value: {x: x, y: y, charType: charType, duration: duration,
                    ease: ease}});
            }
        }

        var notes:Array<FunkinNote> = Reflect.field(rawChart.notes, difficulty);
        
        for (i in 0 ... notes.length)
        {
            var note:FunkinNote = notes[i];

            var kind:NoteKindData = {type: note.k, altAnimation: false, noAnimation: false, specSing: false, charIds: null}

            output.notes.push({time: note.t, direction: note.d % 4, lane: 1 - Math.floor(note.d * 0.25), length: note.l,
                kind: kind});
        }

        var timingPoints:Array<FunkinTimingPoint> = rawMeta.timeChanges;

        for (i in 0 ... timingPoints.length)
        {
            var timeChange:FunkinTimingPoint = timingPoints[i];

            output.timingPoints.push({time: timeChange.t, tempo: timeChange.bpm, beatsPerMeasure: timeChange.n});
        }

        var characters:Dynamic = rawMeta.playData.characters;

        output.spectator = characters.girlfriend;

        output.opponent = characters.opponent;

        output.player = characters.player;

        return output;
    }
}

class PsychConverter
{
    public static function run(chartPath:String):Chart
    {
        var output:Chart = new Chart();

        var raw:Dynamic = Json.parse(Assets.getText(chartPath));

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

                changeBPM: section.changeBPM,

                bpm: section.bpm
            };

            character = _section.mustHitSection ? "player" : "opponent";

            if (_section.gfSection)
                character = "spectator";
            
            output.events.push({time: time, name: "SetCamFocus", value: {x: 0.0, y: 0.0, charType: character,
                duration: -1.0, ease: "linear"}});

            var beatLength:Float = (60.0 / tempo * 1000.0);

            if (_section.changeBPM)
            {
                tempo = _section.bpm;

                beatLength = (60.0 / tempo * 1000.0);

                output.timingPoints.push({time: time, tempo: tempo, beatsPerMeasure: Math.round(_section.sectionBeats)});
            }

            time += beatLength * _section.sectionBeats;

            for (j in 0 ... _section.sectionNotes.length)
            {
                var note:PsychNote = _section.sectionNotes[j];

                var type:String = note.type ?? "";

                var kind:NoteKindData = {type: "", altAnimation: false, noAnimation: false, specSing: false, charIds: null}

                if (type == "Alt Animation")
                    kind.altAnimation = true;

                if (_section.altAnim || type == "No Animation")
                    kind.noAnimation = true;

                if (_section.gfSection || type == "GF Sing")
                    kind.specSing = true;

                if (type.startsWith("mamacitas-char-id"))
                {
                    var charIds:Array<Int> = new Array<Int>();

                    var commas:String = type.split("-").last();

                    var ids:Array<Int> = FlxStringUtil.toIntArray(commas);

                    for (i in 0 ... ids.length)
                        charIds.push(ids[i]);

                    kind.charIds = charIds;
                }

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

typedef FunkinTimedObject =
{
    var t:Float;
}

typedef FunkinEvent = FunkinTimedObject &
{
    var e:String;

    var v:Dynamic;
};

typedef FunkinNote = FunkinTimedObject &
{
    var d:Int;

    var l:Float;

    var k:String;
};

typedef FunkinTimingPoint = FunkinTimedObject &
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

    var altAnim:Bool;

    var gfSection:Bool;

    var changeBPM:Bool;

    var bpm:Float;
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