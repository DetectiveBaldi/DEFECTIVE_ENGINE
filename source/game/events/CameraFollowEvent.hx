package game.events;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;

import game.GameState;

class CameraFollowEvent
{
    public static function dispatch(game:GameState, x:Float, y:Float, duration:Float, ease:String):Void
    {
        var _ease:EaseFunction = Reflect.getProperty(FlxEase, ease);

        if (duration > 0.0)
            FlxTween.tween(game.gameCameraTarget, {x: x, y: y}, duration, {ease: _ease});
        else
            game.gameCameraTarget.setPosition(x, y,);
    }
}