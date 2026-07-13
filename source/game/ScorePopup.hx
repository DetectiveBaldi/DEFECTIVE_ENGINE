package game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

import core.AssetCache;
import core.Options;
import core.Paths;
import interfaces.IBeatDispatcher;
import interfaces.ISequenceHandler;
import music.Conductor;

using tools.AlignTools;

class ScorePopup extends FlxGroup implements ISequenceHandler
{
    public var tweens:FlxTweenManager;

    public var timers:FlxTimerManager;

    public var ratingSprites:FlxSpriteGroup;

    public var comboSprites:FlxSpriteGroup;

    public function new():Void
    {
        super();

        tweens = new FlxTweenManager();

        add(tweens);

        timers = new FlxTimerManager();

        add(timers);

        ratingSprites = new FlxSpriteGroup();

        ratingSprites.setPosition(FlxG.width * 0.35 + Options.ratingPopupOffset.x, FlxG.height * 0.35 + Options.ratingPopupOffset.y);

        add(ratingSprites);

        comboSprites = new FlxSpriteGroup();

        comboSprites.setPosition(FlxG.width * 0.37 + Options.comboPopupOffset.x, FlxG.height * 0.49 + Options.comboPopupOffset.y);

        add(comboSprites);
    }

    public function spriteFactory():FlxSprite
    {
        var spr:FlxSprite = new FlxSprite();

        spr.antialiasing = true;

        return spr;
    }

    public function showRating(rating:Rating):FlxSpriteGroup
    {
        if (!Options.stackScorePopups)
        {
            for (i in 0 ... ratingSprites.members.length)
            {
                var ratingSpr:FlxSprite = ratingSprites.members[i];

                ratingSpr.kill();

                tweens.cancelTweensOf(ratingSpr);
            }
        }

        var ratingSpr:FlxSprite = ratingSprites.recycle(FlxSprite, spriteFactory);

        ratingSpr.loadGraphic(AssetCache.getGraphic('game/ScorePopup/${rating.name.toLowerCase()}'));

        ratingSpr.alpha = 1.0;

        ratingSpr.scale.set(0.65, 0.65);

        ratingSpr.updateHitbox();

        ratingSpr.velocity.set(-FlxG.random.int(0, 10), -FlxG.random.int(140, 175));

        ratingSpr.acceleration.y = 550.0;

        tweens.tween(ratingSpr, {alpha: 0.0}, 0.4, {onComplete: (_:FlxTween) -> ratingSpr.kill(), startDelay: 0.1});

        ratingSprites.remove(ratingSpr, true);

        ratingSpr.setPosition();

        ratingSprites.add(ratingSpr);

        return ratingSprites;
    }

    public function showCombo(combo:Int):FlxSpriteGroup
    {
        if (!Options.stackScorePopups)
        {
            for (i in 0 ... comboSprites.members.length)
            {
                var comboSpr:FlxSprite = comboSprites.members[i];

                comboSpr.kill();

                tweens.cancelTweensOf(comboSpr);
            }
        }

        var comboStr:String = Std.string(combo);

        var splitStr:Array<String> = comboStr.split("");

        for (i in 0 ... splitStr.length)
        {
            var char:String = splitStr[i];

            var comboSpr:FlxSprite = comboSprites.recycle(FlxSprite, spriteFactory);

            comboSpr.loadGraphic(AssetCache.getGraphic('game/ScorePopup/num-${char}'));

            comboSpr.alpha = 1.0;

            comboSpr.scale.set(0.45, 0.45);

            comboSpr.updateHitbox();

            comboSpr.velocity.set(FlxG.random.float(-5.0, 5.0), -FlxG.random.int(130, 150));

            comboSpr.acceleration.y = FlxG.random.int(250, 300);

            tweens.tween(comboSpr, {alpha: 0.0}, 0.4, {onComplete: (_:FlxTween) -> comboSpr.kill(), startDelay: 0.2});

            comboSprites.remove(comboSpr, true);

            comboSpr.setPosition(38.0 * i);

            comboSprites.add(comboSpr);
        }

        return comboSprites;
    }
}