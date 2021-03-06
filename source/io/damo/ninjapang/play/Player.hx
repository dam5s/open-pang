package io.damo.ninjapang.play;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Player extends FlxSprite {

    public static inline var SIZE = 32;
    public static inline var HORIZONTAL_VELOCITY = 150.0;
    private static inline var GRAVITY = 200;

    public var shielded(default, null) = false;


    public function new(x: Float, y: Float) {
        super(x, y);
        loadGraphic(AssetPaths.mini_ninja__png, true, SIZE, SIZE);

        animation.add("idle", [0, 1, 2, 3], 2);
        animation.add("shooting", [4]);
        animation.add("runningLeft", [5, 6, 7, 8, 9, 10, 11, 12], 12, true, true);
        animation.add("runningRight", [5, 6, 7, 8, 9, 10, 11, 12], 12, true, false);

        setSize(12, 26);
        offset.x = 10;
        offset.y = 5;

        velocity.y = GRAVITY;
        velocity.x = 0;
    }

    override public function update(elapsed: Float) {
        if (x < 0) x = 0;
        if (x + width > FlxG.width) x = FlxG.width - width;

        super.update(elapsed);
    }

    public function moveLeft() {
        velocity.x = -HORIZONTAL_VELOCITY;
        animation.play("runningLeft");
    }

    public function moveRight() {
        velocity.x = HORIZONTAL_VELOCITY;
        animation.play("runningRight");
    }

    public function stopMoving() {
        velocity.x = 0;
        animation.play("idle");
    }

    public function shoot(): Projectile {
        var projectileX = x + 4;
        var projectileY = y + SIZE;

        animation.play("shooting");
        return new Projectile(projectileX, projectileY);
    }

    public function hit(): Bool {
        if (shielded) {
            return false;
        }

        shielded = true;

        new FlxTimer().start(2.0, function(_) {
            shielded = false;
        });

        return true;
    }
}
