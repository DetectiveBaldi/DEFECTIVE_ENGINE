package game.notes.events;

class NoteHitEvent
{
    public var note:Note;

    public var playSplash:Bool;

    public function new():Void
    {

    }

    public function reset(_note:Note):Void
    {
        note = _note;

        playSplash = !note.strumline.botplay;
    }
}