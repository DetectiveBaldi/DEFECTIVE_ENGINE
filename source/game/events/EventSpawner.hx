package game.events;

import flixel.FlxBasic;

import game.Chart.LoadedEvent;

class EventSpawner extends FlxBasic
{
    public var game:GameState;

    public var chart(get, never):Chart;

    @:noCompletion
        function get_chart():Chart
        {
            return game.chart;
        }

    public var eventIndex:Int;

    public function new(_game:GameState):Void
    {
        super();

        visible = false;

        game = _game;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        while (eventIndex < chart.events.length)
        {
            var event:LoadedEvent = chart.events[eventIndex];

            if (game.conductor.time < event.time)
                break;

            switch (event.name:String)
            {
                case "Camera Follow":
                    CameraFollowEvent.spawn(game, event.value.x ?? 0.0, event.value.y ?? 0.0, event.value.characterMap ?? "", event.value.character ?? "", event.value.duration ?? -1.0, event.value.ease ?? "linear");

                case "Camera Zoom":
                    CameraZoomEvent.spawn(game, event.value.camera, event.value.zoom, event.value.duration, event.value.ease);

                case "Speed Change":
                    SpeedChangeEvent.spawn(game, event.value.speed, event.value.duration, event.value.ease);
            }

            eventIndex++;
        }
    }
}