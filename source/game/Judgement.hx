package game;

class Judgement
{
    public var name:String;

    public var timing:Float;

    public var bonus:Float;

    public var health:Float;

    public var points:Int;

    public var hits:Int;

    public static function guage(judgements:Array<Judgement>, timing:Float):Judgement
    {
        for (i in 0 ... judgements.length)
        {
            var judgement:Judgement = judgements[i];

            if (timing <= judgement.timing)
                return judgement;
        }

        return null;
    }

    public function new(name:String, timing:Float, bonus:Float, health:Float, points:Int, hits:Int):Void
    {
        this.name = name;

        this.timing = timing;

        this.bonus = bonus;

        this.health = health;

        this.points = points;

        this.hits = hits;
    }
}