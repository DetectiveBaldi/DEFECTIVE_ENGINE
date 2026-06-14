package game;

using util.ArrayUtil;

@:structInit
class Rating
{
    public static var list:Array<Rating> =
    [
        {name: "Sick!", timing: 45.0, bonus: 1.0, health: 1.0},

        {name: "Good", timing: 90.0, bonus: 0.65, health: 0.5},

        {name: "Bad", timing: 135.0, bonus: 0.35, health: 0.0},

        {name: "Shit", timing: 166.6, bonus: 0.0, health: -1.0},
    ];

    public static var earliestTiming(get, never):Float;

    @:noCompletion
    static function get_earliestTiming():Float
    {
        static var v:Float = 0.0;

        if (v == 0.0)
            v = list[0].timing;

        return v;
    }

    public static var latestTiming(get, never):Float;

    @:noCompletion
    static function get_latestTiming():Float
    {
        static var v:Float = 0.0;

        if (v == 0.0)
            v = list.last().timing;

        return v;
    }
    
    public var name:String;

    public var timing:Float;

    public var bonus:Float;

    public var health:Float;

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
}