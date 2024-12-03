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

class InitState extends FlxState
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

        FlxG.fixedTimestep = false;

        FlxG.updateFramerate = MathUtil.maxInt(FlxG.stage.window.displayMode.refreshRate, 144);

        FlxG.drawFramerate = MathUtil.maxInt(FlxG.stage.window.displayMode.refreshRate, 144);

        FlxG.mouse.visible = false;
        
        FlxG.console.registerClass(Options);

        FlxG.plugins.drawOnTop = true;

        AssetMan.init();

        Options.init();

        FlxG.autoPause = Options.autoPause;

        FlxG.console.autoPause = Options.autoPause;
        
        FlxG.fullscreen = Options.fullscreen;

        FlxG.plugins.addPlugin(logger = new Logger());
        
        FlxG.game.addChild(perfTracker = new PerfTracker(10.0, 5.0));

        FlxG.switchState(nextState);
    }
}