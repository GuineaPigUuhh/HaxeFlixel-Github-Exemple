package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import haxe.Json;
import haxegithub.Github;
import openfl.display.BitmapData;

using StringTools;

class PlayState extends FlxState
{
	var curSelected = 0;
	var max = 0;
	var camFollow:FlxObject;

	var myFollowers:Dynamic = null;

	var curUsers:Array<FlxText> = [];

	override public function create()
	{
		super.create();

		var grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x2C00FF95, 0x0));
		grid.scrollFactor.set();
		grid.velocity.set(25, 25);
		add(grid);

		var myUser:Dynamic = Github.getUser('GuineaPigUuhh');
		myFollowers = Github.githubParse(myUser.followers_url);
		max = myFollowers.length;

		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);

		for (i in 0...max)
		{
			var user = myFollowers[i];
			var distance = 60;

			var requestBytes = Github.githubRequestBytes(user.avatar_url + '&size=40');

			var userImage = new FlxSprite(20, 35 + (distance * i), FlxG.bitmap.add(BitmapData.fromBytes(requestBytes), false, user.login));
			add(userImage);

			var userText = new FlxText(80, 40 + (distance * i), 0, user.login, 20);
			add(userText);
			curUsers.push(userText);
		}

		var followUser = new FlxText(0, 40, 0, myUser.login + ' Followers', 25);
		followUser.screenCenter(X);
		followUser.scrollFactor.set();
		followUser.alpha = 0.5;
		add(followUser);

		change();
		FlxG.camera.follow(camFollow, LOCKON, 0.1);
	}

	function change(i:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + i, 0, max - 1);
		camFollow.y = curUsers[curSelected].y;
		for (i in 0...max)
			curUsers[i].text = myFollowers[i].login;
		curUsers[curSelected].text = '> ' + myFollowers[curSelected].login + ' <';
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.UP)
			change(-1);
		else if (FlxG.keys.justPressed.DOWN)
			change(1);

		if (FlxG.keys.justPressed.ENTER)
			FlxG.openURL(myFollowers[curSelected].html_url);

		super.update(elapsed);
	}
}
