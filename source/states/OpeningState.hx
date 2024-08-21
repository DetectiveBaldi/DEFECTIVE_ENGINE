package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.util.typeLimit.NextState;

import core.Conductor;

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

        FlxG.mouse.visible = false;

        FlxSprite.defaultAntialiasing = true;

        Conductor.load();

        #if !html5
            var statistics:core.Statistics = new core.Statistics();

            statistics.x = 10;

            statistics.y = 5;
            
            FlxG.game.addChild(statistics);
        #end

        FlxG.switchState(nextState);
    }
}