package interfaces;

import music.Conductor;

interface IBeatDispatcher
{
    public var conductor:Conductor;

    public function stepHit(step:Int):Void;

    public function beatHit(beat:Int):Void;

    public function measureHit(measure:Int):Void;
}