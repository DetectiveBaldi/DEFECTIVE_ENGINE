package data.chart.converters;

import haxe.Json;

import openfl.utils.Assets;

import flixel.util.FlxStringUtil;

import core.Paths;

import data.Chart;

import util.TimingUtil;

using StringTools;

using util.ArrayUtil;

class FNFChartCoverter
{
    public static function buildFromFiles(chartPath:String, metadataPath:String, difficulty:String):Chart
    {
        var output:Chart = new Chart();

        var rawMeta:Dynamic = Json.parse(Assets.getText(metadataPath));

        output.name = rawMeta.songName;

        var rawChart:Dynamic = Json.parse(Assets.getText(chartPath));

        output.scrollSpeed = Reflect.field(rawChart.scrollSpeed, difficulty);

        var events:Array<FNFEvent> = rawChart.events;

        for (i in 0 ... events.length)
        {
            var ev:FNFEvent = events[i];

            if (ev.e == "FocusCamera")
            {
                var charType:String = "";

                var charTypeInt:Int = ev.v.char ?? -1;

                if (charTypeInt == 0)
                    charType = "player";

                if (charTypeInt == 1)
                    charType = "opponent";

                if (charTypeInt == 2)
                    charType = "spectator";

                var x:Float = ev.v.x ?? 0.0;

                var y:Float = ev.v.y ?? 0.0;

                var duration:Float = ev.v.duration ?? 4.0;

                var ease:String = ev.v.ease ?? "CLASSIC";

                ease = concatenateEase(ease, ev.v.easeDir);

                if (ease == "INSTANT")
                    duration = 0.0;

                if (ease == "CLASSIC")
                    duration = -1.0;

                output.events.push({time: ev.t, name: "SetCamFocus", value: {x: x, y: y, charType: charType, duration: duration,
                    ease: ease}});
            }

            if (ev.e == "ZoomCamera")
            {
                var zoom:Float = ev.v.zoom ?? 1.0;

                var duration:Float = ev.v.duration ?? 4.0;

                var mode:String = ev.v.mode ?? "direct";

                var ease:String = concatenateEase(ev.v.ease, ev.v.easeDir);

                if (ease == "INSTANT")
                    duration = 0.0;

                // I'm going to be honest, the way FNF' does this event is really stupid so there's several components of
                    // this event that just aren't parsed.

                output.events.push({time: ev.t, name: "SetCamZoom", value: {zoom: zoom, duration: duration, mode: mode, ease: ease}});
            }
        }

        var notes:Array<FNFNote> = Reflect.field(rawChart.notes, difficulty);
        
        for (i in 0 ... notes.length)
        {
            var note:FNFNote = notes[i];

            var kind:NoteKindData = {type: note.k, altAnimation: false, noAnimation: false, specSing: false, charIds: null}

            output.notes.push({time: note.t, direction: note.d % 4, lane: 1 - Math.floor(note.d * 0.25), length: note.l,
                kind: kind});
        }

        var timingPoints:Array<FNFTimingPoint> = rawMeta.timeChanges;

        for (i in 0 ... timingPoints.length)
        {
            var timeChange:FNFTimingPoint = timingPoints[i];

            output.timingPoints.push({time: timeChange.t, tempo: timeChange.bpm, beatsPerMeasure: timeChange.n});
        }

        var characters:Dynamic = rawMeta.playData.characters;

        output.spectator = characters.girlfriend;

        output.opponent = characters.opponent;

        output.player = characters.player;

        return output;
    }

    public static function concatenateEase(ease:String, easeDir:String):String
    {
        ease ??= "linear";

        if (ease == "linear" || ease.contains("In") || ease.contains("Out") || ease.contains("InOut"))
        {
            // Ignore easeDir
        }
        else
        {
            easeDir ??= "In";

            ease += easeDir;
        }

        return ease;
    }
}

typedef FNFTimedObject =
{
    var t:Float;
}

typedef FNFEvent = FNFTimedObject &
{
    var e:String;

    var v:Dynamic;
};

typedef FNFNote = FNFTimedObject &
{
    var d:Int;

    var l:Float;

    var k:String;
};

typedef FNFTimingPoint = FNFTimedObject &
{
    var b:Float;

    var bpm:Float;

    var n:Int;

    var d:Int;

    var bt:Array<Int>;
};