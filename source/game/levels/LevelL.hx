package game.levels;

import game.stages.StageS;

using tools.AlignTools;

class LevelL extends PlayState
{
    public var stageS:StageS;

    override function create():Void
    {
        stage = new StageS();

        stageS = cast (stage, StageS);

        super.create();

        cameraPoint.centerTo(stageS.background);

        cameraPoint.y += 100.0;

        gameCamera.snapToTarget();

        spectators.centerTo(stageS.background);

        spectators.y += spectators.height * 0.25;

        opponents.x = stageS.background.x + 550.0;

        opponents.y = stageS.background.getMidpoint().y - opponents.height * 0.35;

        players.x = stageS.background.x + stageS.background.width - players.width - 650.0;

        players.y = stageS.background.getMidpoint().y + players.height * 0.35;
    }
}