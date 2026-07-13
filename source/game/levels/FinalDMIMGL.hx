package game.levels;

import game.notes.Note;
import game.notes.events.NoteHitEvent;

class FinalDMIMGL extends FinalDL
{
    override function create():Void
    {
        super.create();

        oppStrumline.onNoteHit.add(opponentNoteHit);

        oppStrumline.onNoteMiss.add(opponentNoteMiss);
    }

    public function opponentNoteHit(ev:NoteHitEvent):Void
    {
        var note:Note = ev.note;

        if (note.kind.type != "caution")
            return;

        var health:Float = playField.healthBar.value;

        playField.healthBar.value = Math.min(health, Math.max(health - 2.0, 2.0));
    }

    public function opponentNoteMiss(note:Note):Void
    {
        if (note.kind.type != "death" && note.kind.type != "hurt")
            return;

        var health:Float = playField.healthBar.value;

        playField.healthBar.value = Math.min(health, Math.max(health - 2.0, 2.0));
    }
}