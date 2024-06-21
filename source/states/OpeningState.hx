package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.util.typeLimit.NextState;

import core.Conductor;
#if !html5
    import core.Statistics;
#end

class OpeningState extends FlxState
{
    public var nextState(default, null):NextState;

    public function new(nextState:NextState):Void
    {
        super();

        this.nextState = nextState;
    }

    override function create():Void
    {
        super.create();

        #if !html5
            FlxG.autoPause = false;
        #end

        FlxG.fixedTimestep = false;

        #if !html5
            FlxG.updateFramerate = FlxG.stage.window.displayMode.refreshRate;

            FlxG.drawFramerate = FlxG.stage.window.displayMode.refreshRate;
        #end

        FlxSprite.defaultAntialiasing = true;

        Conductor.initiate();

        #if !html5
            var statistics:Statistics = new Statistics();

            statistics.x = 10;

            statistics.y = 5;
            
            FlxG.game.addChild(statistics);
        #end

        FlxG.switchState(nextState);
    }
}