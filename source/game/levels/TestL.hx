package game.levels;

class TestL extends LevelL
{
    override function create():Void
    {
        super.create();
    }

    override function stepHit(step:Int):Void
    {
        super.stepHit(step);

        if (step == 160)
        {
            oppStrumline.setKeyCount(6);

            oppStrumline.getKeysToCheck();

            oppStrumline.regenStrums();

            playField.placeOppStrumline(6);

            plrStrumline.setKeyCount(6);

            plrStrumline.regenStrums();

            plrStrumline.getKeysToCheck();

            playField.placePlrStrumline(6);
        }
    }
}