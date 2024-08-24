package;

import openfl.display.Sprite;

import flixel.FlxGame;

import flixel.util.typeLimit.NextState;

import states.GameState;
import states.OpeningState;

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

			updateFramerate: 30,

			drawFramerate: 30,

			skipSplash: false,

			startFullscreen: false
		};

		addChild(new FlxGame(game.gameWidth, game.gameHeight, () -> new OpeningState(game.nextState), game.updateFramerate, game.drawFramerate, game.skipSplash, game.startFullscreen));
	}
}