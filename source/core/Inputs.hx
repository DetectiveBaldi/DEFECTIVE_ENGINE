package core;

import flixel.FlxG;

import flixel.input.FlxInput.FlxInputState;

import flixel.input.keyboard.FlxKey;

class Inputs
{
    public static var list:Map<String, Array<FlxKey>> =
    [
        "NOTE:LEFT" => [FlxKey.Z, FlxKey.A, FlxKey.LEFT],

        "NOTE:DOWN" => [FlxKey.X, FlxKey.S, FlxKey.DOWN],

        "NOTE:UP" => [FlxKey.PERIOD, FlxKey.W, FlxKey.UP],

        "NOTE:RIGHT" => [FlxKey.SLASH, FlxKey.D, FlxKey.RIGHT],

        "DEBUG:0" => [FlxKey.SEVEN]
    ];

    public static function checkStatus(input:String, status:FlxInputState):Null<Bool>
    {
        if (!list.exists(input))
            return null;

        for (i in 0 ... list[input].length)
        {
            if (FlxG.keys.checkStatus(list[input][i], status))
                return true;
        }

        return false;
    }

    public static function inputsJustPressed(inputs:Array<String>):Null<Bool>
    {
        for (i in 0 ... inputs.length)
        {
            var input:String = inputs[i];

            if (!list.exists(input))
                return null;

            if (checkStatus(input, JUST_PRESSED))
                return true;
        }

        return false;
    }

    public static function inputsPressed(inputs:Array<String>):Null<Bool>
    {
        for (i in 0 ... inputs.length)
        {
            var input:String = inputs[i];

            if (!list.exists(input))
                return null;

            if (checkStatus(input, PRESSED))
                return true;
        }

        return false;
    }

    public static function inputsJustReleased(inputs:Array<String>):Null<Bool>
    {
        for (i in 0 ... inputs.length)
        {
            var input:String = inputs[i];

            if (!list.exists(input))
                return null;

            if (checkStatus(input, JUST_RELEASED))
                return true;
        }

        return false;
    }

    public static function inputsReleased(inputs:Array<String>):Null<Bool>
    {
        for (i in 0 ... inputs.length)
        {
            var input:String = inputs[i];

            if (!list.exists(input))
                return null;

            if (checkStatus(input, RELEASED))
                return true;
        }

        return false;
    }
}