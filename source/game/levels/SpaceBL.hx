package game.levels;

import game.Character;

class SpaceBL extends LevelL
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

        var lastPlayer:Character = player;

        players.setPosition(player.x - player.width * 0.5, player.y - player.height * 0.5);

        var player:Character = new Character(this, 0.0, 0.0, Character.getConfig("bf"));

        players.add(player);

        player.setPosition(lastPlayer.x + player.width * 0.5, lastPlayer.y);

        player = new Character(this, 0.0, 0.0, Character.getConfig("bf"));

        players.add(player);

        player.setPosition(lastPlayer.x, lastPlayer.y + player.height * 0.5);

        player = new Character(this, 0.0, 0.0, Character.getConfig("bf"));

        players.add(player);

        player.setPosition(lastPlayer.x + player.width * 0.5, lastPlayer.y + player.height * 0.5);

        player = new Character(this, 0.0, 0.0, Character.getConfig("bf"));

        players.add(player);

        player.setPosition(lastPlayer.x + player.width, lastPlayer.y);

        player = new Character(this, 0.0, 0.0, Character.getConfig("bf"));

        players.add(player);

        player.setPosition(lastPlayer.x + player.width, lastPlayer.y + player.height * 0.5);
    }
}