package game.levels;

import game.stages.Week1;

using util.MathUtil;

class Level1 extends PlayState
{
    override function create():Void
    {
        stage = new Week1();

        super.create();

        gameCameraZoom = 0.8;

        var _stage:Week1 = cast (stage, Week1);

        gameCameraTarget.centerTo(_stage.background);

        gameCameraTarget.y -= 150.0;

        gameCamera.snapToTarget();

        spectators.centerTo(_stage.background);

        spectators.y -= spectators.height * 0.25;

        opponents.x = _stage.background.x + 650.0;

        opponents.y = _stage.background.getMidpoint().y - opponents.height;

        players.x = _stage.background.x + _stage.background.width - players.width - 650.0;

        players.y = _stage.background.getMidpoint().y - players.height * 0.35;
    }
}