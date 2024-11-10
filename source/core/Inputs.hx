package core;

import flixel.FlxG;

import flixel.input.FlxInput.FlxInputState;

class Inputs
{
    public static function checkStatus(input:Input, status:FlxInputState):Bool
    {
        @:privateAccess
            return FlxG.keys.checkKeyArrayState(input.codes, status);
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
    public var codes:Array<Int>;

    public function new(codes:Array<Int>):Void
    {
        this.codes = codes;
    }
}