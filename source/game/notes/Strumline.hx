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
import flixel.sound.FlxSoundGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

import core.AssetCache;
import core.Options;
import core.Paths;
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
    public var beatDispatcher:IBeatDispatcher;

    public var conductor(get, never):Conductor;

    @:noCompletion
    function get_conductor():Conductor
    {
        return beatDispatcher?.conductor;
    }

    public var keyCount:Int;

    public var keyParams:KeyParams;

    public var keysToCheck:Map<Int, Array<Int>>;

    public var keysHeld:Array<Bool>;

    public var strums:FlxTypedSpriteGroup<Strum>;

    public var strumSpacing(default, set):Float;

    @:noCompletion
    function set_strumSpacing(v:Float):Float
    {   
        strumSpacing = v;

        for (i in 0 ... strums.members.length)
        {
            var strum:Strum = strums.members[i];

            strum.x = strums.x + strumSpacing * i;
        }

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

    public var onSustainHold:FlxTypedSignal<(event:SustainHoldEvent)->Void>;

    public var sustainHoldEvent:SustainHoldEvent;

    public var onGhostTap:FlxTypedSignal<(event:GhostTapEvent)->Void>;

    public var ghostTapEvent:GhostTapEvent;

    public var noteSplashes:FlxTypedGroup<NoteSplash>;

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

    public var charGroup:FlxTypedSpriteGroup<Character>;

    public var spectators:FlxTypedSpriteGroup<Character>;

    public var charList:Array<Character>;

    public var vocals:Array<FlxSound>;

    public function new(beatDispatcher:IBeatDispatcher, keyCount:Int):Void
    {
        super();

        this.beatDispatcher = beatDispatcher;

        setKeyCount(keyCount);

        keysToCheck = new Map<Int, Array<Int>>();

        getKeysToCheck();

        keysHeld = new Array<Bool>();

        for (i in 0 ... keyCount)
            keysHeld.push(false);

        strums = new FlxTypedSpriteGroup<Strum>();

        add(strums);

        buildStrums();

        notes = new FlxTypedGroup<Note>();

        notes.active = false;

        add(notes);

        notesPendingRemoval = new Array<Note>();

        sustains = new FlxTypedGroup<Sustain>();

        sustains.active = false;

        insert(members.indexOf(notes), sustains);

        trails = new FlxTypedGroup<SustainTrail>();

        trails.active = false;

        insert(members.indexOf(notes), trails);

        onNoteSpawn = new FlxTypedSignal<(note:Note)->Void>();

        noteHitEvent = new NoteHitEvent();

        onNoteHit = new FlxTypedSignal<(event:NoteHitEvent)->Void>();

        onNoteMiss = new FlxTypedSignal<(note:Note)->Void>();

        onSustainHold = new FlxTypedSignal<(event:SustainHoldEvent)->Void>();

        sustainHoldEvent = new SustainHoldEvent();

        onGhostTap = new FlxTypedSignal<(event:GhostTapEvent)->Void>();

        ghostTapEvent = new GhostTapEvent();

        noteSplashes = new FlxTypedGroup<NoteSplash>();

        add(noteSplashes);

        charList = new Array<Character>();

        scrollSpeed = 1.0;

        downscroll = Options.downscroll;

        botplay = false;

        vocals = new Array<FlxSound>();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (botplay)
        {
            for (i in 0 ... notes.members.length)
            {
                var note:Note = notes.members[i];

                if (!note.skipHit && note.isHittable())
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
                {
                    if (FlxG.keys.checkKeyArrayState(keys, JUST_PRESSED))
                    {
                        var strum:Strum = strums.members[direction];

                        strum.animation.play('${convertDirectionToAnim(direction).toLowerCase()}Press');

                        var notes:Array<Note> = notes.members.filter((note:Note) -> note.direction == direction && note.isHittable());

                        notes.sort(sortNotes);

                        var note:Note = notes[0];

                        notes = notes.filter((newNote:Note) -> newNote.time == note.time);

                        if (notes.length == 0.0)
                            ghostTap(strum.direction);
                        else
                        {
                            for (i in 0 ... notes.length)
                            {
                                var note:Note = notes[i];

                                noteHit(note);
                            }
                        }
                    }

                    if (FlxG.keys.checkKeyArrayState(keys, PRESSED))
                        keysHeld[direction] = true;

                    if (FlxG.keys.checkKeyArrayState(keys, JUST_RELEASED))
                    {
                        keysHeld[direction] = false;

                        var strum:Strum = strums.members[direction];

                        strum.animation.play('${convertDirectionToAnim(direction).toLowerCase()}Static');
                    }
                }
            }
        }

        for (i in 0 ... notes.members.length)
        {
            var note:Note = notes.members[i];

            var hasMissed:Bool = conductor.time > note.time + Rating.latestTiming;

            if ((note.status == IDLING || note.status == FAILING) && !note.skipHit && hasMissed)
                noteMiss(note);

            var hasExpired:Bool = conductor.time > note.time + note.length + Rating.latestTiming;

            if (hasMissed && hasExpired)
                notesPendingRemoval.push(note);

            if (!note.isSustain)
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

        vocals = null;
    }

    public function setKeyCount(v:Int):Void
    {
        keyCount = v;

        keyParams = KeyParams.build(Json.parse(Assets.getText(Paths.json(Paths.data('data/KeyParams/${keyCount}k')))));
    }

    public function convertDirectionToAnimIndex(direction:Int, base4:Bool = false):Int
    {
        var i:Int = Note.DIRECTIONS.indexOf(keyParams.keys[direction]);

        if (base4)
            return Note.DIRECTIONS_BASE_4[i];

        return i;
    }

    public function convertDirectionToAnim(direction:Int, base4:Bool = false):String
    {
       return Note.DIRECTIONS[convertDirectionToAnimIndex(direction, base4)];
    }

    public function getKeysToCheck():Map<Int, Array<Int>>
    {
        keysToCheck.clear();

        var controls:Array<Array<Int>> = Options.controls.exists(keyCount) ? Options.controls[keyCount] : keyParams.controls;

        for (i in 0 ... controls.length)
        {
            var control:Array<Int> = controls[i];

            var copy:Array<Int> = control.copy();

            copy.remove(-1);

            keysToCheck[i] = copy;
        }

        return keysToCheck;
    }

    public function buildStrums():Void
    {
        // TODO: Maybe use recycling here.
        for (i in 0 ... strums.members.length)
        {
            var strum:Strum = strums.members[i];

            strum.destroy();
        }

        strums.members.resize(0);
        
        var strumScale:Float = keyParams.strumScale;

        for (i in 0 ... keyCount)
        {
            var strum:Strum = new Strum(beatDispatcher);

            strum.strumline = this;

            strum.direction = i;

            strum.animation.play('${convertDirectionToAnim(strum.direction).toLowerCase()}Static');

            strum.scale.set(strumScale, strumScale);

            var hitboxScale:Float = 160.0 * strumScale;

            strum.setSize(hitboxScale, hitboxScale);

            strum.centerOffsets();

            strum.setPosition();
            
            strums.add(strum);
        }

        strumSpacing = keyParams.strumSpacing;
    }

    public function setStrumActive(direc:Int, active:Bool):Void
    {
        var strum:Strum = strums.members[direc];

        strum.active = active;

        if (!active)
            strum.animation.finish();
    }

    public function sortNotes(a:Note, b:Note):Int
    {
        if (a.skipHit && !b.skipHit)
			return 1;

		if (!a.skipHit && b.skipHit)
			return -1;

        return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
    }

    public function noteHit(note:Note):Void
    {
        noteHitEvent.reset(note);

        onNoteHit.dispatch(noteHitEvent);

        note.status = HIT;

        note.playSplash = noteHitEvent.playSplash;

        var strum:Strum = note.strum;

        strum.holdTimer = 0.0;
        
        strum.animation.play('${convertDirectionToAnim(note.direction).toLowerCase()}Confirm', true);

        if (note.isSustain)
            resizeSustainNote(note);
        else
        {
            notesPendingRemoval.push(note);

            if (note.playSplash)
                playSplash(note);
        }
        
        setStrumActive(note.direction, !note.isSustain);

        playCharSingAnims(note, note.direction, false, false);

        setCharAnimsActive(note, !note.isSustain);

        setVocalsVolume(1.0);
    }

    public function noteMiss(note:Note):Void
    {
        onNoteMiss.dispatch(note);

        note.status = MISSED;

        playCharSingAnims(note, note.direction, true, false);

        setCharAnimsActive(note, true);

        setVocalsVolume(0.0);

        FlxG.sound.play(AssetCache.getSound('game/GameState/noteMiss${FlxG.random.int(0, 2)}'), 0.15);
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

    public function resizeSustainNote(note:Note):Void
    {
        note.length += note.time - conductor.time;

        note.time = conductor.time;

        if (!note.isSustain)
            finishSustainNote(note);
    }

    public function isHoldingNote(note:Note):Bool
    {
        if (!note.isSustain || (note.status != HIT && note.status != FAILING))
            return false;

        if (botplay)
            return true;

        return keysHeld[note.direction];
    }

    public function holdSustainNote(note:Note, sustain:Sustain):Void
    {
        sustainHoldEvent.reset(note, sustain);

        onSustainHold.dispatch(sustainHoldEvent);

        var strum:Strum = note.strum;

        strum.holdTimer = 0.0;

        strum.animation.play('${convertDirectionToAnim(note.direction).toLowerCase()}Confirm', true);
            
        setStrumActive(note.direction, false);
        
        note.status = HIT;

        note.unholdTime = 0.0;

        playCharSingAnims(note, note.direction, false, true);

        setCharAnimsActive(note, false);

        setVocalsVolume(1.0);
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
            var anim:String = '${convertDirectionToAnim(note.direction).toLowerCase()}Static';

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

            playCharSingAnims(null, direction, true, false);

            setCharAnimsActive(null, true);

            setVocalsVolume(0.0);
        }
    }

    public function playSplash(note:Note):Void
    {
        var splash:NoteSplash = noteSplashes.recycle(NoteSplash, () -> new NoteSplash());

        var strumScale:Float = keyParams.strumScale;

        splash.scale.set(strumScale, strumScale);

        splash.play(convertDirectionToAnimIndex(note.direction), note.isSustain);

        splash.updateHitbox();

        splash.centerTo(note.strum);
    }

    public function playCharSingAnims(note:Note, direction:Int, miss:Bool, hold:Bool):Void
    {
        getCharList(note);

        for (i in 0 ... charList.length)
        {
            if (note?.kind?.noAnimation)
                continue;

            var character:Character = charList[i];

            if (character.skipSing)
                continue;

            character.holdTimer = 0.0;

            var animSuffix:String = "";

            if (note?.kind?.altAnimation)
                animSuffix += "-alt";

            var dir:String = convertDirectionToAnim(direction, true);

            if (hold && character.animation.name.contains(dir))
                continue;

            var animToPlay:String = 'Sing${dir.toUpperCase()}';

            if (miss)
                animToPlay += "MISS";

            var animWithSuffix:String = animToPlay + animSuffix;

            if (character.animation.exists(animWithSuffix))
                character.animation.play(animWithSuffix, true);
            else
            {
                if (character.animation.exists(animToPlay))
                    character.animation.play(animToPlay, true);
            }
        }
    }

    public function setCharAnimsActive(note:Note, active:Bool):Void
    {
        getCharList(note);

        for (i in 0 ... charList.length)
        {
            if (note?.kind?.noAnimation)
                continue;

            var character:Character = charList[i];

            if (character.skipSing)
                continue;

            if (active)
                character.animation.resume();
            else
                character.animation.pause();
        }
    }

    public function getCharList(note:Note):Array<Character>
    {
        if (note?.kind?.specSing)
            charGroup = spectators;

        charList.resize(0);

        if (note?.kind?.charIds != null)
        {
            charList.resize(0);
            
            for (i in 0 ... note.kind.charIds.length)
            {
                var id:Int = note.kind.charIds[i];

                if (id > charGroup.members.length - 1.0)
                {
                    var firstChar:Character = charGroup.members[0];

                    if (!charList.contains(firstChar))
                        charList.push(firstChar);

                    continue;
                }

                charList.push(charGroup.members[id]);
            }
        }
        else
        {
            for (i in 0 ... charGroup.members.length)
                charList.push(charGroup.members[i]);
        }

        return charList;
    }

    public function setVocalsVolume(volume:Float):Void
    {
        for (i in 0 ... vocals.length)
        {
            var sound:FlxSound = vocals[i];

            if (sound != null)
                sound.volume = volume;
        }
    }
}