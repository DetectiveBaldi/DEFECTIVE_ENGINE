package game.notes.events;

import core.Options;

class NoteHitEvent
{
    public var note:Note;

    public var playSplash:Bool;

    public function new():Void
    {
        playSplash = false;
    }

    public function reset(note:Note):Void
    {
        this.note = note;

        playSplash = Options.noteSplashOpacity != 0.0 && !note.strumline.botplay;
    }
}