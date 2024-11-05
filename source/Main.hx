package;

import openfl.display.Sprite;

import flixel.FlxGame;

import game.levels.Level2;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		addChild(new FlxGame(0, 0, () -> new OpeningState(() -> new Level2()), 60, 60, false, false));
	}
}