// All rights and credits goes to David's TV Studio for helping me revive the starters feature.
const exFolder = process.env.EXAMPLE_FOLDER;
const caché = require("../asset/caché");
const fUtil = require("../misc/file");
const nodezip = require("node-zip");
const parse = require("../movie/parse");
const fs = require("fs");
const truncate = require("truncate");

module.exports = {
	/**
	 *
	 * @param {Buffer} starterZip
	 * @returns {Promise<string>}
	 */
	save(starterZip, thumb) {
		return new Promise(async (res, rej) => {
			var sId = fUtil.getNextFileId("starter-", ".xml");
			var zip = nodezip.unzip(starterZip);
			
			const thumbFile = fUtil.getFileIndex("starter-", ".png", sId);
			fs.writeFileSync(thumbFile, thumb);
			var path = fUtil.getFileIndex("starter-", ".xml", sId);
			var writeStream = fs.createWriteStream(path);
			var assetBuffers = caché.loadTable(sId);
			parse.unpackMovie(zip, thumb, assetBuffers).then((data) => {
				writeStream.write(data, () => {
					writeStream.close();
					res("s-" + sId);
				});
			});
				
				
		});
	},
	delete(mId) {
		return new Promise(async (res, rej) => {
			var i = mId.indexOf("-");
			var prefix = mId.substr(0, i);
			var suffix = mId.substr(i + 1);
			switch (prefix) {
				case "s":
					var moviePath = fUtil.getFileIndex("starter-", ".xml", suffix);
					var thumbPath = fUtil.getFileIndex("starter-", ".png", suffix);
					fs.unlinkSync(moviePath);
					fs.unlinkSync(thumbPath);
					caché.clearTable(mId);
					res(mId);
					break;
				
				default:
					rej();
			}
		});
	},
	// The cores to load starters is in the main.js file in the movie folder. thanks for reading. -Joseph Animate 2021
	thumb(movieId) {
		return new Promise(async (res, rej) => {
			if (!movieId.startsWith("s-")) return;
			const n = Number.parseInt(movieId.substr(2));
			const fn = fUtil.getFileIndex("starter-", ".png", n);
			isNaN(n) ? rej() : res(fs.readFileSync(fn));
		});
	},
	list() {
		const table = [];
		var ids = fUtil.getValidFileIndicies("starter-", ".xml");
		for (const i in ids) {
			var id = `s-${ids[i]}`;
			table.unshift({ id: id });
		}
		return table;
	},
};
