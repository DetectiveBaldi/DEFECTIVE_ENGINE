package game.notes;

import flixel.FlxG;

import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import flixel.sound.FlxSound;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal.FlxTypedSignal;

import core.AssetCache;
import core.Options;

import game.notes.events.GhostTapEvent;
import game.notes.events.NoteHitEvent;
import game.notes.events.SustainHoldEvent;

import music.Conductor;

using StringTools;

using util.ArrayUtil;
using util.MathUtil;

class Strumline extends FlxGroup
{
    public var conductor:Conductor;

    public var keysToCheck:Map<Int, Int>;

    public var keysHeld:Array<Bool>;

    public var strums:FlxTypedSpriteGroup<Strum>;

    public var spacing(default, set):Float;

    @:noCompletion
    function set_spacing(_spacing:Float):Float
    {   
        spacing = _spacing;

        for (i in 0 ... strums.members.length)
            strums.members[i].x = strums.x + spacing * i;

        return spacing;
    }

    public var notes:FlxTypedGroup<Note>;

    public var notesPendingRemoval:Array<Note>;

    public var sustains:FlxTypedGroup<Sustain>;

    public var trails:FlxTypedGroup<SustainTrail>;

    public var onNoteSpawn:FlxTypedSignal<(note:Note)->Void>;

    public var noteHitEvent:NoteHitEvent;

    public var onNoteHit:FlxTypedSignal<(event:NoteHitEvent)->Void>;

    public var onNoteMiss:FlxTypedSignal<(note:Note)->Void>;

    public var noteSplashes:FlxTypedGroup<NoteSplash>;

    public var onSustainHold:FlxTypedSignal<(event:SustainHoldEvent)->Void>;

    public var sustainHoldEvent:SustainHoldEvent;

    public var onGhostTap:FlxTypedSignal<(event:GhostTapEvent)->Void>;

    public var ghostTapEvent:GhostTapEvent;

    public var scrollSpeed:Float;

    public var downscroll(default, set):Bool;

    @:noCompletion
    function set_downscroll(down:Bool):Bool
    {
        downscroll = down;

        for (i in 0 ... strums.members.length)
            strums.members[i].downscroll = downscroll;

        return downscroll;
    }

    public var botplay:Bool;

    public var characters:FlxTypedSpriteGroup<Character>;

    public var spectators:FlxTypedSpriteGroup<Character>;

    public var vocals:FlxSound;

    public var lastStep:Int;

    public function new(beatDispatcher:IBeatDispatcher):Void
    {
        super();

        conductor = beatDispatcher.conductor;

        getKeysToCheck();

        keysHeld = [for (i in 0 ... 4) false];

        strums = new FlxTypedSpriteGroup<Strum>();

        add(strums);

        for (i in 0 ... 4)
        {
            var strum:Strum = new Strum(beatDispatcher);

            strum.strumline = this;

            strum.direction = i;

            strum.animation.play(Note.DIRECTIONS[strum.direction].toLowerCase() + "Static");

            strum.scale.set(0.7, 0.7);

            strum.updateHitbox();
            
            strums.add(strum);
        }

        spacing = 116.0;

        notes = new FlxTypedGroup<Note>();

        notes.active = false;

        add(notes);

        notesPendingRemoval = new Array<Note>();

        sustains = new FlxTypedGroup<Sustain>();

        sustains.active = false;

        insert(members.indexOf(notes), sustains);

        trails = new FlxTypedGroup<SustainTrail>();

        trails.active = false;

        insert(members.indexOf(sustains), trails);

        onNoteSpawn = new FlxTypedSignal<(note:Note)->Void>();

        noteHitEvent = new NoteHitEvent();

        onNoteHit = new FlxTypedSignal<(event:NoteHitEvent)->Void>();

        onNoteMiss = new FlxTypedSignal<(note:Note)->Void>();

        onSustainHold = new FlxTypedSignal<(event:SustainHoldEvent)->Void>();

        sustainHoldEvent = new SustainHoldEvent();

        noteSplashes = new FlxTypedGroup<NoteSplash>();

        add(noteSplashes);

        onGhostTap = new FlxTypedSignal<(event:GhostTapEvent)->Void>();

        ghostTapEvent = new GhostTapEvent();

        scrollSpeed = 1.0;

        downscroll = Options.downscroll;

        botplay = false;

        lastStep = 0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (botplay)
        {
            for (i in 0 ... notes.members.length)
            {
                var note:Note = notes.members[i];

                if (note.isHittable())
                    noteHit(note);
            }
        }
        else
        {
            for (k => v in keysToCheck)
            {
                var keyCode:Int = k;

                var direc:Int = v;

                if (FlxG.keys.checkStatus(keyCode, JUST_PRESSED))
                {
                    var strum:Strum = strums.members[direc];

                    strum.animation.play(Note.DIRECTIONS[direc].toLowerCase() + "Press");

                    var note:Note = notes.getFirst((_note:Note) -> _note.isHittable() && _note.direction == direc);

                    if (note == null)
                        ghostTap(strum.direction);
                    else
                        noteHit(note);
                }

                if (FlxG.keys.checkStatus(keyCode, PRESSED))
                    keysHeld[direc] = true;

                if (FlxG.keys.checkStatus(keyCode, JUST_RELEASED))
                {
                    keysHeld[direc] = false;

                    var strum:Strum = strums.members[direc];

                    strum.animation.play(Note.DIRECTIONS[direc].toLowerCase() + "Static");
                }
            }
        }

        for (i in 0 ... notes.members.length)
        {
            var note:Note = notes.members[i];

            var hasMissed:Bool = conductor.time > note.time + note.latestTiming;

            if ((note.status == IDLING || note.status == FAILING) && hasMissed)
                noteMiss(note);

            var hasExpired:Bool = conductor.time > note.time + note.length + note.latestTiming;

            if (hasMissed && hasExpired)
                notesPendingRemoval.push(note);

            if (note.length == 0.0)
                continue;

            if (isHoldingNote(note))
                holdSustainNote(note, note.sustain, elapsed);
            else
            {
                if (note.status == HIT)
                {
                    if (note.status != FAILING)
                    {
                        resizeSustainNote(note);

                        note.status = FAILING;
                    }
                }

                if (note.status == FAILING)
                {
                    setStrumActive(note.direction, true);

                    note.unholdTime += 1000.0 * elapsed;

                    if (note.unholdTime >= note.latestTiming * 2.0)
                        noteMiss(note);
                }
            }

            if (conductor.time >= note.time + note.length)
                finishSustainNote(note);
        }

        while (notesPendingRemoval.length > 0.0)
            removeNote(notesPendingRemoval.pop());

        notes.update(elapsed);

        sustains.update(elapsed);

        trails.update(elapsed);

        lastStep = conductor.step;
    }

    override function destroy():Void
    {
        super.destroy();

        keysToCheck = null;

        keysHeld = null;

        onNoteHit = cast FlxDestroyUtil.destroy(onNoteHit);

        onNoteMiss = cast FlxDestroyUtil.destroy(onNoteMiss);

        onNoteSpawn = cast FlxDestroyUtil.destroy(onNoteSpawn);

        onGhostTap = cast FlxDestroyUtil.destroy(onGhostTap);
    }

    public function getKeysToCheck():Map<Int, Int>
    {
        return keysToCheck =
        [
            for (i in 0 ... Note.DIRECTIONS.length)
                for (j in 0 ... Options.controls['NOTE:${Note.DIRECTIONS[i]}'].length)
                    Options.controls['NOTE:${Note.DIRECTIONS[i]}'][j] => i
        ];
    }

    public function resetStrums():Void
    {
        strums.forEach((strum:Strum) -> strum.animation.play(Note.DIRECTIONS[strum.direction].toLowerCase() + "Static", true));
    }

    public function resetKeysHeld():Void
    {
        for (i in 0 ... keysHeld.length)
            keysHeld[i] = false;
    }

    public function setStrumActive(direc:Int, active:Bool):Void
    {
        var strum:Strum = strums.members[direc];

        strum.active = active;

        if (!active)
            strum.animation.finish();
    }

    public function noteHit(note:Note):Void
    {
        noteHitEvent.reset(note);

        onNoteHit.dispatch(noteHitEvent);

        note.status = HIT;

        note.playSplash = noteHitEvent.playSplash;

        var strum:Strum = note.strum;

        strum.holdTimer = 0.0;
        
        strum.animation.play(Note.DIRECTIONS[note.direction].toLowerCase() + "Confirm", true);

        if (note.length > 0.0)
            resizeSustainNote(note);
        else
        {
            notesPendingRemoval.push(note);

            if (note.playSplash)
                playSplash(note);
        }
        
        setStrumActive(note.direction, note.length == 0.0);

        playCharSingAnims(note, note.direction, false);

        setCharAnimsActive(note, note.length == 0.0);

        if (vocals != null)
            vocals.volume = 1.0;
    }

    public function noteMiss(note:Note):Void
    {
        onNoteMiss.dispatch(note);

        note.status = MISSED;

        playCharMissAnims(note, note.direction);

        setCharAnimsActive(note, true);

        if (vocals != null)
            vocals.volume = 0.0;

        FlxG.sound.play(AssetCache.getSound('game/GameState/noteMiss${FlxG.random.int(0, 2)}'), 0.15);
    }

    public function playSplash(note:Note):Void
    {
        var splash:NoteSplash = noteSplashes.recycle(NoteSplash, () -> new NoteSplash());

        splash.play(note.strum.direction, note.length > 0.0);

        splash.centerTo(note.strum);
    }

    public function isHoldingNote(note:Note):Bool
    {
        if (note.length == 0.0 || (note.status != HIT && note.status != FAILING))
            return false;

        if (botplay)
            return true;

        return keysHeld[note.direction];
    }

    public function holdSustainNote(note:Note, sustain:Sustain, elapsed:Float):Void
    {
        sustainHoldEvent.reset(note, sustain, elapsed);

        onSustainHold.dispatch(sustainHoldEvent);

        if (lastStep != conductor.step || note.status != HIT)
        {
            note.status = HIT;

            note.unholdTime = 0.0;
            
            var strum:Strum = note.strum;

            strum.holdTimer = 0.0;

            strum.animation.play(Note.DIRECTIONS[strum.direction].toLowerCase() + "Confirm", true);
            
            setStrumActive(note.direction, false);
            
            if (vocals != null)
                vocals.volume = 1.0;

            playCharSingAnims(note, note.direction, true);

            setCharAnimsActive(note, false);
        }
    }

    public function resizeSustainNote(note:Note):Void
    {
        note.length += note.time - conductor.time;

        note.time = conductor.time;

        if (note.length == 0.0)
            finishSustainNote(note);
    }

    public function finishSustainNote(note:Note):Void
    {
        setStrumActive(note.direction, true);

        setCharAnimsActive(note, true);

        if (note.status == HIT)
            notesPendingRemoval.push(note);

        if (note.unholdTime == 0.0)
        {
            if (note.playSplash)
                playSplash(note);
        }
        else
        {
            var anim:String = Note.DIRECTIONS[note.strum.direction].toLowerCase() + "Static";

            note.strum.animation.play(anim, true);
        }
    }

    public function ghostTap(direction:Int):Void
    {
        ghostTapEvent.reset(direction);

        onGhostTap.dispatch(ghostTapEvent);

        if (!ghostTapEvent.ghostTapping)
        {
            FlxG.sound.play(AssetCache.getSound('game/GameState/noteMiss${FlxG.random.int(0, 2)}'), 0.15);

            playCharMissAnims(null, direction);

            setCharAnimsActive(null, true);

            if (vocals != null)
                vocals.volume = 0.0;
        }
    }

    public function playCharSingAnims(note:Note, direction:Int, hold:Bool):Void
    {
        var charGroup:FlxTypedSpriteGroup<Character> = characters;

        if (note.kind.specSing)
            charGroup = spectators;

        for (i in 0 ... charGroup.members.length)
        {
            var character:Character = charGroup.members[i];

            if (note.kind.noAnimation)
                continue;

            var charIds:Array<Int> = note.kind.charIds;

            if (charIds != null && !charIds.contains(-1) && !charIds.contains(i))
                continue;

            if (character.skipSing)
                continue;

            character.holdTimer = 0.0;

            var animSuffix:String = "";

            if (note.kind.altAnimation)
                animSuffix = "-alt";

            var directionStr:String = Note.DIRECTIONS[note.direction];

            if (hold && character.animation.name.contains(directionStr))
                continue;

            var animToPlay:String = 'Sing${directionStr}${animSuffix}';

            if (character.animation.exists(animToPlay))
                character.animation.play(animToPlay, true);
            else
            {
                animToPlay = 'Sing${directionStr}';

                if (character.animation.exists(animToPlay))
                    character.animation.play(animToPlay, true);
            }
        }
    }

    public function playCharMissAnims(note:Note, direction:Int):Void
    {
        var charGroup:FlxTypedSpriteGroup<Character> = characters;

        if (note?.kind?.specSing)
            charGroup = spectators;

        for (i in 0 ... charGroup.members.length)
        {
            var character:Character = charGroup.members[i];

            if (note != null)
            {
                if (note.kind.noAnimation)
                    continue;

                var charIds:Array<Int> = note.kind.charIds;

                if (charIds != null && !charIds.contains(-1) && !charIds.contains(i))
                    continue;
            }

            if (character.skipSing)
                continue;

            character.holdTimer = 0.0;

            var animSuffix:String = "";

            if (note?.kind?.altAnimation)
                animSuffix = "-alt";

            var directionStr:String = Note.DIRECTIONS[direction];

            var animToPlay:String = 'Sing${directionStr}MISS${animSuffix}';

            if (character.animation.exists(animToPlay))
                character.animation.play(animToPlay, true);
            else
            {
                animToPlay = 'Sing${directionStr}MISS';

                if (character.animation.exists(animToPlay))
                    character.animation.play(animToPlay, true);
            }
        }
    }

    public function setCharAnimsActive(note:Note, active:Bool):Void
    {
        var charGroup:FlxTypedSpriteGroup<Character> = characters;

        if (note?.kind?.specSing)
            charGroup = spectators;

        for (i in 0 ... charGroup.members.length)
        {
            var character:Character = charGroup.members[i];

            if (note != null)
            {
                if (note.kind.noAnimation)
                    continue;

                var charIds:Array<Int> = note.kind.charIds;

                if (charIds != null && !charIds.contains(-1) && !charIds.contains(i))
                    continue;
            }

            if (character.skipSing)
                continue;

            if (active)
                character.animation.resume();
            else
                character.animation.pause();
        }
    }

    public function removeNote(note:Note):Void
    {
        notes.members.remove(note);

        note.kill();

        if (note.sustain != null)
        {
            sustains.members.remove(note.sustain);

            trails.members.remove(note.sustain.trail);
        }
    }
}