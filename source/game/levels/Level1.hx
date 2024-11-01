package game.levels;

import flixel.FlxG;

import game.stages.Week1;

class Level1 extends GameState
{
    public function new():Void
    {
        super(new Week1());
    }

    override function create():Void
    {
        super.create();

        gameCameraTarget.setPosition(cast (stage, Week1).background.getMidpoint().x - gameCameraTarget.width * 0.5, cast (stage, Week1).background.getMidpoint().y - gameCameraTarget.height * 0.5 - 150.0);

        gameCamera.snapToTarget();

        spectator.setPosition(cast (stage, Week1).background.getMidpoint().x - spectator.width * 0.5, cast (stage, Week1).background.getMidpoint().y - spectator.height * 0.75);

        opponent.setPosition(cast (stage, Week1).background.x + 550.0, cast (stage, Week1).background.getMidpoint().y - opponent.height);

        player.setPosition(cast (stage, Week1).background.x + cast (stage, Week1).background.width - player.width - 550.0, cast (stage, Week1).background.getMidpoint().y - player.height * 0.35);
    }
}