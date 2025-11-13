package game.levels;

import game.stages.StageS;

using util.MathUtil;

class UnbeatableL extends PlayState
{
    public var stageS:StageS;

    override function create():Void
    {
        stage = new StageS();

        stageS = cast (stage, StageS);

        super.create();

        gameCameraZoom = 0.8;

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

    override function measureHit(section:Int):Void
    {
        super.measureHit(section);

        if (section < 0.0)
            return;
        
        if (cameraCharTarget == "OPPONENT")
            gameCameraZoom = 0.9;
        else
            gameCameraZoom = 0.7;
    }
}