package objects;

import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;

import flixel.util.FlxSignal.FlxTypedSignal;

class Strumline extends FlxTypedSpriteContainer<Strum>
{
    public var lane:Int;

    public var spacing(default, set):Float;

    @:noCompletion
    function set_spacing(spacing:Float):Float
    {
        for (i in 0 ... members.length)
            members[i].x = x + spacing * i;

        return this.spacing = spacing;
    }

    public var inputs:Array<String>;

    public var artificial:Bool;

    public var noteSpawn(default, null):FlxTypedSignal<(Note)->Void>;

    public var noteHit(default, null):FlxTypedSignal<(Note)->Void>;

    public var noteMiss(default, null):FlxTypedSignal<(Note)->Void>;

    public function new():Void
    {
        super();

        lane = -1;

        spacing = 116.0;

        inputs = new Array<String>();

        artificial = false;

        noteSpawn = new FlxTypedSignal<(Note)->Void>();

        noteHit = new FlxTypedSignal<(Note)->Void>();

        noteMiss = new FlxTypedSignal<(Note)->Void>();

        for (i in 0 ... 4)
        {
            var strum:Strum = new Strum();
            strum.direction = i;
            strum.parent = this;
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
    }
}