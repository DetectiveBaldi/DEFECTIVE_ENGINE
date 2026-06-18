package game.notes;

import haxe.Json;

import openfl.utils.Assets;

import flixel.FlxG;

import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;

import flixel.sound.FlxSound;

import flixel.tweens.FlxTween;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxTimer;

import core.AssetCache;
import core.Options;
import core.Paths;

import data.Chart;
import data.KeyParams;

import game.notes.events.GhostTapEvent;
import game.notes.events.NoteHitEvent;
import game.notes.events.SustainHoldEvent;

import music.Conductor;

using StringTools;

using util.ArrayUtil;
using tools.ObjectHelpers;

class Strumline extends FlxGroup
{
    public var conductor:Conductor;

    public var chart:Chart;

    public var keyCount:Int;

    public var keyParams:KeyParams;

    public var keysToCheck:Map<Int, Array<Int>>;

    public var keysHeld:Array<Bool>;

    public var strums:FlxTypedSpriteGroup<Strum>;

    public var strumSpacing(default, set):Float;

    @:noCompletion
    function set_strumSpacing(sstrumSpacing:Float):Float
    {   
        strumSpacing = sstrumSpacing;

        for (i in 0 ... strums.members.length)
            strums.members[i].x = strums.x + strumSpacing * i;

        return strumSpacing;
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

    public function new(beatDispatcher:IBeatDispatcher, keyCount:Int):Void
    {
        super();

        conductor = beatDispatcher.conductor;

        this.keyCount = keyCount;

        keyParams = KeyParams.build(Json.parse(Assets.getText(Paths.json(Paths.data('data/KeyParams/${keyCount}k')))));

        getKeysToCheck();

        keysHeld = [for (i in 0 ... keyCount) false];

        strums = new FlxTypedSpriteGroup<Strum>();

        add(strums);

        var strumScale:Float = keyParams.strumScale;

        for (i in 0 ... keyCount)
        {
            var strum:Strum = new Strum(beatDispatcher);

            strum.strumline = this;

            strum.direction = i;

            strum.animation.play('${convertDirectionToAnimation(strum.direction).toLowerCase()}Static');

            strum.scale.set(strumScale, strumScale);

            strum.updateHitbox();
            
            strums.add(strum);
        }

        strumSpacing = keyParams.strumSpacing;

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
                var direction:Int = k;

                var keys:Array<Int> = v;

                @:privateAccess
                if (checkArrayState(keys, JUST_PRESSED))
                {
                    var strum:Strum = strums.members[direction];

                    strum.animation.play('${convertDirectionToAnimation(direction).toLowerCase()}Press');

                    var note:Note = notes.getFirst((_note:Note) -> _note.isHittable() && _note.direction == direction);

                    if (note == null)
                        ghostTap(strum.direction);
                    else
                        noteHit(note);
                }

                if (checkArrayState(keys, PRESSED))
                    keysHeld[direction] = true;

                if (checkArrayState(keys, JUST_RELEASED))
                {
                    keysHeld[direction] = false;

                    var strum:Strum = strums.members[direction];

                    strum.animation.play('${convertDirectionToAnimation(direction).toLowerCase()}Static');
                }
            }
        }

        for (i in 0 ... notes.members.length)
        {
            var note:Note = notes.members[i];

            var hasMissed:Bool = conductor.time > note.time + Rating.latestTiming;

            if ((note.status == IDLING || note.status == FAILING) && hasMissed)
                noteMiss(note);

            var hasExpired:Bool = conductor.time > note.time + note.length + Rating.latestTiming;

            if (hasMissed && hasExpired)
                notesPendingRemoval.push(note);

            if (note.length == 0.0)
                continue;

            if (isHoldingNote(note))
                holdSustainNote(note, note.sustain);
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

                    if (note.unholdTime >= Rating.latestTiming * 2.0)
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

    public function checkArrayState(keys:Array<FlxKey>, state:FlxInputState):Bool
    {
        @:privateAccess
        return FlxG.keys.checkKeyArrayState(keys, state);
    }

    public function convertDirectionToAnimation(direction:Int):String
    {
        return keyParams.mapping[direction];
    }

    public function convertDirectionToAnimationIndex(direction:Int):Int
    {
        return Note.DIRECTIONS.indexOf(keyParams.mapping[direction]);
    }

    public function getKeysToCheck():Map<Int, Array<Int>>
    {
        if (keysToCheck == null)
            keysToCheck = new Map<Int, Array<Int>>();
        else
            keysToCheck.clear();

        for (i in 0 ... keyParams.controls.length)
        {
            var v:Array<Int> = keyParams.controls[i];

            keysToCheck[i] = v;
        }

        return keysToCheck;
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
        
        strum.animation.play('${convertDirectionToAnimation(note.direction).toLowerCase()}Confirm', true);

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

        var strumScale:Float = keyParams.strumScale;

        splash.scale.set(strumScale, strumScale);

        splash.updateHitbox();

        splash.play(convertDirectionToAnimationIndex(note.direction), note.length > 0.0);

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

    public function holdSustainNote(note:Note, sustain:Sustain):Void
    {
        sustainHoldEvent.reset(note, sustain);

        onSustainHold.dispatch(sustainHoldEvent);

        if (lastStep != conductor.step || note.status != HIT)
        {
            note.status = HIT;

            note.unholdTime = 0.0;
            
            var strum:Strum = note.strum;

            strum.holdTimer = 0.0;

            strum.animation.play('${convertDirectionToAnimation(note.direction).toLowerCase()}Confirm', true);
            
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
            var anim:String = '${convertDirectionToAnimation(note.direction).toLowerCase()}Static';

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

            var directionStr:String = convertDirectionToAnimation(direction);

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

            var directionStr:String = convertDirectionToAnimation(direction);

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