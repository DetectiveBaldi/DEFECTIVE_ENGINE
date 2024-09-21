package;

import openfl.display.Sprite;

import flixel.FlxGame;

import game.GameState;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		addChild(new FlxGame(0, 0, () -> new OpeningState(() -> new GameState()), 60, 60, false, false));
	}
}