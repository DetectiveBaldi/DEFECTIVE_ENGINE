package editors;

import haxe.Json;

import lime.system.Clipboard;

import flixel.FlxCamera;
import flixel.FlxG;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;

import flixel.math.FlxMath;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import haxe.ui.backend.flixel.UIState;

import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

import haxe.ui.focus.FocusManager;

import core.AssetMan;
import core.Paths;

import game.Character;
import game.GameState;

import plugins.Logger;

using StringTools;

using util.ArrayUtil;

@:build(haxe.ui.ComponentBuilder.build("assets/data/editors/character.xml"))
class CharacterEditorState extends UIState
{
    public var gameCamera(get, never):FlxCamera;
    
    @:noCompletion
    function get_gameCamera():FlxCamera
    {
        return FlxG.camera;
    }

    public var hudCamera:FlxCamera;

    public var character:Character;

    public var animationIndex:Int;

    override function create():Void
    {
        super.create();

        FlxG.mouse.visible = true;

        gameCamera.zoom = 0.75;

        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        FlxG.cameras.add(hudCamera, false);

        var background:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(32, 32, 64, 64, true, 0xFFE7E6E6, 0xFFD9D5D5));

        add(background);

        character = new Character(0.0, 0.0, "assets/data/game/characters/BOYFRIEND", ARTIFICIAL, null);

        character.screenCenter();

        add(character);

        animationIndex = character.data.animations.indexOf(character.data.animations.getFirst((animation:CharacterFrameSet) -> character.animation.name == animation.name));

        root.camera = hudCamera;

        refreshMainTab();

        textfield.onChange = (ev:UIEvent) -> character.data.name = textfield.text;

        button.onClick = (ev:MouseEvent) ->
        {
            #if html5
                new openfl.net.FileReference().save(Json.stringify(character.data), Paths.json(character.data.name));

                Logger.logInfo('Character saved to "${Paths.json(character.data.name)}".');
            #else
                sys.io.File.saveContent(Paths.json('assets/data/game/characters/${character.data.name}'), Json.stringify(character.data));

                Logger.logInfo('Character saved to "${Paths.json('assets/data/game/characters/${character.data.name}')}".');
            #end
        }

        _button.onClick = (ev:MouseEvent) ->
        {
            if (!Paths.exists(Paths.json('assets/data/game/characters/${textfield.text}')))
            {
                Logger.logError("The requested file(s) do not exist!");

                return;
            }

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

            character.screenCenter();

            character.flipX = character.data.flipX ?? false;

            character.flipY = character.data.flipY ?? false;

            for (i in 0 ... character.data.animations.length)
            {
                var _animation:CharacterFrameSet = character.data.animations[i];
    
                if (character.animation.exists(_animation.name))
                    throw "game.Character: Invalid animation name!";
    
                if (_animation.indices.length > 0)
                {
                    character.animation.addByIndices
                    (
                        _animation.name,
    
                        _animation.prefix,
    
                        _animation.indices,
    
                        "",
    
                        _animation.frameRate ?? 24.0,
    
                        _animation.looped ?? false,
    
                        _animation.flipX ?? false,
    
                        _animation.flipY ?? false
                    );
                }
                else
                {
                    character.animation.addByPrefix
                    (
                        _animation.name,
    
                        _animation.prefix,
    
                        _animation.frameRate ?? 24.0,
    
                        _animation.looped ?? false,
    
                        _animation.flipX ?? false,
    
                        _animation.flipY ?? false
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

            refreshMainTab();

            refreshAssetsTab();

            refreshAnimationsTab();
        }

        checkbox.onChange = (ev:UIEvent) ->
        {
            character.data.antialiasing = checkbox.value;

            character.antialiasing = character.data.antialiasing;
        }

        numberStepper.onChange = (ev:UIEvent) ->
        {
            if (character.data.scale == null)
                character.data.scale = {x: 1.0, y: 1.0};

            character.data.scale.x = numberStepper.value;

            character.scale.x = character.data.scale.x;

            character.updateHitbox();

            character.screenCenter();
        }

        _numberStepper.onChange = (ev:UIEvent) ->
        {
            if (character.data.scale == null)
                character.data.scale = {x: 1.0, y: 1.0};

            character.data.scale.y = _numberStepper.value;

            character.scale.y = character.data.scale.y;

            character.updateHitbox();

            character.screenCenter();
        }

        _checkbox.onChange = (ev:UIEvent) ->
        {
            character.data.flipX = _checkbox.value;

            character.flipX = character.data.flipX;
        }

        __checkbox.onChange = (ev:UIEvent) ->
        {
            character.data.flipY = __checkbox.value;

            character.flipY = character.data.flipY;
        }

        _textfield.onChange = (ev:UIEvent) ->
        {
            if (_textfield.text.length < 1)
                return;
            
            character.data.danceSteps = _textfield.text.split(",");

            character.danceSteps = _textfield.text.split(",");

            character.danceStep = 0;
        };

        __numberStepper.onChange = (ev:UIEvent) ->
        {
            character.data.danceInterval = __numberStepper.value;

            character.danceInterval = character.data.danceInterval;
        }

        ___numberStepper.onChange = (ev:UIEvent) ->
        {
            character.data.singDuration = ___numberStepper.value;

            character.singDuration = character.data.singDuration;
        }

        refreshAssetsTab();

        __button.onClick = (ev:MouseEvent) ->
        {
            if (character.data.format == __textfield.text && character.data.png == ___textfield.text && character.data.xml == ____textfield.text)
            {
                Logger.logError("The requested format and file(s) are in use!");
                
                return;
            }

            if (!Paths.exists(Paths.png(___textfield.text)) || !Paths.exists(Paths.xml(____textfield.text)))
            {
                Logger.logError("The requested file(s) do not exist!");

                return;
            }

            character.data.format = __textfield.text;

            character.data.png = ___textfield.text;

            character.data.xml = ____textfield.text;

            switch (character.data.format ?? "".toLowerCase():String)
            {
                case "sparrow":
                    character.frames = FlxAtlasFrames.fromSparrow(AssetMan.graphic(Paths.png(character.data.png), true), Paths.xml(character.data.xml));

                case "texturepackerxml":
                    character.frames = FlxAtlasFrames.fromTexturePackerXml(AssetMan.graphic(Paths.png(character.data.png), true), Paths.xml(character.data.xml));
            }

            character.animation.destroyAnimations();

            character.updateHitbox();

            character.screenCenter();

            tabview.selectedPage = __box;
        }

        refreshAnimationsTab();

        ___button.onClick = (ev:MouseEvent) -> saveAnimation();

        ____button.onClick = (ev:MouseEvent) -> deleteAnimation();

        _____button.onClick = (ev:MouseEvent) ->
        {
            var animation:CharacterFrameSet = character.data.animations[animationIndex];

            Clipboard.text = Json.stringify(animation.offset);

            Logger.logInfo("Current animation offset copied to clipboard.");
        }

        ______button.onClick = (ev:MouseEvent) ->
        {
            var animation:CharacterFrameSet = character.data.animations[animationIndex];

            var offset:Null<{?x:Null<Float>, ?y:Null<Float>}> = Json.parse(Clipboard.text);

            setFrameSetOffset(animation, offset?.x ?? 0.0, offset?.y ?? 0.0);

            Logger.logInfo("Copied offset successfully applied to current animation.");
        }
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FocusManager.instance.focus == null)
        {
            if (FlxG.keys.justPressed.W)
                animationIndex = FlxMath.wrap(animationIndex - 1, 0, character.data.animations.length - 1);

            if (FlxG.keys.justPressed.S)
                animationIndex = FlxMath.wrap(animationIndex + 1, 0, character.data.animations.length - 1);

            var animation:CharacterFrameSet = character.data.animations[animationIndex];

            if (FlxG.keys.justPressed.UP)
                addFrameSetOffset(animation, 0.0, FlxG.keys.pressed.SHIFT ? -10.0 : -1.0);

            if (FlxG.keys.justPressed.LEFT)
                addFrameSetOffset(animation, FlxG.keys.pressed.SHIFT ? -10.0 : -1.0, 0.0);

            if (FlxG.keys.justPressed.DOWN)
                addFrameSetOffset(animation, 0.0, FlxG.keys.pressed.SHIFT ? 10.0 : 1.0);

            if (FlxG.keys.justPressed.RIGHT)
                addFrameSetOffset(animation, FlxG.keys.pressed.SHIFT ? 10.0 : 1.0, 0.0);

            if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S || FlxG.keys.justPressed.SPACE)
            {
                character.animation.play(animation.name, true);

                refreshAnimationsTab();
            }

            if (FlxG.keys.justPressed.ENTER)
                FlxG.switchState(() -> new GameState());
        }
        else
        {
            if (FlxG.keys.justPressed.ENTER)
                FocusManager.instance.focus = null;
        }
    }

    override function destroy():Void
    {
        super.destroy();

        FlxG.mouse.visible = false;

        AssetMan.clearCache();
    }

    public function refreshMainTab():Void
    {
        textfield.text = character.data.name;

        checkbox.value = character.data.antialiasing ?? true;

        numberStepper.value = character.data.scale?.x ?? 1.0;

        _numberStepper.value = character.data.scale?.y ?? 1.0;

        _checkbox.value = character.data.flipX ?? false;

        __checkbox.value = character.data.flipY ?? false;

        _textfield.text = character.data.danceSteps.toString();
        
        #if !html5
           _textfield.text = _textfield.text.substring(1, _textfield.text.length - 1);
        #end

        __numberStepper.value = character.data.danceInterval ?? 1.0;

        ___numberStepper.value = character.data.singDuration ?? 8.0;
    }

    public function refreshAssetsTab():Void
    {
        __textfield.text = character.data.format;

        ___textfield.text = character.data.png;

        ____textfield.text = character.data.xml;
    }

    public function refreshAnimationsTab():Void
    {
        var animation:CharacterFrameSet = character.data.animations[animationIndex];

        _____textfield.text = animation.name ?? "";

        ______textfield.text = animation.prefix ?? "";

        textarea.text = animation.indices?.toString() ?? new Array<Int>().toString();

        #if !html5
            textarea.text = textarea.text.substring(1, textarea.text.length - 1);
        #end

        ____numberStepper.value = animation.frameRate ?? 24.0;

        ___checkbox.value = animation.looped ?? false;

        ____checkbox.value = animation.flipX ?? false;

        _____checkbox.value = animation.flipY ?? false;

        _____________label.text = 'Offset: (${animation.offset?.x ?? 0.0}, ${animation.offset?.y ?? 0.0})';
    }

    public function saveAnimation():Void
    {
        var frames:Array<FlxFrame> = new Array<FlxFrame>();

        @:privateAccess
            character.animation.findByPrefix(frames, ______textfield.text);
        
        if (frames.length <= 0.0)
        {
            Logger.logError("Invalid frames detected!");

            return;
        }

        var indices:Array<String> = textarea.text.split(",");

        var _indices:Array<Int> = new Array<Int>();

        if (textarea.text.length > 0)
        {
            for (i in 0 ... indices.length)
                _indices.push(Std.parseInt(indices[i]));
        }

        var animation:CharacterFrameSet = character.data.animations.getFirst((animation:CharacterFrameSet) -> _____textfield.text == animation.name);

        if (animation == null)
        {
            character.data.animations.push
            ({
                name: _____textfield.text,

                prefix: ______textfield.text,

                indices: _indices,

                frameRate: ____numberStepper.value,

                looped: ___checkbox.value,

                flipX: ____checkbox.value,

                flipY: _____checkbox.value
            });

            animationIndex = character.data.animations.length - 1;

            animation = character.data.animations.getFirst((animation:CharacterFrameSet) -> _____textfield.text == animation.name);
        }
        else
        {
            animation.prefix = ______textfield.text;

            animation.indices = _indices;

            animation.frameRate = ____numberStepper.value;

            animation.looped = ___checkbox.value;

            animation.flipX = ____checkbox.value;

            animation.flipY = _____checkbox.value;
        }

        if (_indices.length > 0.0)
            character.animation.addByIndices(animation.name, animation.prefix, animation.indices, "", animation.frameRate, animation.looped, animation.flipX, animation.flipY);
        else
            character.animation.addByPrefix(animation.name, animation.prefix, animation.frameRate, animation.looped, animation.flipX, animation.flipY);

        character.animation.play(animation.name, true);

        refreshAnimationsTab();

        Logger.logInfo('Saved "${animation.name}"!');
    }

    public function deleteAnimation():Void
    {
        if (character.data.animations.length <= 1.0)
        {
            Logger.logError("You must have at least one animation!");

            return;
        }

        var animation:CharacterFrameSet = character.data.animations[animationIndex];

        character.data.animations.remove(animation);

        if (character.animation.exists(animation.name))
            character.animation.remove(animation.name);

        animationIndex = 0;

        animation = character.data.animations[animationIndex];

        if (character.data.animations.length > 0.0)
            character.animation.play(animation.name, true);
        else
            character.animation.destroyAnimations();

        refreshAnimationsTab();

        Logger.logInfo('Deleted "${animation.name}"!');
    }

    public function setFrameSetOffset(animation:CharacterFrameSet, x:Float = 0.0, y:Float = 0.0):Void
    {
        if (animation.offset == null)
            animation.offset = {x: 0.0, y: 0.0};

        animation.offset.x = x;

        animation.offset.y = y;

        _____________label.text = 'Offset: (${animation.offset?.x ?? 0.0}, ${animation.offset?.y ?? 0.0})';
    }

    public function addFrameSetOffset(animation:CharacterFrameSet, x:Float = 0.0, y:Float = 0.0):Void
    {
        if (animation.offset == null)
            animation.offset = {x: 0.0, y: 0.0};

        setFrameSetOffset(animation, animation.offset.x + x, animation.offset.y + y);
    }
}