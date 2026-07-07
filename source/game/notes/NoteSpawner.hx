package game.notes;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;

import core.AssetCache;
import core.Paths;
import data.Chart;
import interfaces.IBeatDispatcher;
import music.Conductor;

using StringTools;

using util.ArrayUtil;

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

            if (noteData.time > conductor.time + getSpawnDistance(strumline))
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

            var needNewType:Bool = false;

            if (note == null)
            {
                note = notes.recycle(null, noteFactory, false, false);

                needNewType = true;
            }

            note.reset(FlxG.width, FlxG.height);

            note.visible = true;
        
            note.time = noteData.time;

            note.direction = noteData.direction;

            note.length = noteData.length;

            note.lane = noteData.lane;

            note.kind = noteData.kind;

            if (needNewType)
            {
                note.frames = note.getNoteFrames();

                note.addAnimations();
            }

            note.animation.play(strumline.convertDirectionToAnim(note.direction).toLowerCase());

            note.strumline = strumline;
            
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

                needNewType = false;

                if (sustain == null)
                {
                    sustain = sustains.recycle(null, sustainFactory, false, false);

                    needNewType = true;
                }

                sustain.reset(FlxG.width, FlxG.height);

                if (needNewType)
                {
                    sustain.frames = note.frames;

                    sustain.addAnimations();
                }

                sustain.flipY = strumline.downscroll;

                sustain.animation.play('${note.animation.name}HoldPiece');

                sustain.note = note;

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

                needNewType = false;

                if (trail == null)
                {
                    trail = trails.recycle(null, trailFactory, false, false);

                    needNewType = true;
                }

                trail.reset(FlxG.width, FlxG.height);

                if (needNewType)
                {
                    trail.frames = sustain.frames;

                    trail.addAnimations();
                }

                trail.animation.play('${note.animation.name}HoldTail');

                trail.flipY = strumline.downscroll;

                trail.note = note;

                trails.add(trail);

                strumline.trails.add(trail);

                note.trail = trail;
            }

            setNoteType(note);

            noteIndex++;
        }
    }

    public function getSpawnDistance(strumline:Strumline):Float
    {
        return FlxG.height / 0.45 / Math.max(1.0, strumline.scrollSpeed);
    }

    public function noteFactory():Note
    {
        return new Note(beatDispatcher);
    }

    public function sustainFactory():Sustain
    {
        return new Sustain();
    }

    public function trailFactory():SustainTrail
    {
        return new SustainTrail();
    }

    public function setNoteType(note:Note):Void
    {
        switch (note.kind.type:String)
        {
            case "caution":
                note.missHealth = 50.0;

            case "death":
            {
                note.hitHealth = -100.0;

                note.skipHit = true;
            }

            case "hurt":
            {
                note.hitHealth = -50.0;

                note.skipHit = true;
            }

            default:
            {
                
            }
        }
    }
}