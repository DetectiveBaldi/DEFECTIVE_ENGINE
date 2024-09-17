package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.util.typeLimit.NextState;

import core.Conductor;

import util.MathUtil;

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

        FlxG.updateFramerate = MathUtil.maxInt(FlxG.stage.window.displayMode.refreshRate, 144);

        FlxG.drawFramerate = MathUtil.maxInt(FlxG.stage.window.displayMode.refreshRate, 144);

        FlxG.mouse.visible = false;

        #if FLX_DEBUG
            FlxG.console.registerClass(Conductor);
        #end

        FlxSprite.defaultAntialiasing = true;

        Conductor.load();

        var perfTracker:objects.PerfTracker = new objects.PerfTracker(10.0, 5.0);
        
        FlxG.game.addChild(perfTracker);

        FlxG.switchState(nextState);
    }
}