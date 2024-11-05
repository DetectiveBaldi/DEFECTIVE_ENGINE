package core;

import flixel.FlxG;

import flixel.input.FlxInput.FlxInputState;

import flixel.input.keyboard.FlxKey;

class Inputs
{
    public static function checkStatus(input:Input, status:FlxInputState):Bool
    {
        for (i in 0 ... input.keys.length)
        {
            if (FlxG.keys.checkStatus(input.keys[i], status))
                return true;
        }

        return false;
    }

    public static function inputsJustPressed(inputs:Array<Input>):Bool
    {
        for (i in 0 ... inputs.length)
        {
            if (checkStatus(inputs[i], JUST_PRESSED))
                return true;
        }

        return false;
    }

    public static function inputsPressed(inputs:Array<Input>):Bool
    {
        for (i in 0 ... inputs.length)
        {
            if (checkStatus(inputs[i], PRESSED))
                return true;
        }

        return false;
    }

    public static function inputsJustReleased(inputs:Array<Input>):Bool
    {
        for (i in 0 ... inputs.length)
        {
            if (checkStatus(inputs[i], JUST_RELEASED))
                return true;
        }

        return false;
    }

    public static function inputsReleased(inputs:Array<Input>):Bool
    {
        for (i in 0 ... inputs.length)
        {
            if (checkStatus(inputs[i], RELEASED))
                return true;
        }

        return false;
    }
}

class Input
{
    public var name:String;

    public var keys:Array<FlxKey>;

    public function new(name:String, keys:Array<FlxKey>):Void
    {
        this.name = name;

        this.keys = keys;
    }
}