package game.notes.events;

class SustainHoldEvent
{
    public var note:Note;

    public var sustain:Sustain;

    public function new():Void
    {

    }

    public function reset(note:Note, sustain:Sustain):Void
    {
        this.note = note;
        
        this.sustain = sustain;
    }
}