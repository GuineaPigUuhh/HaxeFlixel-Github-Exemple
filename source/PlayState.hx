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

	var usersText:Array<FlxText> = [];

	override public function create()
	{
		super.create();

		// Cool Backdrop to stay cool
		var grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x2C00FF95, 0x0));
		grid.scrollFactor.set();
		grid.velocity.set(25, 25);
		add(grid);

		// it will take my User Data and parse it
		var myUser:Dynamic = Github.getUser('GuineaPigUuhh');

		// will get my Followers from my Github
		myFollowers = Github.githubParse(myUser.followers_url);

		// set The Variable Max
		max = myFollowers.length;

		// It will be used to identify which user you are seeing
		camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);

		// Loop to Create the Objects
		for (i in 0...max)
		{
			// Get the Full User Data
			var user = Github.getUser(myFollowers[i].login);

			// It will give a Request to get the Image Bytes
			var requestBytes = Github._requestBytes(user.avatar_url + '&size=40');

			// will Create a Bitmap in FlxG to Later Be Used in the User Icon
			var bitmapImage = FlxG.bitmap.add(BitmapData.fromBytes(requestBytes), false, 'GithubFollower:${user.login}');

			// new FlxSprite to The User Profile
			var userImage = new FlxSprite(20, 35 + (60 * i), bitmapImage);

			// new FlxText to The User Name
			var userText = new FlxText(80, 40 + (60 * i), 0, user.login, 20);

			// Add Items
			add(userImage);
			add(userText);

			// will give a push to be used on CamFollow
			usersText.push(userText);
		}

		// Cool Text to stay cool
		var followUser = new FlxText(0, 40, 0, myUser.login + ' Followers' + ' (Total: $max)', 25);
		followUser.screenCenter(X);
		followUser.scrollFactor.set();
		followUser.alpha = 0.5;
		add(followUser);

		// Change The Item
		changeItem();

		// Follow the CamFollow
		FlxG.camera.follow(camFollow, LOCKON, 0.1);
	}

	function changeItem(i:Int = 0)
	{
		// Change the User you are selected
		curSelected = FlxMath.wrap(curSelected + i, 0, max - 1);

		// Change the camera position to the selected User
		camFollow.y = usersText[curSelected].y;

		// Leave all text as default
		for (i in 0...max)
			usersText[i].text = myFollowers[i].login;

		// set the text you have selected
		usersText[curSelected].text = '> ' + myFollowers[curSelected].login + ' <';
	}

	override public function update(elapsed:Float)
	{
		/* Keyboard Commands */
		if (FlxG.keys.justPressed.UP)
			changeItem(-1);
		else if (FlxG.keys.justPressed.DOWN)
			changeItem(1);

		// To Reset the State
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();

		// When you press ENTER on the keyboard, you will enter the user's Github
		if (FlxG.keys.justPressed.ENTER)
			FlxG.openURL(myFollowers[curSelected].html_url);

		super.update(elapsed);
	}
}
