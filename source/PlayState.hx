package;

import haxegithub.GithubAPI;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import haxegithub.utils.User;
import haxegithub.flixel.GithubUtil;
import haxegithub.flixel.shaders.CircleAvatarShader;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import haxegithub.GithubAPI;

using StringTools;

typedef UserGroup =
{
	var image:FlxSprite;
	var text:FlxText;
}

class CircleShader extends FlxShader
{
	@:glFragmentSource('
    // Credits to FNF Codename Engine Team!

    #pragma header

    void main() {
        float len = length(openfl_TextureCoordv - vec2(0.5, 0.5));
        float r = 0.5 - (1.0 / openfl_TextureSize.x);
        vec4 c = flixel_texture2D(bitmap, openfl_TextureCoordv);
        vec4 color = mix(vec4(0.0, 0.0, 0.0, 0.5), c, c.a);
        gl_FragColor = color * clamp(1.0 - ((len - r) * openfl_TextureSize.x), 0.0, 1.0);
    }
    ')
	public function new()
	{
		super();
	}
}

class PlayState extends FlxState
{
	public var _default_notSelected:Float = 0.55;

	var curSelected:Int = 0;

	public static var myFollowers:Array<Dynamic> = null;
	static final userView:String = "GuineaPigUuhh";

	var total_users:Int = 0;

	var camObject:FlxObject;

	var usersAssets:Array<UserGroup> = [];

	public static function reloadGithub_variables(reset = false)
	{
		if (reset == true)
			myFollowers = null;

		if (myFollowers == null)
			myFollowers = User.getFollowers(userView);
	}

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = false;

		// to the Cam Follow this Object
		camObject = new FlxObject(80, 0, 0, 0);
		camObject.screenCenter(X);

		var grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x2C00FF95, 0x0));
		grid.scrollFactor.set();
		grid.velocity.set(25, 25);
		add(grid);

		reloadGithub_variables();
		total_users = myFollowers.length;

		// Loop to Create the Objects
		for (i in 0...total_users)
		{
			// Get the Follower Data
			var this_user:Dynamic = myFollowers[i];

			var avatar:FlxSprite = new FlxSprite(15, 25 + (60 * i));
			avatar.makeGraphic(55, 55, FlxColor.WHITE);
			avatar.antialiasing = true;
			avatar.shader = new CircleShader();
			sys.thread.Thread.create(() ->
			{
				avatar.loadGraphic(requestImg(this_user.avatar_url, 'Follower:${this_user.login}'));
				avatar.setGraphicSize(55, 55);
				avatar.updateHitbox();
			});

			// new FlxText to The User Name
			var text = new FlxText(80, 40 + (60 * i), 0, this_user.login, 20);
			text.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);

			// set Alpha
			avatar.alpha = _default_notSelected;
			text.alpha = _default_notSelected;

			// Add Items
			add(avatar);
			add(text);

			// Import Assets to usersAssets
			usersAssets.push({
				image: avatar,
				text: text
			});
		}
		// Cool Text to stay cool
		var followUser = new FlxText(0, 40, 0, userView + ' Followers (Total Loaded: $total_users)', 22);
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

		/*
			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					reloadGithub_variables(true);
				FlxG.resetState();
			}
		 */

		// When you press ENTER on the keyboard, you will enter the user's Github
		if (FlxG.keys.justPressed.ENTER)
			FlxG.openURL(myFollowers[curSelected].html_url);

		/* Mouse Commands */
		if (FlxG.mouse.wheel != 0)
			changeItem(FlxG.mouse.wheel * -1);

		super.update(elapsed);
	}

	function requestImg(url:String, ?key:Null<String>)
	{
		var img = new haxe.Http(url);
		img.request();
		return FlxG.bitmap.add(BitmapData.fromBytes(img.responseBytes), true, key);
	}
}
