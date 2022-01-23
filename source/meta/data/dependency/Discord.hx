package meta.data.dependency;

#if !android
import discord_rpc.DiscordRpc;
#end
import lime.app.Application;

/**
	Discord Rich Presence, both heavily based on Izzy Engine and the base game's, as well as with a lot of help 
	from the creator of izzy engine because I'm dummy and dont know how to program discord
**/
class Discord
{
	// set up the rich presence initially
	public static function initializeRPC()
	{
                #if !android
		DiscordRpc.start({
			clientID: "879525344128925717",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		// THANK YOU GEDE
		Application.current.window.onClose.add(shutdownRPC);
                #end
	}

	// from the base game
	static function onReady()
	{
                #if !android
		DiscordRpc.presence({
			details: "",
			state: null,
			largeImageKey: 'iconog',
			largeImageText: "Forever Engine"
		});
                #end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	//

	public static function changePresence(details:String = '', state:Null<String> = '', ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
                #if !android
		var startTimestamp:Float = (hasStartTimestamp) ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'iconog',
			largeImageText: "Forever Engine",
			smallImageKey: smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});
                #end

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	public static function shutdownRPC()
	{
                #if !android
		// borrowed from izzy engine -- somewhat, at least
		DiscordRpc.shutdown();
                #end
	}
}
