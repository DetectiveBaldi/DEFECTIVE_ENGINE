package game.levels;

import flixel.FlxG;

import data.Chart.NoteData;

class TestL extends LevelL
{
    override function create():Void
    {
        super.create();
    }

    override function loadChart():Void
    {
        super.loadChart();

        for (i in 0 ... chart.notes.length)
        {
            var note:NoteData = chart.notes[i];

            if (i > 23.0 && i < 40.0)
                note.direction = FlxG.random.int(0, 8);

            if (i > 39.0 && i < 116.0)
                note.direction = FlxG.random.int(0, 5);

            if (i > 177.0 && i < 234.0)
                note.direction = FlxG.random.int(0, 11);

            if (i > 308.0 && i < 432.0)
                note.direction = FlxG.random.int(0, 8);

            if (i > 431.0)
                note.direction = FlxG.random.int(0, 17);
        }
    }

    override function stepHit(step:Int):Void
    {
        super.stepHit(step);

        if (step == 192)
            changeKeyCount(9);

        if (step == 256)
            changeKeyCount(6);

        if (step == 384)
            changeKeyCount(4);

        if (step == 512)
            changeKeyCount(12);

        if (step == 640)
            changeKeyCount(4);

        if (step == 768)
            changeKeyCount(9);

        if (step == 896)
            changeKeyCount(20);
    } 

    public function changeKeyCount(keyCount:Int):Int
    {
        oppStrumline.setKeyCount(keyCount);

        oppStrumline.getKeysToCheck();

        oppStrumline.getKeysHeld();

        oppStrumline.regenStrums();

        playField.placeOpponentStrumline(keyCount);

        plrStrumline.setKeyCount(keyCount);

        plrStrumline.regenStrums();

        plrStrumline.getKeysToCheck();

        plrStrumline.getKeysHeld();

        playField.placePlayerStrumline(keyCount);
        
        return keyCount;
    }
}