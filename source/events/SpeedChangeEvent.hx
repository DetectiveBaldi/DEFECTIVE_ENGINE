package events;

import flixel.FlxG;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;

import states.GameState;

class SpeedChangeEvent
{
    public static function dispatch(speed:Float, duration:Float, ease:EaseFunction):Void
    {
        if (Type.getClass(FlxG.state) != GameState)
            return;

        var game:GameState = cast (FlxG.state, GameState);

        if (duration > 0.0)
            FlxTween.tween(game, {songSpeed: game.chart.speed * speed}, duration, {ease: ease});
        else
            game.chartSpeed = game.chart.speed * speed;
    }
}