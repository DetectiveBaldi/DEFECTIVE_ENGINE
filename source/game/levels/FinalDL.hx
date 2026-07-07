package game.levels;

class FinalDL extends LevelL
{
    override function create():Void
    {
        super.create();
        
        var lastOpponent:Character = opponent;

        opponents.x -= opponent.width * 0.5;

        var opponent:Character = new Character(this, 0.0, 0.0, Character.getConfig("bf-pixel-opponent"));

        opponents.add(opponent);

        opponent.setPosition(lastOpponent.x + opponent.width * 0.5, lastOpponent.y);
    }
}