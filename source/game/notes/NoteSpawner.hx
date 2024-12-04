package game.notes;

import haxe.ds.ArraySort;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;

import flixel.group.FlxGroup.FlxTypedGroup;

import game.Chart;
import game.Chart.LoadedNote;
import game.GameState;

import music.Conductor;

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

    public var noteHashes:Array<String>;

    public var noteIndex:Int;

    public function new(game:GameState):Void
    {
        super();

        visible = false;

        this.game = game;

        notes = new FlxTypedGroup<Note>();

        noteHashes = new Array<String>();

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

            var hash:String = '${note.time}${note.direction}${note.lane}';

            if (noteHashes.contains(hash))
            {
                noteIndex++;

                continue;
            }

            noteHashes.push(hash);

            var strumLine:StrumLine = game.strumLines.members[note.lane];

            var _note:Note = notes.recycle(Note, () -> new Note());

            _note.time = note.time;

            _note.speed = note.speed;

            _note.direction = note.direction;

            _note.lane = note.lane;

            _note.length = note.length;

            _note.animation.play(Note.directions[_note.direction].toLowerCase());

            _note.flipY = false;

            _note.scale.set(0.7, 0.7);

            _note.updateHitbox();

            _note.setPosition((FlxG.width - _note.width) * 0.5, strumLine.downscroll ? -_note.height : hudCamera.height / hudCamera.zoom);

            strumLine.notes.add(_note);

            strumLine.onNoteSpawn.dispatch(_note);

            var crotchet:Float = (60.0 / conductor.getTimeChange(chart.tempo, _note.time).tempo) * 1000.0;

            for (k in 0 ... Math.round(_note.length / (crotchet * 0.25)))
            {
                var sustain:Note = notes.recycle(Note, () -> new Note());

                sustain.time = _note.time + (crotchet * 0.25 * (k + 1.0));

                sustain.speed = _note.speed;

                sustain.direction = _note.direction;
                
                sustain.lane = _note.lane;

                sustain.length = crotchet;

                sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldPiece");

                if (k >= Math.round(_note.length / (crotchet * 0.25)) - 1.0)
                    sustain.animation.play(Note.directions[sustain.direction].toLowerCase() + "HoldTail");

                sustain.flipY = strumLine.downscroll;

                sustain.scale.set(0.7, 0.7);

                sustain.updateHitbox();

                sustain.setPosition((FlxG.width - sustain.width) * 0.5, strumLine.downscroll ? -sustain.height : hudCamera.height / hudCamera.zoom);

                strumLine.notes.add(sustain);
            }
            
            ArraySort.sort(notes.members, (__note:Note, ___note:Note) -> Std.int(__note.time - ___note.time));

            ArraySort.sort(strumLine.notes.members, (__note:Note, ___note:Note) -> Std.int(__note.time - ___note.time));

            noteIndex++;
        }
    }
}