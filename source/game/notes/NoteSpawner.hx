package game.notes;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;

import core.AssetCache;
import core.Paths;
import data.Chart;
import interfaces.IBeatDispatcher;
import game.notes.types.CautionNote;
import game.notes.types.DeathNote;
import game.notes.types.HurtNote;
import music.Conductor;

using StringTools;

class NoteSpawner extends FlxBasic
{
    public var beatDispatcher:IBeatDispatcher;

    public var conductor(get, never):Conductor;

    @:noCompletion
    function get_conductor():Conductor
    {
        return beatDispatcher?.conductor;
    }

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

        this.beatDispatcher = beatDispatcher;
        
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

            var spawnDistanceMs:Float = camera.height / 0.45 / Math.max(1.0, strumline.scrollSpeed);

            if (noteData.time > conductor.time + spawnDistanceMs)
                break;

            var note:Note = null;

            for (i in 0 ... notes.members.length)
            {
                var loopNote:Note = notes.members[i];

                if (!loopNote.exists && noteData.kind.type == loopNote.kind.type)
                {
                    note = loopNote;

                    break;
                }
            }

            if (note == null)
                note = noteFactory();

            note.data = noteData;

            note.revive();

            note.strumline = strumline;

            notes.remove(note, true);
            
            notes.add(note);

            strumline.notes.add(note);

            strumline.onNoteSpawn.dispatch(note);

            if (note.length > 0.0)
            {
                var sustain:Sustain = null;

                for (i in 0 ... sustains.members.length)
                {
                    var loopSustain:Sustain = sustains.members[i];

                    if (!loopSustain.exists && note.frames.parent == loopSustain.frames.parent)
                    {
                        sustain = loopSustain;
                        
                        break;
                    }
                }

                if (sustain == null)
                    sustain = sustains.recycle(null, sustainFactory);

                sustain.frames = note.frames;

                sustain.addAnimations();

                sustain.revive();

                sustain.note = note;

                sustains.remove(sustain, true);

                sustains.add(sustain);

                strumline.sustains.add(sustain);

                note.sustain = sustain;

                var trail:SustainTrail = null;

                for (i in 0 ... trails.members.length)
                {
                    var loopTrail:SustainTrail = trails.members[i];

                    if (!loopTrail.exists && sustain.frames.parent == loopTrail.frames.parent)
                    {
                        trail = loopTrail;

                        break;
                    }
                }

                if (trail == null)
                    trail = trails.recycle(null, trailFactory);

                trail.frames = sustain.frames;

                trail.addAnimations();

                trail.revive();

                trail.flipY = strumline.downscroll;

                trail.note = note;

                trails.remove(trail, true);

                trails.add(trail);

                strumline.trails.add(trail);

                note.trail = trail;
            }

            noteIndex++;
        }
    }

    public function resolveNoteClass(noteData:NoteData):Class<Note>
    {
        return switch (noteData.kind.type:String)
        {
            case "caution":
                CautionNote;

            case "death":
                DeathNote;

            case "hurt":
                HurtNote;

            default:
                Note;
        }
    }

    public function noteFactory():Note
    {
        var noteData:NoteData = noteParams[noteIndex];

        var noteClass:Class<Note> = resolveNoteClass(noteData);

        return switch (noteClass:Class<Note>)
        {
            case CautionNote:
                new CautionNote(beatDispatcher, noteData);

            case DeathNote:
                new DeathNote(beatDispatcher, noteData);
            
            case HurtNote:
                new HurtNote(beatDispatcher, noteData);

            default:
                new Note(beatDispatcher, noteData);
        }
    }

    public function sustainFactory():Sustain
    {
        return new Sustain();
    }

    public function trailFactory():SustainTrail
    {
        return new SustainTrail();
    }
}