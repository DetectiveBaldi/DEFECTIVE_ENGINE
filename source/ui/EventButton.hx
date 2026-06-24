package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

import core.AssetCache;
import core.Paths;

class EventButton extends FlxSprite
{
    public var enabled:Bool;

    public var onToggle:FlxSignal;

    public function new(x:Float = 0.0, y:Float = 0.0):Void
    {
        super();

        antialiasing = true;

        frames = FlxAtlasFrames.fromSparrow(AssetCache.getGraphic("ui/EventButton/button", false),
            Paths.image(Paths.xml("ui/EventButton/button")));

        animation.addByPrefix("idle", "back", 24.0, false);

        animation.play("idle");

        animation.finish();

        scale.set(0.5, 0.5);

        updateHitbox();

        enabled = true;

        onToggle = new FlxSignal();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var overlap:Bool = FlxG.mouse.overlaps(this, camera) && enabled;

        var scaleInc:Float = FlxMath.lerp(scale.x, overlap ? 0.85 : 0.65, FlxMath.getElapsedLerp(0.15, elapsed));

        scale.set(scaleInc, scaleInc);

        if (FlxG.mouse.justPressed && overlap)
            onToggle.dispatch();
    }

    override function destroy():Void
    {
        super.destroy();

        onToggle = cast FlxDestroyUtil.destroy(onToggle);
    }
}