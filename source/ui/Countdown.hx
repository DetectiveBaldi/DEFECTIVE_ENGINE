package ui;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.group.FlxGroup;

import flixel.sound.FlxSound;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenManager;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;

import core.AssetCache;
import core.Paths;

import interfaces.ISequenceHandler;

import music.Conductor;

/**
 * A `flixel.group.FlxGroup` representing the countdown you see in `game.PlayState`.
 */
class Countdown extends FlxGroup
{
    public var tweens:FlxTweenManager;

    public var conductor:Conductor;

    public var tick:Int;

    public var sprite:FlxSprite;

    public var threeSound:FlxSound;

    public var twoSound:FlxSound;

    public var oneSound:FlxSound;

    public var goSound:FlxSound;

    public function new(sequenceHandler:ISequenceHandler, beatDispatcher:IBeatDispatcher):Void
    {
        super();

        tweens = sequenceHandler.tweens;

        conductor = beatDispatcher.conductor;

        conductor.onBeatHit.add(beatHit);

        tick = 0;

        sprite = new FlxSprite().loadGraphic(AssetCache.getGraphic("ui/Countdown/countdown"), true, 1000, 500);

        sprite.antialiasing = true;

        sprite.animation.add("ready", [0], 0.0, false);

        sprite.animation.add("set", [1], 0.0, false);

        sprite.animation.add("go", [2], 0.0, false);

        sprite.alpha = 0.0;

        sprite.scale.set(0.85, 0.85);

        sprite.updateHitbox();

        sprite.screenCenter();

        add(sprite);

        threeSound = FlxG.sound.load(AssetCache.getSound("ui/Countdown/three"), 0.65);

        twoSound = FlxG.sound.load(AssetCache.getSound("ui/Countdown/two"), 0.65);

        oneSound = FlxG.sound.load(AssetCache.getSound("ui/Countdown/one"), 0.65);

        goSound = FlxG.sound.load(AssetCache.getSound("ui/Countdown/go"), 0.65);
    }

    override function destroy():Void
    {
        super.destroy();

        conductor?.onBeatHit?.remove(beatHit);

        stopSounds();
    }

    public function beatHit(beat:Int):Void
    {
        switch (tick:Int)
        {
            case 0:
                threeSound.play();

            case 1:
            {
                sprite.animation.play("ready");

                twoSound.play();
            }

            case 2:
            {
                sprite.animation.play("set");

                oneSound.play();
            }

            case 3:
            {
                sprite.animation.play("go");

                goSound.play();
            }

            case 4:
                kill();
        }

        if (tick > 0.0)
        {
            tweens.cancelTweensOf(sprite, ["alpha"]);
            
            sprite.alpha = 1.0;
            
            tweens.tween(sprite, {alpha: 0.0}, conductor.beatLength * 0.001, {ease: FlxEase.circInOut});
        }

        tick++;
    }

    public function stopSounds(destroySounds:Bool = true):Void
    {
        threeSound.stop();

        twoSound.stop();

        oneSound.stop();

        goSound.stop();

        if (destroySounds)
        {
            threeSound.destroy();

            twoSound.destroy();

            oneSound.destroy();

            goSound.destroy();
        }
    }

    public function skip():Void
    {
        kill();

        conductor.update(0.0);
        
        conductor.onBeatHit.remove(beatHit);

        stopSounds(false);
    }
}