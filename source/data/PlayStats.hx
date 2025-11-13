package data;

using util.ArrayUtil;

@:structInit
class PlayStats
{
    public static function empty():PlayStats
    {
        return {score: 0, hits: 0, misses: 0, bonus: 0.0}
    }
    
    public var score:Int;

    public var hits:Int;

    public var misses:Int;

    public var bonus:Float;

    public var accuracy(get, never):Float;

    @:noCompletion
    function get_accuracy():Float
    {
        return bonus / (hits + misses) * 100.0;
    }
    
    public function isEmpty():Bool
    {
        return hits == 0 && misses == 0;
    }

    public function concat(stats:PlayStats):Void
    {
        score += stats.score;

        hits += stats.hits;

        misses += stats.misses;

        bonus += stats.bonus;
    }

    public function copy():PlayStats
    {
        return {score: score, hits: hits, misses: misses, bonus: bonus}
    }

    public function toString():String
    {
        return 'Score: ${score}';
    }
}