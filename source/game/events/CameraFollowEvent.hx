package game.events;

import flixel.math.FlxPoint;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import game.GameState;

class CameraFollowEvent
{
    public static function dispatch(game:GameState, x:Float, y:Float, character:String, duration:Float, ease:String):Void
    {
        x ?? 0.0;

        y ?? 0.0;

        character ?? "";

        duration ?? game.conductor.crotchet * 0.001;

        ease ?? "linear";

        switch (character:String)
        {
            case "spectator":
            {
                x = game.player.getMidpoint().x;

                y = game.player.getMidpoint().y;
            }

            case "opponent":
            {
                x = game.player.getMidpoint().x;

                y = game.player.getMidpoint().y;
            }

            case "player":
            {
                x = game.player.getMidpoint().x;

                y = game.player.getMidpoint().y;
            }
        }

        if (duration > 0.0)
            FlxTween.tween(game.gameCameraTarget, {x: x, y: y}, duration, {ease: Reflect.getProperty(FlxEase, ease)});
        else
            game.gameCameraTarget.setPosition(x, y,);
    }
}