package interfaces;

import flixel.tweens.FlxTween.FlxTweenManager;

import flixel.util.FlxTimer.FlxTimerManager;

interface ISequenceHandler
{
    public var tweens:FlxTweenManager;

    public var timers:FlxTimerManager;
}