/***
 * character uploading
 */
const formidable = require("formidable");
const fs = require("fs");
const character = require("./main");

module.exports = function (req, res, url) {
	if (req.method != "POST" || url.path != "/upload_character") return;
	new formidable.IncomingForm().parse(req, (e, f, files) => { // parse character form
		const buffer = fs.readFileSync(files.import.path);
		character
			.save(buffer)
			.then(id => { // save character
				character
					.getTheme(id)
					.then(themeId => { // get char theme
						res.statusCode = 302;
						const url = `/cc?themeId=${themeId}&original_asset_id=${id}`
						res.setHeader("Location", url);
						res.end();
					});
			})
			.catch(() => res.end(`10`))
	});
	return true;
}
