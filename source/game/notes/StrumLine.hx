package game.notes;

import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;

import flixel.input.keyboard.FlxKey;

import flixel.util.FlxSignal.FlxTypedSignal;

import core.Conductor;
import core.Inputs;

class StrumLine extends FlxTypedSpriteContainer<Strum>
{
    public var conductor(default, set):Conductor;

    @:noCompletion
    function set_conductor(conductor:Conductor):Conductor
    {
        for (i in 0 ... members.length)
            members[i].conductor = conductor;
        
        return this.conductor = conductor;
    }

    public var inputs:Array<Input>;

    public var lane:Int;

    public var spacing(default, set):Float;

    @:noCompletion
    function set_spacing(spacing:Float):Float
    {
        for (i in 0 ... members.length)
            members[i].x = x + spacing * i;

        return this.spacing = spacing;
    }

    public var artificial:Bool;

    public var noteSpawn:FlxTypedSignal<(note:Note)->Void>;

    public var noteHit:FlxTypedSignal<(note:Note)->Void>;

    public var noteMiss:FlxTypedSignal<(note:Note)->Void>;

    public var ghostTap:FlxTypedSignal<(direction:Int)->Void>;

    public function new(conductor:Conductor):Void
    {
        super();

        this.conductor = conductor;

        inputs =
        [
            {name: "NOTE:LEFT", keys: [FlxKey.Z, FlxKey.A, FlxKey.LEFT]},

            {name: "NOTE:DOWN", keys: [FlxKey.X, FlxKey.S, FlxKey.DOWN]},

            {name: "NOTE:UP", keys: [FlxKey.PERIOD, FlxKey.W, FlxKey.UP]},

            {name: "NOTE:RIGHT", keys: [FlxKey.SLASH, FlxKey.D, FlxKey.RIGHT]}
        ];

        lane = -1;

        spacing = 116.0;

        artificial = false;

        noteSpawn = new FlxTypedSignal<(note:Note)->Void>();

        noteHit = new FlxTypedSignal<(note:Note)->Void>();

        noteMiss = new FlxTypedSignal<(note:Note)->Void>();

        ghostTap = new FlxTypedSignal<(direction:Int)->Void>();

        for (i in 0 ... 4)
        {
            var strum:Strum = new Strum(conductor);

            strum.parent = this;

            strum.direction = i;

            strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Static");

            strum.scale.set(0.685, 0.685);

            strum.updateHitbox();

            strum.x = x + spacing * i;
            
            add(strum);
        }
    }

    override function destroy():Void
    {
        super.destroy();

        noteHit.destroy();

        noteMiss.destroy();

        noteSpawn.destroy();

        ghostTap.destroy();
    }
}