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

using StringTools;

using util.ArrayUtil;

class InitState extends FlxState
{
    public static var fullscreenPlugin:FullscreenPlugin;

    public static function setAutoPause(autoPause:Bool):Void
    {
        FlxG.autoPause = autoPause;

        FlxG.console.autoPause = FlxG.autoPause;
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

        FlxG.console.registerClass(InitState);
        
        FlxG.console.registerClass(Options);

        FlxG.console.registerClass(SaveManager);

        FlxG.console.registerClass(HighScore);

        FlxG.plugins.drawOnTop = true;

        AssetCache.init();

        Playlist.init();

        fullscreenPlugin = new FullscreenPlugin();

        FlxG.plugins.addPlugin(fullscreenPlugin);

        var definedWeek:String = MacroUtil.sanitizeDefine(MacroUtil.getDefine("WEEK"));

        definedWeek = definedWeek.split(":").join(" ");

        var definedLevel:String = MacroUtil.sanitizeDefine(MacroUtil.getDefine("LEVEL"));

        definedLevel = definedLevel.split(":").join(" ");

        if (definedWeek == "" && definedLevel == "")
            throw "No week or level was configured to launch. Use `-D WEEK=Week:Name` or `-D LEVEL=Level:Name` in the command line to continue.";

        var difficulty:String = MacroUtil.sanitizeDefine(MacroUtil.getDefine("DIFFICULTY"));

        difficulty = difficulty.split(":").join(" ");

        if (difficulty == "")
            difficulty = "Normal";
        
        if (definedWeek != "")
        {
            var week:WeekData = WeekData.list.first((week:WeekData) -> week.name == definedWeek);

            PlayState.loadWeek(week, difficulty);

            return;
        }

        var level:LevelData = LevelData.list.first((level:LevelData) -> level.name == definedLevel);

        PlayState.loadLevel(level, difficulty);
    }
}