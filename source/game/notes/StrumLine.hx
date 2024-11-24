package game.notes;

import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import flixel.util.FlxSignal.FlxTypedSignal;

import core.Conductor;
import core.Inputs;
import core.Options;

import game.GameState;

using StringTools;

using util.ArrayUtil;

class StrumLine extends FlxGroup
{
    public var game:GameState;

    public var conductor(get, never):Conductor;

    @:noCompletion
    function get_conductor():Conductor
    {
        return game.conductor;
    }

    public var inputs:Array<Input>;

    public var strums:FlxTypedSpriteGroup<Strum>;

    public var spacing(default, set):Float;

    @:noCompletion
    function set_spacing(spacing:Float):Float
    {   
        for (i in 0 ... strums.members.length)
            strums.members[i].x = strums.x + spacing * i;

        return this.spacing = spacing;
    }

    public var notes:FlxTypedGroup<Note>;

    public var onNoteSpawn:FlxTypedSignal<(note:Note)->Void>;

    public var onNoteHit:FlxTypedSignal<(note:Note)->Void>;

    public var onNoteMiss:FlxTypedSignal<(note:Note)->Void>;

    public var onGhostTap:FlxTypedSignal<(direction:Int)->Void>;

    public var automated:Bool;

    public function new(game:GameState):Void
    {
        super();

        this.game = game;

        inputs =
        [
            new Input([90, 65, 37]),

            new Input([88, 83, 40]),

            new Input([190, 87, 38]),

            new Input([191, 68, 39])
        ];

        strums = new FlxTypedSpriteGroup<Strum>();

        add(strums);

        for (i in 0 ... 4)
        {
            var strum:Strum = new Strum(conductor);

            strum.parent = this;

            strum.direction = i;

            strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Static");

            strum.scale.set(0.685, 0.685);

            strum.updateHitbox();
            
            strums.add(strum);
        }

        spacing = 116.0;

        notes = new FlxTypedGroup<Note>();

        add(notes);

        onNoteSpawn = new FlxTypedSignal<(note:Note)->Void>();

        onNoteHit = new FlxTypedSignal<(note:Note)->Void>();

        onNoteHit.add((note:Note) ->
        {
            notes.remove(note, true);

            note.kill();
        });

        onNoteMiss = new FlxTypedSignal<(note:Note)->Void>();

        onNoteMiss.add((note:Note) ->
        {
            notes.remove(note, true);

            note.kill();
        });

        onGhostTap = new FlxTypedSignal<(direction:Int)->Void>();

        automated = false;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!automated)
        {
            for (i in 0 ... inputs.length)
            {
                var input:Input = inputs[i];

                if (Inputs.checkStatus(input, JUST_PRESSED))
                {
                    var strum:Strum = strums.members[i];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Press");

                    var note:Note = notes.getFirst((_note:Note) -> _note.exists && Math.abs(conductor.time - _note.time) <= game.judgements.last().timing && strum.direction == _note.direction && !_note.animation.name.contains("Hold"));

                    note == null ? onGhostTap.dispatch(strum.direction) : onNoteHit.dispatch(note);
                }

                if (Inputs.checkStatus(input, PRESSED))
                {
                    var strum:Strum = strums.members[i];

                    var note:Note = notes.getFirst((_note:Note) -> _note.exists && conductor.time >= _note.time && strum.direction == _note.direction && _note.animation.name.contains("Hold"));

                    if (note != null)
                        onNoteHit.dispatch(note);
                }

                if (Inputs.checkStatus(input, JUST_RELEASED))
                {
                    var strum:Strum = strums.members[i];

                    strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Static");
                }
            }
        }

        var i:Int = notes.members.length - 1;

        while (i >= 0.0)
        {
            var note:Note = notes.members[i];

            var strum:Strum = strums.members[note.direction];

            if (automated)
            {
                if (note.exists && conductor.time >= note.time)
                {
                    onNoteHit.dispatch(note);

                    i--;

                    continue;
                }
            }
            else
            {
                if (note.exists && conductor.time > note.time + game.judgements.last().timing)
                {
                    onNoteMiss.dispatch(note);
    
                    i--;
    
                    continue;
                }
            }

            i--;

            note.setPosition(strum.getMidpoint().x - note.width * 0.5, strum.y - (conductor.time - note.time) * game.chartSpeed * note.speed * 0.45 * (Options.downscroll ? -1.0 : 1.0));
        }
    }

    override function destroy():Void
    {
        super.destroy();

        onNoteHit.destroy();

        onNoteMiss.destroy();

        onNoteSpawn.destroy();

        onGhostTap.destroy();
    }
}