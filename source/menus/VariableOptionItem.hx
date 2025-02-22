package menus;

import flixel.util.FlxDestroyUtil;
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

        onUpdate.dispatch(value);

        return value;
    }

    public var onUpdate:FlxTypedSignal<(value:T)->Void>;

    public function new(_x:Float = 0.0, _y:Float = 0.0, _title:String, _description:String, _option:String):Void
    {
        super(_x, _y, _title, _description);

        option = _option;

        onUpdate = new FlxTypedSignal<(value:T)->Void>();
    }

    override function destroy():Void
    {
        super.destroy();

        onUpdate = cast FlxDestroyUtil.destroy(onUpdate);
    }
}