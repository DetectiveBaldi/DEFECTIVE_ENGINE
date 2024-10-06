package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.util.typeLimit.NextState;

import haxe.ui.Toolkit;

import haxe.ui.themes.Theme;

import core.AssetMan;
import core.Preferences;

import ui.PerfTracker;

import util.MathUtil;

class OpeningState extends FlxState
{
    public var nextState:NextState;

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
            FlxG.console.registerClass(Preferences);
        #end

        FlxSprite.defaultAntialiasing = true;

        Toolkit.init();

        Toolkit.theme = Theme.DARK;

        AssetMan.init();

        Preferences.init();

        Preferences.load();

        var perfTracker:PerfTracker = new PerfTracker(10.0, 5.0);
        
        FlxG.game.addChild(perfTracker);

        FlxG.switchState(nextState);
    }
}