package events;

import flixel.FlxG;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;

import states.GameState;

class CameraFollowEvent
{
    public static function dispatch(x:Float, y:Float, duration:Float, ease:EaseFunction):Void
    {
        if (Type.getClass(FlxG.state) != GameState)
        {
            return;
        }

        var game:GameState = cast (FlxG.state, GameState);

        if (duration > 0.0)
        {
            FlxTween.tween(game.gameCameraTarget, {x: x, y: y}, duration, {ease: ease});
        }
        else
        {
            game.gameCameraTarget.setPosition(x, y);
        }
    }
}