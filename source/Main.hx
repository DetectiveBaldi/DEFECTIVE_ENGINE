package;

import openfl.display.Sprite;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.util.typeLimit.NextState;

import core.Conductor;
#if !html5
    import core.Statistics;
#end

import states.GameState;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		var game:{gameWidth:Int, gameHeight:Int, nextState:NextState, updateFramerate:Int, drawFramerate:Int, skipSplash:Bool, startFullscreen:Bool} =
		{
			gameWidth: 0,

			gameHeight: 0,

			nextState: () -> new GameState(),

			updateFramerate: 60,

			drawFramerate: 60,

			skipSplash: false,

			startFullscreen: false
		};

		addChild(new FlxGame(game.gameWidth, game.gameHeight, () -> new FlxState(), game.updateFramerate, game.drawFramerate, game.skipSplash, game.startFullscreen));

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
            var statistics:Statistics = new Statistics();

            statistics.x = 10;

            statistics.y = 5;
            
            FlxG.game.addChild(statistics);
        #end

        FlxG.switchState(game.nextState);
	}
}