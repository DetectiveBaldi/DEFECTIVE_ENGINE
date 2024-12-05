package game.levels;

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

        var _stage:Week1 = cast (stage, Week1);

        gameCameraTarget.setPosition(_stage.background.getMidpoint().x - gameCameraTarget.width * 0.5, _stage.background.getMidpoint().y - gameCameraTarget.height * 0.5 - 150.0);

        gameCamera.snapToTarget();

        spectator.setPosition(_stage.background.getMidpoint().x - spectator.width * 0.5, _stage.background.getMidpoint().y - spectator.height * 0.75);

        opponent.setPosition(_stage.background.x + 550.0, _stage.background.getMidpoint().y - opponent.height);

        player.setPosition(_stage.background.x + _stage.background.width - player.width - 550.0, _stage.background.getMidpoint().y - player.height * 0.35);
    }
}