package menus.options.items;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal.FlxTypedSignal;

import core.Options;
import core.SaveManager;

class VarOptionItem<T> extends BaseOptionItem
{
    public var option:String;

    public var value:T;

    public var onUpdate:FlxTypedSignal<(newValue:T)->Void>;

    public function new(x:Float = 0.0, y:Float = 0.0, title:String, description:String, option:String):Void
    {
        super(x, y, title, description);

        this.option = option;

        value = getValue();

        onUpdate = new FlxTypedSignal<(newValue:T)->Void>();
    }

    override function destroy():Void
    {
        super.destroy();

        onUpdate = cast FlxDestroyUtil.destroy(onUpdate);
    }

    public function getValue():T
    {
        return Reflect.getProperty(Options, option);
    }

    public function setValue(value:T):Void
    {
        this.value = value;

        Reflect.setProperty(Options, option, value);

        SaveManager.saveOptions();

        onUpdate.dispatch(value);
    }
}