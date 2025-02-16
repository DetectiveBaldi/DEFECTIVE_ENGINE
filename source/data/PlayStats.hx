package data;

@:structInit
class PlayStats
{
    public var score:Int;

    public var hits:Int;

    public var misses:Int;

    public var bonus:Float;

    public var rating(get, never):Float;

    @:noCompletion
    function get_rating():Float
    {
        return bonus / (hits + misses) * 100.0;
    }
}