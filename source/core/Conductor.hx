package core;

import flixel.util.FlxSignal;

class Conductor
{
    public static var current(default, null):Conductor;

    public var currentSection(default, null):Int;

    public var currentBeat(default, null):Int;

    public var currentStep(default, null):Int;

    public var sectionHit:FlxSignal;

    public var beatHit:FlxSignal;

    public var stepHit:FlxSignal;

    public var tempo:Float;

    public var crotchet(get, never):Float;

    @:noCompletion
    function get_crotchet():Float
    {
        return (60 / tempo) * 1000;
    }

    public var time:Float;

    public function new():Void
    {
        currentSection = -1;

        currentBeat = -1;

        currentStep = -1;

        sectionHit = new FlxSignal();

        beatHit = new FlxSignal();

        stepHit = new FlxSignal();

        tempo = 100.0;

        time = 0.0;
    }

    public static function initiate():Void
    {
        Conductor.current = new Conductor();
    }

    public function calculate():Void
    {
        var lastSection:Int = currentSection;

        var lastBeat:Int = currentBeat;

        var lastStep:Int = currentStep;

        currentSection = Math.floor((time / crotchet) * 0.25);

        currentBeat = Math.floor(time / crotchet);

        currentStep = Math.floor((time / crotchet) * 4);

        if (currentSection != lastSection)
        {
            sectionHit.dispatch();
        }

        if (currentBeat != lastBeat)
        {
            beatHit.dispatch();
        }

        if (currentStep != lastStep)
        {
            stepHit.dispatch();
        }
    }

    public function reset():Void
    {
        currentSection = -1;

        currentBeat = -1;

        currentStep = -1;

        sectionHit = new FlxSignal();

        beatHit = new FlxSignal();

        stepHit = new FlxSignal();

        tempo = 100.0;

        time = 0.0;
    }
}