package;

import openfl.display.Sprite;

import flixel.FlxGame;

import states.GameState;
import states.OpeningState;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		addChild(new FlxGame(0, 0, () -> new OpeningState(() -> new GameState()), 60, 60, false, false));
	}
}