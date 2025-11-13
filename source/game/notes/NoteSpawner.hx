package game.notes;

import flixel.FlxBasic;
import flixel.FlxG;

import flixel.group.FlxGroup.FlxTypedGroup;

import data.Chart;

import music.Conductor;

using StringTools;

using util.ArrayUtil;

class NoteSpawner extends FlxBasic
{
    public var conductor:Conductor;

    public var noteParams:Array<NoteData>;

    public var strumlines:FlxTypedGroup<Strumline>;

    public var notes:FlxTypedGroup<Note>;

    public var sustains:FlxTypedGroup<Sustain>;

    public var trails:FlxTypedGroup<SustainTrail>;

    public var noteIndex:Int;

    public function new(beatDispatcher:IBeatDispatcher, noteParams:Array<NoteData>, strumlines:FlxTypedGroup<Strumline>):Void
    {
        super();

        visible = false;

        this.conductor = beatDispatcher.conductor;
        
        this.noteParams = noteParams;

        this.strumlines = strumlines;

        notes = new FlxTypedGroup<Note>();

        sustains = new FlxTypedGroup<Sustain>();

        trails = new FlxTypedGroup<SustainTrail>();

        noteIndex = 0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        while (noteIndex < noteParams.length)
        {
            var noteData:NoteData = noteParams[noteIndex];

            var strumline:Strumline = strumlines.members[noteData.lane];

            if (noteData.time > conductor.time + getSpawnDistance(noteData.lane))
                break;

            var note:Note = notes.recycle(Note, noteFactory);

            note.visible = true;
        
            note.time = noteData.time;

            note.direction = noteData.direction;

            note.length = noteData.length;

            note.lane = noteData.lane;

            note.kind = noteData.kind;
            
            note.status = IDLING;

            note.playSplash = false;

            note.unholdTime = 0.0;

            note.sustain = null;

            note.strumline = strumline;

            note.strum = strumline.strums.members[note.direction];

            note.animation.play(Note.DIRECTIONS[note.direction].toLowerCase());

            note.flipY = false;

            note.scale.set(0.7, 0.7);

            note.updateHitbox();

            notes.add(note);

            strumline.notes.add(note);

            strumline.onNoteSpawn.dispatch(note);

            if (noteData.length > 0.0)
            {
                var sustain:Sustain = sustains.recycle(Sustain, sustainFactory);

                sustain.note = note;

                sustain.animation.play(Note.DIRECTIONS[note.direction].toLowerCase() + "HoldPiece");

                sustain.flipY = note.strum.downscroll;

                sustain.setGraphicSize(sustain.frameWidth * 0.7, note.length * strumline.scrollSpeed * 0.45);

                sustain.updateHitbox();

                sustains.add(sustain);

                strumline.sustains.add(sustain);

                note.sustain = sustain;

                var trail:SustainTrail = trails.recycle(SustainTrail, trailFactory);

                trail.sustain = sustain;

                trail.animation.play(Note.DIRECTIONS[note.direction].toLowerCase() + "HoldTail");

                trail.flipY = note.strum.downscroll;

                trail.scale.set(0.7, 0.7);

                trail.updateHitbox();

                trails.add(trail);

                strumline.trails.add(trail);

                sustain.trail = trail;
            }

            noteIndex++;
        }
    }

    public function noteFactory():Note
    {
        return new Note();
    }

    public function sustainFactory():Sustain
    {
        return new Sustain();
    }

    public function trailFactory():SustainTrail
    {
        return new SustainTrail();
    }

    public function getStrumline(lane:Int):Strumline
    {
        return strumlines.members[lane];
    }

    public function getSpawnDistance(lane:Int):Float
    {
        var strumline:Strumline = getStrumline(lane);

        return FlxG.height / 0.45 / Math.max(strumline.scrollSpeed, 1.0);
    }

    public function setNoteIndexAt(time:Float):Void
    {
        noteIndex = 0;
        
        var noteData:NoteData = noteParams[noteIndex];

        while (noteIndex < noteParams.length && noteData.time <= time)
        {
            noteIndex++;
            
            noteData = noteParams[noteIndex];
        }
    }
}