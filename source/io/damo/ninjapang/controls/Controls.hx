package io.damo.ninjapang.controls;

import haxe.ds.Option;
import io.damo.ninjapang.menu.MenuItem;


interface Controls {

    function skip(): Bool;

    function accept(): Bool;

    function up(): Bool;

    function down(): Bool;

    function left(): Bool;

    function right(): Bool;

    function stopMoving(): Bool;

    function shoot(): Bool;

    function selectedMenuItem(menuItems: Array<MenuItem>): Option<MenuItem>;
}
