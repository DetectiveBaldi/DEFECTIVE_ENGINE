package game.levels;

import game.stages.Week1;

class Level1 extends PlayState
{
    override function create():Void
    {
        stage = new Week1();

        super.create();

        var _stage:Week1 = cast (stage, Week1);

        gameCameraTarget.setPosition(_stage.background.getMidpoint().x - gameCameraTarget.width * 0.5, _stage.background.getMidpoint().y - gameCameraTarget.height * 0.5 - 150.0);

        gameCamera.snapToTarget();

        spectators.x = _stage.background.getMidpoint().x - spectators.width * 0.5;

        spectators.y = _stage.background.getMidpoint().y - spectators.height * 0.75;

        opponents.x = _stage.background.x + 550.0;

        opponents.y = _stage.background.getMidpoint().y - opponent.height;

        players.x = _stage.background.x + _stage.background.width - players.width - 550.0;

        players.y = _stage.background.getMidpoint().y - players.height * 0.35;
    }
}