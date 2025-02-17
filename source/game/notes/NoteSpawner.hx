package game.notes;

import flixel.FlxBasic;

import flixel.group.FlxGroup.FlxTypedGroup;

import data.Chart;
import data.Chart.RawNote;

import music.Conductor;

using StringTools;

using util.ArrayUtil;

class NoteSpawner extends FlxBasic
{
    public var conductor:Conductor;

    public var chart:Chart;

    public var strumlines:FlxTypedGroup<Strumline>;

    public var notes:FlxTypedGroup<Note>;

    public var sustains:FlxTypedGroup<Sustain>;

    public var trails:FlxTypedGroup<SustainTrail>;

    public var noteIndex:Int;

    public function new(_conductor:Conductor, _chart:Chart, _strumlines:FlxTypedGroup<Strumline>):Void
    {
        super();

        visible = false;

        conductor = _conductor;
        
        chart = _chart;

        strumlines = _strumlines;

        notes = new FlxTypedGroup<Note>();

        sustains = new FlxTypedGroup<Sustain>();

        trails = new FlxTypedGroup<SustainTrail>();

        noteIndex = 0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        while (noteIndex < chart.notes.length)
        {
            var note:RawNote = chart.notes[noteIndex];

            var strumline:Strumline = strumlines.members[note.lane];

            if (note.time - conductor.time > 1500.0 / strumline.scrollSpeed)
                break;

            var _note:Note = notes.recycle(Note, noteConstructor);

            _note.visible = true;
        
            _note.time = note.time;

            _note.direction = note.direction;

            _note.length = note.length;

            _note.lane = note.lane;
            
            _note.status = IDLING;

            _note.showPop = false;

            _note.finishedHold = false;

            _note.unholdTime = 0.0;

            _note.sustain = null;

            _note.strumline = strumline;

            _note.strum = strumline.strums.members[_note.direction];

            _note.animation.play(Note.DIRECTIONS[_note.direction].toLowerCase());

            _note.flipY = false;

            _note.scale.set(0.7, 0.7);

            _note.updateHitbox();

            _note.setPosition(camera.viewMarginRight, 0.0);

            notes.add(_note);

            strumline.notes.add(_note);

            strumline.onNoteSpawn.dispatch(_note);

            if (note.length > 0.0)
            {
                var sustain:Sustain = sustains.recycle(Sustain, sustainConstructor);

                sustain.note = _note;

                sustain.animation.play(Note.DIRECTIONS[_note.direction].toLowerCase() + "HoldPiece");

                sustain.flipY = strumline.downscroll;

                sustain.setGraphicSize(sustain.frameWidth * 0.7, _note.length * strumline.scrollSpeed * 0.45);

                sustain.updateHitbox();

                sustain.setPosition(camera.viewMarginRight, 0.0);

                sustains.add(sustain);

                strumline.sustains.add(sustain);

                _note.sustain = sustain;

                var trail:SustainTrail = trails.recycle(SustainTrail, trailConstructor);

                trail.sustain = sustain;

                trail.animation.play(Note.DIRECTIONS[_note.direction].toLowerCase() + "HoldTail");

                trail.flipY = strumline.downscroll;

                trail.scale.set(0.7, 0.7);

                trail.updateHitbox();

                trail.setPosition(camera.viewMarginRight, 0.0);

                trails.add(trail);

                strumline.trails.add(trail);

                sustain.trail = trail;
            }

            noteIndex++;
        }
    }

    public function noteConstructor():Note
    {
        return new Note();
    }

    public function sustainConstructor():Sustain
    {
        return new Sustain();
    }

    public function trailConstructor():SustainTrail
    {
        return new SustainTrail();
    }
}