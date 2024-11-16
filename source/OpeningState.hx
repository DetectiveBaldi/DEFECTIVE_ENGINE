package;

import haxe.ui.Toolkit;

import haxe.ui.focus.FocusManager;

import haxe.ui.themes.Theme;

import flixel.FlxG;
import flixel.FlxState;

import flixel.util.typeLimit.NextState;

import core.AssetMan;
import core.Options;

import plugins.Logger;

import ui.PerfTracker;

import util.MathUtil;

class OpeningState extends FlxState
{
    public var nextState:NextState;

    public static var logger:Logger;

    public static var perfTracker:PerfTracker;

    public function new(nextState:NextState):Void
    {
        super();

        this.nextState = nextState;
    }

    override function create():Void
    {
        super.create();

        Toolkit.init();

        Toolkit.theme = Theme.DARK;

        FocusManager.instance.autoFocus = false;

        FlxG.autoPause = false;

        FlxG.fixedTimestep = false;

        FlxG.updateFramerate = MathUtil.maxInt(FlxG.stage.window.displayMode.refreshRate, 144);

        FlxG.drawFramerate = MathUtil.maxInt(FlxG.stage.window.displayMode.refreshRate, 144);

        FlxG.mouse.visible = false;

        FlxG.console.autoPause = false;
        
        FlxG.console.registerClass(Options);

        FlxG.plugins.drawOnTop = true;

        AssetMan.init();

        Options.init();

        logger = new Logger();

        FlxG.plugins.addPlugin(logger);

        perfTracker = new PerfTracker(10.0, 5.0);
        
        FlxG.game.addChild(perfTracker);

        FlxG.switchState(nextState);
    }
}