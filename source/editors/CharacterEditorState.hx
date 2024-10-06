package editors;

import haxe.Json;

import openfl.events.Event;
import openfl.events.IOErrorEvent;

import openfl.net.FileReference;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.graphics.frames.FlxAtlasFrames;

import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

import core.AssetMan;
import core.Paths;

import extendable.MusicBeatState;

import game.Character;
import game.GameState;

import game.stages.Stage;
import game.stages.Week1;

@:build(haxe.ui.ComponentBuilder.build("assets/data/editors/character.xml"))
class CharacterEditorState extends MusicBeatState
{
    public var gameCamera(get, never):FlxCamera;
    
    @:noCompletion
    function get_gameCamera():FlxCamera
    {
        return FlxG.camera;
    }

    public var gameCameraTarget:FlxObject;

    public var gameCameraZoom:Float;

    public var hudCamera:FlxCamera;

    public var hudCameraZoom:Float;

    public var stage:Stage<FlxBasic>;

    public var character:Character;

    public var fileRef:FileReference;

    override function create():Void
    {
        super.create();

        FlxG.mouse.visible = true;

        gameCamera.zoom = 0.75;

        gameCameraTarget = new FlxObject();

        gameCameraTarget.screenCenter();

        add(gameCameraTarget);

        gameCamera.follow(gameCameraTarget, LOCKON, 0.05);

        gameCameraZoom = gameCamera.zoom;

        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        FlxG.cameras.add(hudCamera, false);

        hudCameraZoom = hudCamera.zoom;

        stage = new Week1();

        for (i in 0 ... stage.members.length)
            add(stage.members[i]);

        character = new Character(0.0, 0.0, "assets/data/game/characters/BOYFRIEND", ARTIFICIAL, conductor);

        character.setPosition(FlxG.width - character.width - 15.0, 385.0);

        add(character);

        vbox.camera = hudCamera;

        textfield.text = character.data.name;

        textfield.onChange = (ev:UIEvent) ->
        {
            character.data.name = textfield.text;
        }

        button.onClick = (ev:MouseEvent) ->
        {
            character.data = Json.parse(AssetMan.text(Paths.json('assets/data/game/characters/${textfield.text}')));

            switch (character.data.format ?? "".toLowerCase():String)
            {
                case "sparrow":
                    character.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(character.data.png), true), Paths.xml(character.data.xml));

                case "texturepackerxml":
                    character.frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(character.data.png), true), Paths.xml(character.data.xml));
            }

            character.antialiasing = character.data.antialiasing ?? true;

            character.scale.set(character.data.scale?.x ?? 1.0, character.data.scale?.y ?? 1.0);

            character.updateHitbox();

            character.flipX = character.data.flipX ?? false;

            character.flipY = character.data.flipY ?? false;

            for (i in 0 ... character.data.animations.length)
            {
                if (character.data.animations[i].indices.length > 0)
                {
                    character.animation.addByIndices
                    (
                        character.data.animations[i].name,

                        character.data.animations[i].prefix,

                        character.data.animations[i].indices,

                        "",

                        character.data.animations[i].frameRate ?? 24.0,

                        character.data.animations[i].looped ?? false,

                        character.data.animations[i].flipX ?? false,

                        character.data.animations[i].flipY ?? false
                    );
                }
                else
                {
                    character.animation.addByPrefix
                    (
                        character.data.animations[i].name,

                        character.data.animations[i].prefix,

                        character.data.animations[i].frameRate ?? 24.0,

                        character.data.animations[i].looped ?? false,

                        character.data.animations[i].flipX ?? false,

                        character.data.animations[i].flipY ?? false
                    );
                }
            }

            character.danceSteps = character.data.danceSteps;

            character.danceStep = 0;

            character.danceInterval = character.data.danceInterval ?? 1.0;

            character.singDuration = character.data.singDuration ?? 8.0;

            character.skipDance = false;

            character.skipSing = false;

            character.singCount = 0.0;

            character.dance();

            checkbox.value = character.data.antialiasing ?? true;

            numberStepper.value = character.data.scale?.x ?? 1.0;

            _numberStepper.value = character.data.scale?.x ?? 1.0;

            _checkbox.value = character.data.flipX ?? false;

            __checkbox.value = character.data.flipY ?? false;

            __numberStepper.value = character.data.danceInterval ?? 1.0;

            ___numberStepper.value = character.data.danceInterval ?? 8.0;

            _textfield.text = character.data.format;

            __textfield.text = character.data.png;

            ___textfield.text = character.data.png;
        }

        checkbox.value = character.data.antialiasing ?? true;

        checkbox.onChange = (ev:UIEvent) ->
        {
            character.data.antialiasing = checkbox.value;

            character.antialiasing = character.data.antialiasing;
        }

        numberStepper.value = character.data.scale?.x ?? 1.0;

        numberStepper.onChange = (ev:UIEvent) ->
        {
            if (character.data.scale == null)
                character.data.scale = {x: 1.0, y: 1.0};

            character.data.scale.x = numberStepper.value;

            character.scale.x = character.data.scale.x;

            character.updateHitbox();
        }

        _numberStepper.value = character.data.scale?.y ?? 1.0;

        _numberStepper.onChange = (ev:UIEvent) ->
        {
            if (character.data.scale == null)
                character.data.scale = {x: 1.0, y: 1.0};

            character.data.scale.y = _numberStepper.value;

            character.scale.y = character.data.scale.y;

            character.updateHitbox();
        }

        _checkbox.value = character.data.flipX ?? false;

        _checkbox.onChange = (ev:UIEvent) ->
        {
            character.data.flipX = _checkbox.value;

            character.flipX = character.data.flipX;
        }

        __checkbox.value = character.data.flipX ?? false;

        __checkbox.onChange = (ev:UIEvent) ->
        {
            character.data.flipY = __checkbox.value;

            character.flipY = character.data.flipY;
        }

        __numberStepper.value = character.data.danceInterval ?? 1.0;

        __numberStepper.onChange = (ev:UIEvent) ->
        {
            character.data.danceInterval = __numberStepper.value;

            character.danceInterval = character.data.danceInterval;
        }

        ___numberStepper.value = character.data.singDuration ?? 8.0;

        ___numberStepper.onChange = (ev:UIEvent) ->
        {
            character.data.singDuration = ___numberStepper.value;

            character.singDuration = character.data.singDuration;
        }

        _button.onClick = (ev:MouseEvent) ->
        {
            var fileRef:FileReference = new FileReference();

            fileRef.addEventListener(Event.COMPLETE, onSave);

            fileRef.addEventListener(Event.CANCEL, onCancel);

            fileRef.addEventListener(IOErrorEvent.IO_ERROR, onIOError);

            fileRef.save(character.data, '${character.data.name}.json');
        }

        _textfield.text = character.data.format;

        __textfield.text = character.data.png;

        ___textfield.text = character.data.png;

        __button.onClick = (ev:MouseEvent) ->
        {
            if (character.data.format == _textfield.text && character.data.png == __textfield.text && character.data.xml == ___textfield.text)
                return;

            character.data.format = _textfield.text;

            character.data.png = __textfield.text;

            character.data.xml = ___textfield.text;

            switch (character.data.format ?? "".toLowerCase():String)
            {
                case "sparrow":
                    character.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(character.data.png), true), Paths.xml(character.data.xml));

                case "texturepackerxml":
                    character.frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(character.data.png), true), Paths.xml(character.data.xml));
            }
        }
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ENTER)
            FlxG.switchState(() -> new GameState());
    }

    public function onSave(ev:Event):Void
    {
        fileRef = null;
    }

    public function onCancel(ev:Event):Void
    {
        fileRef = null;
    }

    public function onIOError(io:IOErrorEvent):Void
    {
        fileRef = null;
    }
}