package;

import openfl.display.Sprite;

import flixel.FlxGame;

import game.levels.Level1;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		addChild(new FlxGame(0, 0, () -> new InitState(() -> new Level1()), 60, 60, false, false));
	}
}