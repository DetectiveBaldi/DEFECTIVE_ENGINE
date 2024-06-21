package objects;

import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;

import flixel.util.FlxSignal.FlxTypedSignal;

class StrumLine extends FlxTypedSpriteContainer<Strum>
{
    public var lane:Int;

    public var noteHit(default, null):FlxTypedSignal<(Note)->Void>;

    public var noteMiss(default, null):FlxTypedSignal<(Note)->Void>;

    public var noteSpawn(default, null):FlxTypedSignal<(Note)->Void>;

    public var automatic:Bool;

    public function new():Void
    {
        super();

        lane = -1;

        noteHit = new FlxTypedSignal<(Note)->Void>();

        noteMiss = new FlxTypedSignal<(Note)->Void>();

        noteSpawn = new FlxTypedSignal<(Note)->Void>();

        automatic = false;

        for (i in 0 ... 4)
        {
            var strum:Strum = new Strum();

            strum.direction = i;

            strum.parent = this;

            strum.scale.set(0.725, 0.725);

            strum.updateHitbox();

            strum.setPosition(strum.x + ((strum.width * 0.725) * i), 0);

            add(strum);
        }
    }

    override function destroy():Void
    {
        super.destroy();

        noteHit.destroy();

        noteHit = null;

        noteMiss.destroy();

        noteMiss = null;

        noteSpawn.destroy();

        noteSpawn = null;
    }
}