package game;

using tools.ArrayTools;

@:structInit
class Rating
{
    public static var list:Array<Rating> =
    [
        {name: "Sick", hitWindow: 45.0, bonus: 1.0},

        {name: "Good", hitWindow: 90.0, bonus: 0.9},

        {name: "Bad", hitWindow: 135.0, bonus: 0.60},

        {name: "Shit", hitWindow: 166.6, bonus: 0.50},
    ];

    static var _earliestTiming:Null<Float> = null;

    public static var earliestTiming(get, never):Float;

    @:noCompletion
    static function get_earliestTiming():Float
    {
       if (_earliestTiming == null)
            _earliestTiming = list[0].hitWindow;

        return _earliestTiming;
    }

    static var _latestTiming:Null<Float> = null;

    public static var latestTiming(get, never):Float;

    @:noCompletion
    static function get_latestTiming():Float
    {
        if (_latestTiming == null)
            _latestTiming = list.last().hitWindow;

        return _latestTiming;
    }

    public static function fromTime(time:Float):Rating
    {
        for (i in 0 ... list.length)
        {
            var rating:Rating = list[i];

            if (time <= rating.hitWindow)
                return rating;
        }

        return list.last();
    }
    
    public var name:String;

    public var hitWindow:Float;

    public var bonus:Float;
}