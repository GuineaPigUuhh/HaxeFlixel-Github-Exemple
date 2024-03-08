package;

import flixel.util.FlxColor;
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

typedef UserGroup = {
	var image:FlxSprite;
	var text:FlxText;
}

class PlayState extends FlxState
{
	public var _used_user:String = 'GuineaPigUuhh';
	public var _default_notSelected:Float = 0.75;

	var curSelected:Int = 0;

	var myFollowers:Dynamic = null;
	var total_users:Int = 0;

	var camObject:FlxObject;

	var usersAssets:Array<UserGroup> = [];

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = false;

		// to the Cam Follow this Object
		camObject = new FlxObject(80, 0, 0, 0);
		camObject.screenCenter(X);

		// New BG to Stay Cool
		var bg:FlxSprite = new FlxSprite(0, 0, _githubImage('https://raw.githubusercontent.com/GuineaPigUuhh/GuineaPigUuhh/main/background.png'));
		bg.color = 0xB9B9B9;
		bg.screenCenter();
		bg.scale.set(0.3, 0.3);
		bg.scrollFactor.set();
		add(bg);

		// it will take my User Data and parse it
		var myUser:Dynamic = Github.getUser(_used_user);

		// will get my Followers from my Github
		myFollowers = Github._easyparse(myUser.followers_url);
		total_users = myFollowers.length;

		// Loop to Create the Objects
		for (i in 0...total_users)
		{
			// Get the Full User Data
			var this_user = Github.getUser(myFollowers[i].login);

			// new FlxSprite to The User Profile
			var userSprite = new FlxSprite(20, 35 + (60 * i), 
			    _githubImage(this_user.avatar_url + '&size=43', 'Follower:${this_user.login}'));

			// new FlxText to The User Name
			var userText = new FlxText(80, 40 + (60 * i), 0, this_user.login, 20);
			userText.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);

			// set Alpha
			userSprite.alpha = _default_notSelected;
			userText.alpha = _default_notSelected;

			// Add Items
			add(userSprite);
			add(userText);

			// Import Assets to usersAssets
			usersAssets.push({
				image: userSprite,
				text: userText
			});
		}

		// Cool Text to stay cool
		var followUser = new FlxText(0, 40, 0, myUser.login + ' Followers' + ' (Total: $total_users)', 25);
		followUser.screenCenter(X);
		followUser.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);
		followUser.scrollFactor.set();
		followUser.alpha = 0.65;
		add(followUser);

		// Change The Item
		changeItem();

		// Follow Object Camera
		FlxG.camera.follow(camObject, LOCKON, 0.25);
	}

	function changeItem(number:Int = 0)
	{
		// set text to default
		usersAssets[curSelected].text.alpha = _default_notSelected;
		usersAssets[curSelected].image.alpha = _default_notSelected;

		// Change the User you are selected
		curSelected = FlxMath.wrap(curSelected + number, 0, total_users - 1);

		// Camera
		camObject.y = usersAssets[curSelected].text.y;

		// set the text you have selected
		usersAssets[curSelected].text.alpha = 1;
		usersAssets[curSelected].image.alpha = 1;
	}

	override public function update(elapsed:Float)
	{
		/* Keyboard Commands */
		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
			changeItem(-1);
		else if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
			changeItem(1);

		// To Reset the State
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
		
		// When you press ENTER on the keyboard, you will enter the user's Github
		if (FlxG.keys.justPressed.ENTER)
			FlxG.openURL(myFollowers[curSelected].html_url);

		/* Mouse Commands */
		if (FlxG.mouse.wheel != 0)
			changeItem(FlxG.mouse.wheel * -1);

		super.update(elapsed);
	}

	function _githubImage(url:String, ?key:Null<String>) {
		// It will give a Request to get the Image Bytes
		var requestBytes = Github._requestBytes(url);

		// will Create a Bitmap in FlxG to Later Be Used in the Sprite
		var bitmapImage = FlxG.bitmap.add(BitmapData.fromBytes(requestBytes), false, key);

		// Return Value
		return bitmapImage;
	}
}