package game.levels;

import game.stages.Template;

class Level1 extends GameState
{
    public function new():Void
    {
        super(new Template());
    }

    override function create():Void
    {
        super.create();

        gameCameraTarget.setPosition(cast (stage, Template).background.getMidpoint().x - gameCameraTarget.width * 0.5, cast (stage, Template).background.getMidpoint().y - gameCameraTarget.height * 0.5 - 150.0);

        gameCamera.snapToTarget();

        spectator.setPosition(cast (stage, Template).background.getMidpoint().x - spectator.width * 0.5, cast (stage, Template).background.getMidpoint().y - spectator.height * 0.75);

        opponent.setPosition(cast (stage, Template).background.x + 550.0, cast (stage, Template).background.getMidpoint().y - opponent.height);

        player.setPosition(cast (stage, Template).background.x + cast (stage, Template).background.width - player.width - 550.0, cast (stage, Template).background.getMidpoint().y - player.height * 0.35);
    }
}