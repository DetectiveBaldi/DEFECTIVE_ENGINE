package game.notes.events;

class NoteHitEvent
{
    public var note:Note;

    public var showPop:Bool;

    public function new():Void
    {

    }

    public function reset(_note:Note):Void
    {
        note = _note;

        showPop = !note.strumline.automated;
    }
}