package util;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import game.PlayField;
import game.notes.Strumline;

class PlayFieldTools
{
    public static function setVisible(playField:PlayField, v:Bool):Void
    {
        playField.scoreClip.visible = playField.scoreText.visible = playField.healthBar.visible = playField.timerClock.visible =
            playField.timerNeedle.visible = v;
    }

    public static function tweenAlpha(playField:PlayField, v:Float, duration:Float = 1.0, ?options:TweenOptions):Void
    {
        var tweens:FlxTweenManager = playField.tweens;

        tweens.tween(playField.scoreClip, {alpha: v}, duration, options);

        tweens.tween(playField.scoreText, {alpha: v}, duration, options);

        tweens.tween(playField.healthBar, {alpha: v}, duration, options);

        tweens.tween(playField.timerClock, {alpha: v}, duration, options);

        tweens.tween(playField.timerNeedle, {alpha: v}, duration, options);
    }

    public static function tweenStrumlinesAlpha(playField:PlayField, v:Float, duration:Float = 1.0, ?options:TweenOptions):Void
    {
        for (i in 0 ... playField.strumlines.members.length)
            playField.tweens.tween(playField.strumlines.members[i], {alpha: v}, duration, options);
    }
}