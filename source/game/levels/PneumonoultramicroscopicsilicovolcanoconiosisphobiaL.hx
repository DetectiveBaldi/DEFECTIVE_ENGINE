package game.levels;

import flixel.math.FlxMath;

import game.Character;
import game.levels.LevelL;

class PneumonoultramicroscopicsilicovolcanoconiosisphobiaL extends LevelL
{
    override function create():Void
    {
        super.create();

        var lastOpponent:Character = opponent;

        opponents.x -= opponent.width * 0.5;

        var opponent:Character = new Character(this, 0.0, 0.0, Character.getConfig("bf-pixel-opponent"));

        opponents.add(opponent);

        opponent.setPosition(lastOpponent.x + opponent.width * 0.5, lastOpponent.y);

        opponent = new Character(this, 0.0, 0.0, Character.getConfig("bf-pixel-opponent"));

        opponents.add(opponent);

        opponent.setPosition(lastOpponent.x, lastOpponent.y + opponent.height * 0.5);

        opponent = new Character(this, 0.0, 0.0, Character.getConfig("bf-pixel-opponent"));

        opponents.add(opponent);

        opponent.setPosition(lastOpponent.x + opponent.width * 0.5, lastOpponent.y + opponent.height * 0.5);

        opponent = new Character(this, 0.0, 0.0, Character.getConfig("bf-pixel-opponent"));

        opponents.add(opponent);

        opponent.setPosition(lastOpponent.x + opponent.width, lastOpponent.y);

        opponent = new Character(this, 0.0, 0.0, Character.getConfig("bf-pixel-opponent"));

        opponents.add(opponent);

        opponent.setPosition(lastOpponent.x + opponent.width, lastOpponent.y + opponent.height * 0.5);

        opponent = new Character(this, 0.0, 0.0, Character.getConfig("bf-pixel-opponent"));

        opponents.add(opponent);

        opponent.setPosition(lastOpponent.x + opponent.width * 1.5, lastOpponent.y);

        opponent = new Character(this, 0.0, 0.0, Character.getConfig("bf-pixel-opponent"));

        opponents.add(opponent);

        opponent.setPosition(lastOpponent.x + opponent.width * 1.5, lastOpponent.y + opponent.height * 0.5);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        opponents.alpha = FlxMath.lerp(opponents.alpha, oppStrumline.notes.members.length > 0.0 ? 1.0 : 0.5, FlxMath.getElapsedLerp(0.15, elapsed));

        players.alpha = FlxMath.lerp(players.alpha, plrStrumline.notes.members.length > 0.0 ? 1.0 : 0.5, FlxMath.getElapsedLerp(0.15, elapsed));
    }
}