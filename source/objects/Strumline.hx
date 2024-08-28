package objects;

import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;

import flixel.util.FlxSignal.FlxTypedSignal;

class Strumline extends FlxTypedSpriteContainer<Strum>
{
    public var inputs:Array<String>;

    public var lane:Int;

    public var noteHit(default, null):FlxTypedSignal<(Note)->Void>;

    public var noteMiss(default, null):FlxTypedSignal<(Note)->Void>;

    public var noteSpawn(default, null):FlxTypedSignal<(Note)->Void>;

    public var artificial:Bool;

    public function new():Void
    {
        super();

        inputs = new Array<String>();

        lane = -1;

        noteHit = new FlxTypedSignal<(Note)->Void>();

        noteMiss = new FlxTypedSignal<(Note)->Void>();

        noteSpawn = new FlxTypedSignal<(Note)->Void>();

        artificial = false;

        for (i in 0 ... 4)
        {
            var strum:Strum = new Strum();

            strum.direction = i;

            strum.parent = this;

            strum.animation.play(Strum.directions[strum.direction].toLowerCase() + "Static");

            strum.scale.set(0.685, 0.685);

            strum.updateHitbox();

            strum.setPosition(strum.x + ((strum.width * 0.725) * i), 0);

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