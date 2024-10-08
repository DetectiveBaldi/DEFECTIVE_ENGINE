package editors;

import haxe.Json;

import openfl.net.FileReference;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.math.FlxMath;

import flixel.text.FlxText;

import flixel.util.FlxColor;

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

    public var messages:FlxTypedContainer<FlxText>;

    public var character:Character;

    public var animationIndex:Int;

    public var fileRef:FileReference;

    override function create():Void
    {
        super.create();

        FlxG.mouse.visible = true;

        gameCamera.zoom = 0.75;

        hudCamera = new FlxCamera();

        hudCamera.bgColor.alpha = 0;

        FlxG.cameras.add(hudCamera, false);

        messages = new FlxTypedContainer<FlxText>();

        messages.camera = hudCamera;

        add(messages);

        var background:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(32, 32, 64, 64, true, 0xFFE7E6E6, 0xFFD9D5D5));

        add(background);

        character = new Character(0.0, 0.0, "assets/data/game/characters/BOYFRIEND", ARTIFICIAL, null);

        character.screenCenter();

        add(character);

        animationIndex = character.data.animations.indexOf(character.data.animations.getFirst((animation:CharacterAnimationData) -> character.animation.name == animation.name));

        vbox.camera = hudCamera;

        refreshMainTab();

        textfield.onChange = (ev:UIEvent) ->
        {
            character.data.name = textfield.text;
        }

        button.onClick = (ev:MouseEvent) ->
        {
            if (!Paths.exists(Paths.json('assets/data/game/characters/${textfield.text}')))
            {
                var warn:FlxText = message("The requested character file could not be located!");

                warn.color = FlxColor.RED;

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

        _button.onClick = (ev:MouseEvent) ->
        {
            fileRef = new FileReference();

            fileRef.save(Json.stringify(character.data), Paths.json(character.data.name));
        }

        refreshAssetsTab();

        __button.onClick = (ev:MouseEvent) ->
        {
            if (character.data.format == __textfield.text && character.data.png == ___textfield.text && character.data.xml == ____textfield.text)
                return;

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

            clearAnimations();

            character.screenCenter();

            tabview.selectedPage = __box;
        }

        ___button.onClick = (ev:MouseEvent) -> saveAnimation();

        ____button.onClick = (ev:MouseEvent) -> deleteAnimation();

        _____button.onClick = (ev:MouseEvent) -> clearAnimations();

        refreshAnimationsTab();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var i:Int = messages.members.length - 1;

        while (i >= 0.0)
        {
            var msg:FlxText = messages.members[i];

            if (!msg.isOnScreen())
                messages.remove(msg, true).destroy();

            i--;
        }

        if (character.data.animations.length > 0.0)
        {
            if (FlxG.keys.justPressed.W && FocusManager.instance.focus == null)
                character.animation.play(character.data.animations[animationIndex = FlxMath.wrap(animationIndex - 1, 0, character.data.animations.length - 1)].name, true);

            if (FlxG.keys.justPressed.S && FocusManager.instance.focus == null)
                character.animation.play(character.data.animations[animationIndex = FlxMath.wrap(animationIndex - 1, 0, character.data.animations.length - 1)].name, true);

            if (FlxG.keys.justPressed.UP && FocusManager.instance.focus == null)
                offsetAnimation(0.0, FlxG.keys.pressed.SHIFT ? -10.0 : -1.0);

            if (FlxG.keys.justPressed.LEFT && FocusManager.instance.focus == null)
                offsetAnimation(FlxG.keys.pressed.SHIFT ? -10.0 : -1.0, 0.0);

            if (FlxG.keys.justPressed.DOWN && FocusManager.instance.focus == null)
                offsetAnimation(0.0, FlxG.keys.pressed.SHIFT ? 10.0 : 1.0);

            if (FlxG.keys.justPressed.RIGHT && FocusManager.instance.focus == null)
                offsetAnimation(FlxG.keys.pressed.SHIFT ? 10.0 : 1.0, 0.0);

            if (FlxG.keys.justPressed.SPACE && FocusManager.instance.focus == null)
                character.animation.play(character.data.animations[animationIndex].name, true);

            if (FlxG.keys.anyJustPressed([W, S, SPACE]) && FocusManager.instance.focus == null)
                refreshAnimationsTab();
        }

        if (FlxG.keys.justPressed.ENTER && FocusManager.instance.focus == null)
            FlxG.switchState(() -> new GameState());
    }

    override function destroy():Void
    {
        super.destroy();

        AssetMan.clearCache();
    }

    public function message(content:String):FlxText
    {
        var output:FlxText = new FlxText(0.0, 0.0, FlxG.width, content, 24);

        output.setBorderStyle(SHADOW, FlxColor.BLACK, 3.5);

        output.moves = true;

        output.acceleration.set(0.0, 550.0);

        output.velocity.set(-FlxG.random.int(0, 100), -FlxG.random.int(0, 100));

        output.setPosition(50.0, 450.0);

        messages.add(output);

        return output;
    }

    public function refreshMainTab():Void
    {
        textfield.text = character.data.name;

        checkbox.value = character.data.antialiasing ?? true;

        numberStepper.value = character.data.scale?.x ?? 1.0;

        _numberStepper.value = character.data.scale?.x ?? 1.0;

        _checkbox.value = character.data.flipX ?? false;

        __checkbox.value = character.data.flipY ?? false;

        _textfield.text = character.data.danceSteps.toString();
        
        #if !html5
           _textfield.text = _textfield.text.substring(1, _textfield.text.length - 1);
        #end

        __numberStepper.value = character.data.danceInterval ?? 1.0;

        ___numberStepper.value = character.data.danceInterval ?? 8.0;
    }

    public function refreshAssetsTab():Void
    {
        __textfield.text = character.data.format;

        ___textfield.text = character.data.png;

        ____textfield.text = character.data.xml;
    }

    public function refreshAnimationsTab():Void
    {
        _________label.text = 'Offsets: (${character.data.animations[animationIndex]?.offsets?.x ?? 0.0}, ${character.data.animations[animationIndex]?.offsets?.y ?? 0.0})';

        _____textfield.text = character.data.animations[animationIndex]?.name ?? "";

        ______textfield.text = character.data.animations[animationIndex]?.prefix ?? "";

        _______textfield.text = character.data.animations[animationIndex]?.indices?.toString() ?? new Array<Int>().toString();

        _______textfield.text = _______textfield.text.substring(1, _______textfield.text.length - 1);

        ____numberStepper.value = character.data.animations[animationIndex]?.frameRate ?? 24.0;

        ___checkbox.value = character.data.animations[animationIndex]?.looped ?? false;

        ____checkbox.value = character.data.animations[animationIndex]?.flipX ?? false;

        _____checkbox.value = character.data.animations[animationIndex]?.flipY ?? false;
    }

    public function saveAnimation():Void
    {
        var animation:CharacterAnimationData = character.data.animations.getFirst((animation:CharacterAnimationData) -> _____textfield.text == animation.name);

        var indices:Array<Int> = new Array<Int>();

        if (_______textfield.text.length > 0)
            indices = _______textfield.text.split(",").map(Std.parseInt);

        if (animation == null)
        {
            character.data.animations.push
            ({
                name: _____textfield.text,

                prefix: ______textfield.text,

                indices: indices,

                frameRate: ____numberStepper.value,

                looped: ___checkbox.value,

                flipX: ____checkbox.value,

                flipY: _____checkbox.value
            });

            animation = character.data.animations.getFirst((animation:CharacterAnimationData) -> _____textfield.text == animation.name);
        }
        else
        {
            animation.prefix = ______textfield.text;

            animation.indices = indices;

            animation.frameRate = ____numberStepper.value;

            animation.looped = ___checkbox.value;

            animation.flipX = ____checkbox.value;

            animation.flipY = _____checkbox.value;
        }

        if (indices.length > 0)
            character.animation.addByIndices(animation.name, animation.prefix, animation.indices, "", animation.frameRate, animation.looped, animation.flipX, animation.flipY);
        else
            character.animation.addByPrefix(animation.name, animation.prefix, animation.frameRate, animation.looped, animation.flipX, animation.flipY);

        character.animation.play(animation.name, true);

    }

    public function deleteAnimation():Void
    {
        if (character.data.animations.length <= 0.0)
        {
            var warn:FlxText = message("No animation to delete!");

            warn.color = FlxColor.RED;

            return;
        }

        var animation:CharacterAnimationData = character.data.animations[animationIndex];

        character.data.animations.remove(animation);

        if (character.animation.exists(animation.name))
            character.animation.remove(animation.name);

        animationIndex = 0;

        if (character.data.animations.length > 0.0)
            character.animation.play(character.data.animations[animationIndex].name);
        else
            character.animation.destroyAnimations();

        refreshAnimationsTab();
    }

    public function clearAnimations():Void
    {
        if (character.data.animations.length <= 0.0)
        {
            var warn:FlxText = message("No animations to clear!");

            warn.color = FlxColor.RED;

            return;
        }

        var i:Int = character.data.animations.length - 1;

        while (i >= 0.0)
        {
            deleteAnimation();

            i--;
        }
    }

    public function offsetAnimation(x:Float = 0.0, y:Float = 0.0):Void
    {
        var animation:CharacterAnimationData = character.data.animations[animationIndex];

        if (animation.offsets == null)
            animation.offsets = {x: 0.0, y: 0.0};

        animation.offsets.x += x;

        animation.offsets.y += y;

        _________label.text = 'Offsets: (${character.data.animations[animationIndex]?.offsets?.x ?? 0.0}, ${character.data.animations[animationIndex]?.offsets?.y ?? 0.0})';
    }
}