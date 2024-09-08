package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.math.FlxMath;

import flixel.util.typeLimit.NextState;

import core.Conductor;

#if !html5
    import objects.PerfTracker;
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
            FlxG.updateFramerate = FlxMath.minInt(FlxG.stage.window.displayMode.refreshRate, 144);

            FlxG.drawFramerate = FlxMath.minInt(FlxG.stage.window.displayMode.refreshRate, 144);
        #end

        FlxG.mouse.visible = false;

        #if FLX_DEBUG
            FlxG.console.registerClass(Conductor);
        #end

        FlxSprite.defaultAntialiasing = true;

        Conductor.load();

        #if !html5
            var perfTracker:PerfTracker = new PerfTracker();

            perfTracker.x = 10;

            perfTracker.y = 5;
            
            FlxG.game.addChild(perfTracker);
        #end

        FlxG.switchState(nextState);
    }
}