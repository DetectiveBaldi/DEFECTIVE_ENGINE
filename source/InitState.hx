package;

import haxe.ui.Toolkit;

import haxe.ui.focus.FocusManager;

import haxe.ui.themes.Theme;

import flixel.FlxG;
import flixel.FlxState;

import flixel.util.typeLimit.NextState;

import core.Assets;
import core.Options;

import plugins.Log;

import ui.PerfStats;

import util.MathUtil;

class InitState extends FlxState
{
    public var nextState:NextState;

    public static var log:Log;

    public static var perfStats:PerfStats;

    public function new(_nextState:NextState):Void
    {
        super();

        nextState = _nextState;
    }

    override function create():Void
    {
        super.create();

        Toolkit.init();

        Toolkit.theme = "dark";

        FocusManager.instance.autoFocus = false;

        FlxG.fixedTimestep = false;

        FlxG.updateFramerate = MathUtil.maxInt(FlxG.stage.window.displayMode.refreshRate, 144);

        FlxG.drawFramerate = MathUtil.maxInt(FlxG.stage.window.displayMode.refreshRate, 144);

        FlxG.mouse.visible = false;

        FlxG.console.registerClass(InitState);
        
        FlxG.console.registerClass(Options);

        FlxG.plugins.drawOnTop = true;

        Options.init();

        FlxG.autoPause = Options.autoPause;

        FlxG.console.autoPause = Options.autoPause;
        
        FlxG.fullscreen = Options.fullscreen;

        Assets.init();

        log = new Log();

        FlxG.plugins.addPlugin(log);

        perfStats = new PerfStats(10.0, 5.0);
        
        FlxG.game.addChildAt(perfStats, FlxG.game.getChildIndex(FlxG.game.debugger));

        FlxG.switchState(nextState);
    }
}