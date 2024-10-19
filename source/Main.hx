package;

import openfl.display.Sprite;

import flixel.FlxGame;

import game.GameScreen;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		addChild(new FlxGame(0, 0, () -> new OpeningState(() -> new GameScreen("Bopeebo")), 60, 60, false, false));
	}
}