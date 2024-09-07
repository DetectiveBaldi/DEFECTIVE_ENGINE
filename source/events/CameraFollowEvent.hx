package events;

import flixel.FlxG;

import flixel.math.FlxPoint;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;

import states.GameState;

class CameraFollowEvent
{
    public static function dispatch(position:FlxPoint, duration:Float, ease:EaseFunction):Void
    {
        if (Type.getClass(FlxG.state) != GameState)
            return;

        var game:GameState = cast (FlxG.state, GameState);

        if (duration > 0.0)
            FlxTween.tween(game.gameCameraTarget, {x: position.x, y: position.y}, duration, {ease: ease});
        else
            game.gameCameraTarget.setPosition(position.x, position.y);

        position.put();
    }
}