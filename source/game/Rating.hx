package game;

using util.ArrayUtil;

@:structInit
class Rating
{
    public static var list:Array<Rating> =
    [
        {name: "Sick!", timing: 45.0, bonus: 1.0},

        {name: "Good", timing: 90.0, bonus: 0.9},

        {name: "Bad", timing: 135.0, bonus: 0.60},

        {name: "Shit", timing: 166.6, bonus: 0.50},
    ];

    static var _earliestTiming:Null<Float> = null;

    public static var earliestTiming(get, never):Float;

    @:noCompletion
    static function get_earliestTiming():Float
    {
       if (_earliestTiming == null)
            _earliestTiming = list[0].timing;

        return _earliestTiming;
    }

    static var _latestTiming:Null<Float> = null;

    public static var latestTiming(get, never):Float;

    @:noCompletion
    static function get_latestTiming():Float
    {
        if (_latestTiming == null)
            _latestTiming = list.last().timing;

        return _latestTiming;
    }

    public static function fromTiming(timing:Float):Rating
    {
        for (i in 0 ... list.length - 1)
        {
            var rating:Rating = list[i];

            if (timing <= rating.timing)
                return rating;
        }

        return list.last();
    }
    
    public var name:String;

    public var timing:Float;

    public var bonus:Float;
}