package game.notes;

import openfl.events.KeyboardEvent;

import flixel.FlxG;

import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import flixel.sound.FlxSound;

import flixel.util.FlxSignal.FlxTypedSignal;

import core.Assets;
import core.Options;
import core.Paths;

import game.notes.events.GhostTapEvent;
import game.notes.events.NoteHitEvent;

import music.Conductor;

using StringTools;

using util.ArrayUtil;

class Strumline extends FlxGroup
{
    public var conductor:Conductor;

    public var keys:Map<Int, Int>;

    public var keysHeld:Array<Bool>;

    public var registerInputs:Bool;

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

    public var notePops:FlxTypedGroup<NotePop>;

    public var onGhostTap:FlxTypedSignal<(event:GhostTapEvent)->Void>;

    public var ghostTapEvent:GhostTapEvent;

    public var scrollSpeed:Float;

    public var downscroll:Bool;

    public var automated:Bool;

    public var characters:FlxTypedSpriteGroup<Character>;

    public var vocals:FlxSound;

    public var lastStep:Int;

    public function new(_conductor:Conductor):Void
    {
        super();

        conductor = _conductor;

        addKeyboardListeners();

        keysHeld = [for (i in 0 ... 4) false];

        registerInputs = true;

        strums = new FlxTypedSpriteGroup<Strum>();

        add(strums);

        for (i in 0 ... 4)
        {
            var strum:Strum = new Strum(conductor);

            strum.strumline = this;

            strum.direction = i;

            strum.animation.play(Note.DIRECTIONS[strum.direction].toLowerCase() + "Static");

            strum.scale.set(0.7, 0.7);

            strum.updateHitbox();
            
            strums.add(strum);
        }

        spacing = 116.0;

        notes = new FlxTypedGroup<Note>();

        add(notes);

        notesPendingRemoval = new Array<Note>();

        sustains = new FlxTypedGroup<Sustain>();

        insert(members.indexOf(notes), sustains);

        trails = new FlxTypedGroup<SustainTrail>();

        insert(members.indexOf(sustains), trails);

        onNoteSpawn = new FlxTypedSignal<(note:Note)->Void>();

        noteHitEvent = new NoteHitEvent();

        onNoteHit = new FlxTypedSignal<(event:NoteHitEvent)->Void>();

        onNoteMiss = new FlxTypedSignal<(note:Note)->Void>();

        notePops = new FlxTypedGroup<NotePop>();

        add(notePops);

        onGhostTap = new FlxTypedSignal<(event:GhostTapEvent)->Void>();

        ghostTapEvent = new GhostTapEvent();

        scrollSpeed = 1.0;

        downscroll = Options.downscroll;

        automated = false;

        lastStep = 0;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        while (notesPendingRemoval.length > 0.0)
        {
            var note:Note = notesPendingRemoval.pop();

            notes.members.remove(note);

            note.kill();

            if (note.length > 0.0)
            {
                sustains.members.remove(note.sustain);

                trails.members.remove(note.sustain.trail);
            }
        }

        for (i in 0 ... notes.members.length)
        {
            var note:Note = notes.members[i];

            if (automated && note.isHittable())
                noteHit(note);

            var isLate:Bool = conductor.time > note.time + 166.0;

            if (!automated && note.status == IDLING && isLate)
                noteMiss(note, false);

            var isExpired:Bool = conductor.time > note.time + note.length + 166.0;

            if (isLate && isExpired)
                notesPendingRemoval.push(note);

            if (note.length > 0.0 && note.status != IDLING && !note.finishedHold)
            {
                if (isHolding(note))
                {
                    holdSustainNote(note);

                    if (note.unholdTime > 0.0)
                        note.unholdTime = Math.max(0.0, note.unholdTime - elapsed * 1000.0);
                }
                else
                {
                    if (note.status != MISSED)
                    {
                        note.unholdTime += elapsed * 1000.0;

                        if (note.unholdTime > 166.0)
                            noteMiss(note, true);
                    }
                }
    
                if (conductor.time >= note.time + note.length)
                    finishSustainNote(note);
            }
        }

        lastStep = conductor.step;
    }

    override function destroy():Void
    {
        super.destroy();

        removeKeyboardListeners();

        onNoteHit.destroy();

        onNoteMiss.destroy();

        onNoteSpawn.destroy();

        onGhostTap.destroy();
    }

    public function addKeyboardListeners():Void
    {
        if (keys != null)
            return;

        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);

        FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

        keys = [Options.controls["NOTE:LEFT"] => 0, Options.controls["NOTE:DOWN"] => 1, Options.controls["NOTE:UP"] => 2, Options.controls["NOTE:RIGHT"] => 3];
    }

    public function removeKeyboardListeners():Void
    {
        if (keys == null)
            return;

        FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);

        FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);

        keys = null;
    }

    public function keyDown(ev:KeyboardEvent):Void
    {
        var dir:Int = keys[ev.keyCode] ?? -1;

        if (keysHeld[dir] || !registerInputs || dir == -1)
            return;

        keysHeld[dir] = true;

        var strum:Strum = strums.members[dir];

        strum.animation.play(Note.DIRECTIONS[dir].toLowerCase() + "Press");

        var note:Note = notes.getFirst((_note:Note) -> strum.direction == _note.direction && _note.isHittable());

        note == null ? ghostTap(strum.direction) : noteHit(note);
    }

    public function keyUp(ev:KeyboardEvent):Void
    {
        var dir:Int = keys[ev.keyCode] ?? -1;

        if (dir == -1)
            return;

        keysHeld[dir] = false;

        var strum:Strum = strums.members[dir];

        strum.animation.play(Note.DIRECTIONS[dir].toLowerCase() + "Static");
    }

    public function noteHit(note:Note):Void
    {
        noteHitEvent.reset(note);

        onNoteHit.dispatch(noteHitEvent);

        if (note.length > 0.0)
            resizeSustainNote(note);

        note.status = HIT;

        note.showPop = noteHitEvent.showPop;

        if (note.length > 0.0)
            note.visible = false;
        else
        {
            notesPendingRemoval.push(note);

            if (note.showPop)
                showPop(note);
        }

        var strum:Strum = note.strum;

        strum.confirmTimer = 0.0;
        
        strum.animation.play(Note.DIRECTIONS[note.direction].toLowerCase() + "Confirm", true);

        singCharacters(note, note.direction, false);

        if (vocals != null)
            vocals.volume = 1.0;
    }

    public function noteMiss(note:Note, resize:Bool):Void
    {
        onNoteMiss.dispatch(note);

        if (resize)
            resizeSustainNote(note);

        note.status = MISSED;

        missCharacters(note, note.direction);

        if (vocals != null)
            vocals.volume = 0.0;

        var _noteMiss:FlxSound = FlxG.sound.play(Assets.getSound(Paths.ogg('assets/sounds/game/GameState/noteMiss${FlxG.random.int(0, 2)}'), false), 0.15);

        _noteMiss.onComplete = _noteMiss.kill;
    }

    public function ghostTap(direction:Int):Void
    {
        ghostTapEvent.reset(direction);

        onGhostTap.dispatch(ghostTapEvent);

        if (ghostTapEvent.penalize)
        {
            var _noteMiss:FlxSound = FlxG.sound.play(Assets.getSound(Paths.ogg('assets/sounds/game/GameState/noteMiss${FlxG.random.int(0, 2)}'), false), 0.15);

            _noteMiss.onComplete = _noteMiss.kill;

            missCharacters(null, direction);

            if (vocals != null)
                vocals.volume = 0.0;
        }
    }

    public function singCharacters(note:Note, direction:Int, hold:Bool):Void
    {
        if (characters == null)
            return;

        for (i in 0 ... characters.members.length)
        {
            var character:Character = characters.members[i];

            if (character.skipSing)
                continue;

            character.singTimer = 0.0;

            if (hold && character.animation.name == 'Sing${Note.DIRECTIONS[note.direction]}')
                continue;

            if (character.animation.exists('Sing${Note.DIRECTIONS[direction]}'))
                character.animation.play('Sing${Note.DIRECTIONS[direction]}', true);
        }
    }

    public function missCharacters(note:Note, direction:Int):Void
    {
        if (characters == null)
            return;

        for (i in 0 ... characters.members.length)
        {
            var character:Character = characters.members[i];

            if (character.skipSing)
                continue;

            character.singTimer = 0.0;

            if (character.animation.exists('Sing${Note.DIRECTIONS[direction]}MISS'))
                character.animation.play('Sing${Note.DIRECTIONS[direction]}MISS', true);
        }
    }

    public function isHolding(note:Note):Bool
    {
        return note.status != MISSED && (automated || keysHeld[note.direction] || (note.status == HIT && conductor.time >= note.time + note.length - 50.0));
    }

    public function holdSustainNote(note:Note):Void
    {
        if (lastStep != conductor.step)
        {
            var strum:Strum = note.strum;

            strum.confirmTimer = 0.0;

            strum.animation.play(Note.DIRECTIONS[strum.direction].toLowerCase() + "Confirm", true);
            
            if (vocals != null)
                vocals.volume = 1.0;

            singCharacters(note, note.direction, true);
        }
    }

    public function resizeSustainNote(note:Note):Void
    {
        note.length += note.time - conductor.time;

        note.time = conductor.time;
    }

    public function finishSustainNote(note:Note):Void
    {
        if (note.status == HIT)
            notesPendingRemoval.push(note);

        if (!automated)
        {
            if (note.status == HIT)
            {
                if (note.showPop)
                    showPop(note);
            }

            if (!keysHeld[note.direction])
            {
                var anim:String = Note.DIRECTIONS[note.strum.direction].toLowerCase() + "Static";

                note.strum.animation.play(anim, true);
            }
        }

        note.finishedHold = true;
    }

    public function showPop(note:Note):Void
    {
        var pop:NotePop = notePops.recycle(NotePop, () -> new NotePop());

        pop.pop(note.strum.direction, note.length > 0.0);

        pop.setPosition(note.strum.getMidpoint().x - pop.width * 0.5, note.strum.getMidpoint().y - pop.height * 0.5);
    }
}