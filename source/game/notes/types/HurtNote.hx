package game.notes.types;

import data.Chart.NoteData;
import interfaces.IBeatDispatcher;

class HurtNote extends Note
{
    public function new(beatDispatcher:IBeatDispatcher, noteData:NoteData):Void
    {
        super(beatDispatcher, noteData);

        hitHealth = -50.0;

        skipHit = true;
    }
}