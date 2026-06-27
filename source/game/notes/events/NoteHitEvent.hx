package game.notes.events;

class NoteHitEvent
{
    public var note:Note;

    public var playSplash:Bool;

    public function new():Void
    {

    }

    public function reset(note:Note):Void
    {
        this.note = note;

        playSplash = !note.strumline.botplay;
    }
}