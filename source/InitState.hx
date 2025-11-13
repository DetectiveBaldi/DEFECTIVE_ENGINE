package;

import haxe.ui.Toolkit;

import haxe.ui.focus.FocusManager;

import haxe.ui.themes.Theme;

import flixel.FlxG;
import flixel.FlxState;

import flixel.util.typeLimit.NextState;

import core.AssetCache;
import core.Options;
import core.Paths;
import core.SaveManager;

import data.LevelData;
import data.Playlist;
import data.WeekData;

import game.HighScore;
import game.PlayState;

import plugins.FullscreenPlugin;

import util.MacroUtil;

using util.ArrayUtil;

class InitState extends FlxState
{
    public static var fullscreenPlugin:FullscreenPlugin;

    public static function setAutoPause(autoPause:Bool):Void
    {
        FlxG.autoPause = autoPause;

        #if FLX_DEBUG
        FlxG.console.autoPause = autoPause;
        #end
    }

    public static function setFrameRateCap(frameRate:Int):Void
    {
        if (frameRate > FlxG.updateFramerate)
        {
            FlxG.updateFramerate = frameRate;

            FlxG.drawFramerate = frameRate;
        }
        else
        {
            FlxG.drawFramerate = frameRate;

            FlxG.updateFramerate = frameRate;
        }
    }

    override function create():Void
    {
        super.create();

        Toolkit.init();

        Toolkit.theme = Theme.DARK;

        FocusManager.instance.autoFocus = false;

        FlxG.fixedTimestep = false;

        SaveManager.init();

        SaveManager.mergeData();

        setAutoPause(Options.autoPause);

        setFrameRateCap(Options.frameRate);

        FlxG.fullscreen = true;

        FlxG.mouse.visible = false;

        #if FLX_DEBUG
        FlxG.console.registerClass(InitState);
        
        FlxG.console.registerClass(Options);

        FlxG.console.registerClass(SaveManager);

        FlxG.console.registerClass(HighScore);
        #end

        FlxG.plugins.drawOnTop = true;

        AssetCache.init();

        Playlist.init();

        fullscreenPlugin = new FullscreenPlugin();

        FlxG.plugins.addPlugin(fullscreenPlugin);

        var definedWeek:String = MacroUtil.getDefine("WEEK");

        if (definedWeek != null)
            definedWeek = definedWeek.split("=")[0];

        var definedLevel:String = MacroUtil.getDefine("LEVEL");

        if (definedLevel != null)
            definedLevel = definedLevel.split("=")[0];

        if (definedWeek == null && definedLevel == null)
            throw "Invalid launch parameters!";
        else
        {
            if (definedWeek == null)
                PlayState.loadLevel(LevelData.list.first((level:LevelData) -> level.name == definedLevel));
            else
                PlayState.loadWeek(WeekData.list.first((week:WeekData) -> week.name == definedWeek));
        }
    }
}