package game.events;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import game.PlayState;

class CameraFollowEvent
{
    public static function dispatch(game:PlayState, x:Float, y:Float, characterRole:String, duration:Float, ease:String):Void
    {
        switch (characterRole:String)
        {
            case "spectator":
            {
                x = game.spectator.getMidpoint().x;

                y = game.spectator.getMidpoint().y;
            }

            case "opponent":
            {
                x = game.opponent.getMidpoint().x;

                y = game.opponent.getMidpoint().y;
            }

            case "player":
            {
                x = game.player.getMidpoint().x;

                y = game.player.getMidpoint().y;
            }
        }

        if (duration > 0.0)
        {
            game.gameCamera.follow(null, LOCKON, 0.05);

            game.gameCameraTarget.setPosition(x, y);

            FlxTween.tween(game.gameCamera.scroll, {x: game.gameCameraTarget.x - game.gameCamera.width * 0.5, y: game.gameCameraTarget.y - game.gameCamera.height * 0.5}, duration,
            {
                ease: Reflect.getProperty(FlxEase, ease),

                onComplete: (tween:FlxTween) -> game.gameCamera.follow(game.gameCameraTarget, LOCKON, 0.05)
            });
        }
        else
            game.gameCameraTarget.setPosition(x, y);
    }
}