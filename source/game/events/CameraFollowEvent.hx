package game.events;

import flixel.math.FlxPoint;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import game.GameState;

class CameraFollowEvent
{
    public static function dispatch(game:GameState, x:Float, y:Float, characterMap:String, character:String, duration:Float, ease:String):Void
    {
        switch (characterMap:String)
        {
            case "spectatorMap":
            {
                x = game.spectatorMap[character].getMidpoint().x;

                y = game.spectatorMap[character].getMidpoint().y;
            }

            case "opponentMap":
            {
                x = game.opponentMap[character].getMidpoint().x;

                y = game.opponentMap[character].getMidpoint().y;
            }

            case "playerMap":
            {
                x = game.playerMap[character].getMidpoint().x;

                y = game.playerMap[character].getMidpoint().y;
            }
        }

        if (duration > 0.0)
            FlxTween.tween(game.gameCameraTarget, {x: x, y: y}, duration, {ease: Reflect.getProperty(FlxEase, ease)});
        else
            game.gameCameraTarget.setPosition(x, y,);
    }
}