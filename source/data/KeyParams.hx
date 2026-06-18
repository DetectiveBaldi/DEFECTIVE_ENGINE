package data;

typedef KeyParamsData =
{
    public var controls:Array<Array<Int>>;

    public var mapping:Array<String>;

    public var strumScale:Float;

    public var strumSpacing:Float;
}

@:structInit
class KeyParams
{
    public static function build(v:KeyParamsData):KeyParams
    {
        var keyParams:KeyParams = {controls: v.controls, mapping: v.mapping, strumScale: v.strumScale, strumSpacing: v.strumSpacing}

        return keyParams;
    };

    public var controls:Array<Array<Int>>;

    public var mapping:Array<String>;

    public var strumScale:Float;

    public var strumSpacing:Float;
}