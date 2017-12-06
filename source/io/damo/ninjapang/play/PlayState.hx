package io.damo.ninjapang.play;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import io.damo.ninjapang.gameover.GameOverState;
import io.damo.ninjapang.interactions.Interactions;
import io.damo.ninjapang.play.BallSize;
import io.damo.ninjapang.play.HorizontalDirection;
import io.damo.ninjapang.play.Player;
import io.damo.ninjapang.ui.AssetsSupport;


class PlayState extends FlxState {

    private static inline var TILE_SIZE = 16;
    private static inline var BALL_MAX_X = 640 - 16;
    private static inline var BALL_MIN_X = 16;

    private var saveService: SaveService;
    private var interactions: Interactions;
    private var scoreBoard: ScoreBoard;

    private var floor: FlxSprite;
    private var balls: FlxTypedGroup<Ball>;
    private var projectiles: FlxTypedGroup<Projectile>;
    private var player: Player;
    private var playerBuffs: PlayerBuffs;
    private var hud: HUD;

    override public function create() {
        super.create();

        saveService = Env.instance.saveService;
        interactions = Env.instance.interactions;
        scoreBoard = Env.instance.resetScoreBoard();

        projectiles = new FlxTypedGroup<Projectile>();

        floor = new FlxSprite(0, FlxG.height - TILE_SIZE);
        floor.immovable = true;
        floor.setSize(FlxG.width, TILE_SIZE);
        floor.loadGraphic(AssetPaths.mini_ninja_floor__png);

        balls = new FlxTypedGroup<Ball>();
        spawnBall(0.0, true);

        var playerX = (FlxG.width - Player.SIZE) / 2;
        var playerY = FlxG.height - Player.SIZE - TILE_SIZE;
        player = new Player(playerX, playerY);
        playerBuffs = new PlayerBuffs();

        hud = new HUD();

        add(AssetsSupport.buildBgSprite());
        add(projectiles);
        add(floor);
        add(playerBuffs);
        add(player);
        add(balls);
        add(hud);
    }

    override public function update(elapsed: Float) {
        FlxG.collide(player, floor);
        FlxG.collide(balls, floor, bounceBall);
        FlxG.collide(projectiles, balls, collideProjectileAndBall);
        FlxG.overlap(player, balls, hitPlayer);

        spawnBall(elapsed);
        movePlayer();
        shoot();
        killProjectiles();
        changeBallsDirection();
        updateHUD();
        updateBuffs();

        super.update(elapsed);
    }


    private var timeSinceLastSpawn: Float = 0;
    private var spawnFrequency: Float = 5;

    private function spawnBall(elapsed: Float, force: Bool = false) {
        timeSinceLastSpawn += elapsed;

        if (timeSinceLastSpawn > spawnFrequency || force) {
            var x = randomX();
            var direction = randomDirection();

            balls.add(new Ball(x, 30, BallSize.Big, direction));
            timeSinceLastSpawn = 0;
        }
    }

    private function updateBuffs() {
        playerBuffs.x = player.x - 10;
        playerBuffs.y = player.y - 3;

        if (player.shielded && !playerBuffs.displayingShield) playerBuffs.displayShield();

        if (!player.shielded && playerBuffs.displayingShield) playerBuffs.hideShield();
    }

    private function updateHUD() {
        hud.displayLives(scoreBoard.lives);
        hud.displayScore(scoreBoard.score);
    }

    private function killProjectiles() {
        projectiles.forEach(function(projectile: Projectile) {
            if (projectile.y < 0) projectile.kill();
        });
    }

    private function bounceBall(ball: Ball, floor: FlxSprite) {
        ball.velocity.y = -Ball.GRAVITY;
        ball.animation.play("bounce");
    }

    private function changeBallsDirection() {
        balls.forEach(function(ball: Ball) {
            if (ball.x <= 0) {
                ball.velocity.x = ball.horizontalVelocity;
            }

            if (ball.x + ball.width >= FlxG.width) {
                ball.velocity.x = -ball.horizontalVelocity;
            }
        });
    }

    private function collideProjectileAndBall(projectile: Projectile, ball: Ball) {
        FlxG.sound.play(AssetPaths.pop__ogg);

        projectile.kill();
        scoreBoard.score += ball.score;

        for (newBall in ball.split()) {
            newBall.x = xWithinBoundaries(newBall.x);
            balls.add(newBall);
        }
    }

    private function hitPlayer(player: Player, ball: Ball) {
        if (player.hit()) {
            scoreBoard.lives -= 1;

            FlxG.sound.play(AssetPaths.hit__ogg);
            FlxG.camera.shake(0.02, 0.35);

            if (scoreBoard.lives < 0) {
                FlxG.switchState(new GameOverState());
            }
        }
    }


    private inline function movePlayer() {
        if (interactions.stopMoving()) player.stopMoving();
        if (interactions.left()) player.moveLeft();
        if (interactions.right()) player.moveRight();

        if (player.x < 0) player.x = 0;
        if (player.x + player.width > FlxG.width) player.x = FlxG.width - player.width;
    }

    private inline function shoot() {
        if (interactions.shoot() && canShoot()) {
            FlxG.sound.play(AssetPaths.shoot__ogg, .6);

            var projectile = player.shoot();
            projectiles.add(projectile);
        }
    }

    private inline function canShoot(): Bool {
        return projectiles.countLiving() < 2;
    }

    private inline function randomX(): Int {
        return 256 + Math.floor(Math.random() * FlxG.width - 256);
    }

    private inline function randomDirection(): HorizontalDirection {
        if (Math.random() > .5) {
            return HorizontalDirection.Right;
        }

        return HorizontalDirection.Left;
    }

    private inline function xWithinBoundaries(x: Float): Float {
        if (x < BALL_MIN_X) return BALL_MIN_X;
        if (x > BALL_MAX_X) return BALL_MAX_X;
        return x;
    }
}
