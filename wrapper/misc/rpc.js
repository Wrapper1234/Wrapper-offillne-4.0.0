const RPC = require("discord-rpc");
const http = require("http");

// Loads env.json for Wrapper version and build number
const env = Object.assign(process.env,
	require('../env'));
// env.json variables
let version = env.WRAPPER_VER;

// Discord rich presence
const rpc = new RPC.Client({
	transport: "ipc"
});

module.exports = {
	setActivity(page) {
		if (env.RPC == "y") {
			switch (page) {
				case "vl": { 
					var state = 'Video List'; 
					break; 
				}
				case "vm": { 
					var state = 'Making a Video'; 
					break; 
				}
				case "th": { 
					var state = 'Picking a Theme'; 
					break; 
				}
				case "cc": { 
					var state = 'Creating a Character'; 
					break; 
				}
				case "ccb": { 
					var state = 'Browsing Characters'; 
					break; 
				}
				case "vp": { 
					var state = 'Watching a Video'; 
					break; 
				}
			}
			// Sets RPC activity
			rpc.setActivity({
				state: state,
				details: "Version " + version,
				startTimestamp: new Date(),
				largeImageKey: "icon",
				largeImageText: "Wrapper: Offline",
				smallImageKey: "Wrapper: Offline",
				smallImagetext: "Wrapper: Offline",
			});
		}
	}
}

if (env.RPC == "y") {
	rpc.on("ready", () => {
		rpc.setActivity({
			state: 'Waiting for RPC input...',
			details: "Version " + version,
			startTimestamp: new Date(),
			largeImageKey: "icon",
			largeImageText: "Wrapper: Offline",
			smallImageKey: "Wrapper: Offline",
			smallImagetext: "Wrapper: Offline",
		});
	});
}
// Connects RPC to app
if (env.RPC == "y") {
	try {
		rpc.login({
			clientId: "866340172874383370"
		});
		console.log('Rich presence is on!')
	} catch (e) {
		console.log(e);
	}
}
