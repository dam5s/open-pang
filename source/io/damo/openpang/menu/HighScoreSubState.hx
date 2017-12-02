package io.damo.openpang.menu;

import flixel.FlxSubState;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import io.damo.openpang.interactions.Interactions;
import io.damo.openpang.save.SaveService;
import io.damo.openpang.ui.AssetsSupport;
import io.damo.openpang.ui.FlxTextExtender;


class HighScoreSubState extends FlxSubState {

    private var interactions: Interactions;

    public function new(saveService: SaveService, interactions: Interactions) {
        this.interactions = interactions;

        super(FlxColor.BLACK);

        add(AssetsSupport.buildBgSprite());

        var score = saveService.loadHighScore();
        var text = new MenuItem(0, 1, 'HIGHSCORE ${lpad(score, 6)}');
        text.borderStyle = FlxTextBorderStyle.OUTLINE;
        text.color = FlxTextExtender.DEFAULT_TEXT_COLOR;
        add(text);
    }

    override public function update(elapsed: Float): Void {
        if (interactions.skip())
            close();
    }


    private inline function lpad(number: Int, padding: Int): String {
        return StringTools.lpad(Std.string(number), "0", padding);
    }
}