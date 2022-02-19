const http = require("http");
const fUtil = require("../misc/file");
const folder = process.env.THEME_FOLDER;
const fs = require("fs");
themelist = fs.readFileSync(`${folder}/_themelist.xml`, 'utf8');

if (process.env.TRUNCATE_THEMES == "n") {
	themelist = themelist.replace(/<!--/g, ``).replace(/-->/g, ``);
}

/**
 * @param {http.IncomingMessage} req
 * @param {http.ServerResponse} res
 * @param {import("url").UrlWithParsedQuery} url
 * @returns {boolean}
 */

module.exports = function (req, res, url) {
	if (req.method != "POST" || url.path != "/goapi/getThemeList/") return;
	res.setHeader("Content-Type", "application/zip");
	fUtil.makeZip('0', "themelist.xml", themelist).then((b) => res.end(b));
	return true;
};
