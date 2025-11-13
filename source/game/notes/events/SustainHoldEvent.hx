package game.notes.events;

class SustainHoldEvent
{
    public var note:Note;

    public var sustain:Sustain;

    public var elapsed:Float;

    public function new():Void
    {

    }

    public function reset(note:Note, sustain:Sustain, elapsed:Float):Void
    {
        this.note = note;
        
        this.sustain = sustain;

        this.elapsed = elapsed;
    }
}