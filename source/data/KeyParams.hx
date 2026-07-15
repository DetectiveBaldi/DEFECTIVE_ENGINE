package data;

@:structInit
class KeyParams
{
    public static function build(v:KeyParamsData):KeyParams
    {
        var keyParams:KeyParams = {keys: v.keys, strumScale: v.strumScale, strumSpacing: v.strumSpacing, controls: v.controls}

        return keyParams;
    };
    
    public var keys:Array<String>;

    public var strumScale:Float;

    public var strumSpacing:Float;

    public var controls:Array<Array<Int>>;
}

typedef KeyParamsData =
{
    public var keys:Array<String>;

    public var controls:Array<Array<Int>>;

    public var strumScale:Float;

    public var strumSpacing:Float;
}