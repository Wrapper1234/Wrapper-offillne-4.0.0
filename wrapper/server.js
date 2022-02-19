/***
 * start wrapper: offline's server
 */
// assign config and env.json stuff to process.env
const env = Object.assign(process.env, require("./env"), require("./config"));
const http = require("http");
const url = require("url");

/**
 * routes
 */
const chr = require("./character/redirect");
const pmc = require("./character/premade");
const chl = require("./character/load");
const chs = require("./character/save");
const cht = require("./character/thmb");
const chu = require("./character/upload");
const mvu = require("./movie/upload");
const asu = require("./asset/upload");
const stl = require("./static/load");
const stp = require("./static/page");
const the = require("./static/page-themelist");
const str = require("./starter/save");
const stt = require("./starter/thmb");
const asl = require("./asset/load");
const asL = require("./asset/list");
const ast = require("./asset/thmb");
const mvl = require("./movie/load");
const mvL = require("./movie/list");
const mvm = require("./movie/meta");
const mvs = require("./movie/save");
const mvt = require("./movie/thmb");
const thL = require("./theme/list");
const thl = require("./theme/load");
const tsv = require("./tts/voices");
const tsl = require("./tts/load");
const rpc = require("./misc/rpc");
const functions = [mvL, pmc, asl, chl, thl, thL, chs, chu, cht, asL, tsl, chr, ast, mvm, mvl, mvs, mvt, tsv, asu, mvu, stp, stl, the, str, stt, rpc];

/**
 * create the server
 */
module.exports = http
	.createServer((req, res) => {
		try {
			const parsedUrl = url.parse(req.url, true);
			// run each route function until the correct one is found
			const found = functions.find((f) => f(req, res, parsedUrl));
			// log every request
			console.log(req.method, parsedUrl.path);
			if (!found) { // page not found
				res.statusCode = 404;
				res.end();
			}
		} catch (x) {
			res.statusCode = 404;
			res.end();
		}
	})
	.listen(env.PORT || env.SERVER_PORT, console.log("Wrapper: Offline has started."));
