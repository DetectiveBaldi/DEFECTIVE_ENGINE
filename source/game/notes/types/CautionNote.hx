package game.notes.types;

import data.Chart.NoteData;
import interfaces.IBeatDispatcher;

class CautionNote extends Note
{
    public function new(beatDispatcher:IBeatDispatcher, noteData:NoteData):Void
    {
        super(beatDispatcher, noteData);

        missHealth = 50.0;
    }
}