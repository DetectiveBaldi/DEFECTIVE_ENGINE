package;

import openfl.display.Sprite;

import flixel.FlxGame;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		addChild(new FlxGame(0, 0, () -> new InitState(), 60, 60, false, false));
	}
}