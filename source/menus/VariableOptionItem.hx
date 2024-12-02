package menus;

import flixel.util.FlxSignal.FlxTypedSignal;

import core.Options;

class VariableOptionItem<T> extends BaseOptionItem
{
    public var option:String;

    public var value(get, set):T;

    @:noCompletion
    function get_value():T
    {
        return Reflect.getProperty(Options, option);
    }

    @:noCompletion
    function set_value(_value:T):T
    {
        Reflect.setProperty(Options, option, _value);

        onUpdate.dispatch(_value);

        return value;
    }

    public var onUpdate:FlxTypedSignal<(value:T)->Void>;

    public function new(x:Float = 0.0, y:Float = 0.0, name:String, description:String, option:String):Void
    {
        super(x, y, name, description);

        this.option = option;

        onUpdate = new FlxTypedSignal<(value:T)->Void>();
    }
}