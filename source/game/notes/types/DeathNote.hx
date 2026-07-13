package game.notes.types;

import data.Chart.NoteData;
import interfaces.IBeatDispatcher;

class DeathNote extends Note
{
    public function new(beatDispatcher:IBeatDispatcher, noteData:NoteData):Void
    {
        super(beatDispatcher, noteData);

        hitHealth = -100.0;

        skipHit = true;
    }
}