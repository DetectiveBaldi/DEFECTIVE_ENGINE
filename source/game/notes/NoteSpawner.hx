package game.notes;

import haxe.ds.ArraySort;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;

import flixel.group.FlxGroup.FlxTypedGroup;

import core.Conductor;
import core.Options;

import game.Chart;
import game.Chart.LoadedNote;
import game.GameState;

using StringTools;

using util.ArrayUtil;

class NoteSpawner extends FlxBasic
{
    public var game:GameState;

    public var conductor(get, never):Conductor;

    @:noCompletion
    function get_conductor():Conductor
    {
        return game.conductor;
    }

    public var hudCamera(get, never):FlxCamera;

    @:noCompletion
    function get_hudCamera():FlxCamera
    {
        return game.hudCamera;
    }

    public var chart(get, never):Chart;

    @:noCompletion
    function get_chart():Chart
    {
        return game.chart;
    }

    public var notes:FlxTypedGroup<Note>;

    public var noteIndex:Int;

    public function new(game:GameState):Void
    {
        super();

        this.game = game;

        notes = new FlxTypedGroup<Note>();

        noteIndex = 0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        while (noteIndex < chart.notes.length)
        {
            var note:LoadedNote = chart.notes[noteIndex];

            if (note.time > conductor.time + hudCamera.height / hudCamera.zoom / game.chartSpeed / note.speed / 0.45)
                break;

            if (notes.members.length > 0.0)
            {
                var _note:Note = notes.members.last();

                if (note.time == _note.time && note.direction == _note.direction && note.lane == _note.lane && !_note.animation.name.contains("Hold"))
                {
                    noteIndex++;

                    continue;
                }
            }

            var _note:Note = notes.recycle(Note, () -> new Note());

            _note.time = note.time;

            _note.speed = note.speed;

            _note.direction = note.direction;

            _note.lane = note.lane;

            _note.length = note.length;

            _note.animation.play(Note.directions[_note.direction].toLowerCase());

            _note.flipY = false;

            _note.scale.set(0.685, 0.685);

            _note.updateHitbox();

            _note.setPosition((FlxG.width - _note.width) * 0.5, Options.downscroll ? -_note.height : hudCamera.height / hudCamera.zoom);

            var strumLine:StrumLine = game.strumLines.members[note.lane];

            strumLine.notes.add(_note);

            strumLine.onNoteSpawn.dispatch(_note);

            for (k in 0 ... Math.round(_note.length / (((60.0 / conductor.getTimeChange(chart.tempo, _note.time).tempo) * 1000.0) * 0.25)))
            {
                var sustain:Note = notes.recycle(Note, () -> new Note());

                sustain.time = _note.time + ((((60.0 / conductor.getTimeChange(chart.tempo, _note.time).tempo) * 1000.0) * 0.25) * (k + 1.0));

                sustain.speed = _note.speed;

                sustain.direction = _note.direction;
                
                sustain.lane = _note.lane;

                sustain.length = (60.0 / conductor.getTimeChange(chart.tempo, _note.time).tempo) * 1000.0;

                sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldPiece");

                if (k >= Math.round(_note.length / (((60.0 / conductor.getTimeChange(chart.tempo, _note.time).tempo) * 1000.0) * 0.25)) - 1.0)
                    sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldTail");

                sustain.flipY = Options.downscroll;

                sustain.scale.set(0.685, 0.685);

                sustain.updateHitbox();

                sustain.setPosition((FlxG.width - sustain.width) * 0.5, Options.downscroll ? -sustain.height : hudCamera.height / hudCamera.zoom);

                strumLine.notes.add(sustain);
            }

            ArraySort.sort(notes.members, (__note:Note, ___note:Note) -> Std.int(__note.time - ___note.time));

            ArraySort.sort(strumLine.notes.members, (__note:Note, ___note:Note) -> Std.int(__note.time - ___note.time));

            noteIndex++;
        }
    }
}