package play;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import play.BallSize;
import play.HorizontalDirection;
import play.Player;

class PlayState extends FlxState {

    private static inline var TILE_SIZE = 16;

    var map = new FlxTilemap();
    var balls = new FlxTypedGroup<Ball>();
    var projectiles = new FlxTypedGroup<Projectile>();
    var player: Player;


    override public function create(): Void {
        super.create();

        var tiledMap = new TiledMap(AssetPaths.map__tmx);
        var mainLayer: TiledTileLayer = cast tiledMap.getLayer("main");
        var bgLayer: TiledTileLayer = cast tiledMap.getLayer("bg");
        var bg = new FlxTilemap();

        bg.loadMapFromArray(bgLayer.tileArray, tiledMap.width, tiledMap.height, AssetPaths.tiles__png, 16, 16, 1);
        map.loadMapFromArray(mainLayer.tileArray, tiledMap.width, tiledMap.height, AssetPaths.tiles__png, 16, 16, 1);

        balls.add(new Ball(30, 30, BallSize.Big, HorizontalDirection.Right, FlxColor.RED));
        balls.add(new Ball(100, 30, BallSize.Medium, HorizontalDirection.Left, FlxColor.GREEN));
        balls.add(new Ball(100, 30, BallSize.Small, HorizontalDirection.Right, FlxColor.YELLOW));

        player = new Player(
        (FlxG.width - Player.SIZE) / 2,
        FlxG.height - Player.SIZE - TILE_SIZE
        );

        add(bg);
        add(projectiles);
        add(player);
        add(balls);
        add(map);
    }

    override public function update(elapsed: Float): Void {
        FlxG.collide(balls, map);
        FlxG.collide(player, map);

        movePlayer();
        shoot();

        super.update(elapsed);
    }


    private inline function movePlayer(): Void {
        if (FlxG.keys.pressed.LEFT) player.moveLeft();
        if (FlxG.keys.justReleased.LEFT) player.stopMoving();
        if (FlxG.keys.pressed.RIGHT) player.moveRight();
        if (FlxG.keys.justReleased.RIGHT) player.stopMoving();
    }

    private inline function shoot(): Void {

        if (FlxG.keys.justPressed.Z) {
            projectiles.add(new Projectile(
            player.x + Player.SIZE / 2 - Projectile.WIDTH / 2,
            player.y
            ));
        }
    }
}
