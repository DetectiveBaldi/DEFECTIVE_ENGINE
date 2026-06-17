package data;

typedef KeyParamsData =
{
    public var controls:Array<Array<Int>>;

    public var mapping:Array<String>;

    public var noteScale:Float;

    public var noteSpacing:Float;
}

@:structInit
class KeyParams
{
    public static function build(v:KeyParamsData):KeyParams
    {
        var keyParams:KeyParams = {controls: v.controls, mapping: v.mapping, noteScale: v.noteScale, noteSpacing: v.noteSpacing};

        return keyParams;
    };

    public var controls:Array<Array<Int>>;

    public var mapping:Array<String>;

    public var noteScale:Float;

    public var noteSpacing:Float;
}