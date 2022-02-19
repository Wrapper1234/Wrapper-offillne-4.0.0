/***
 * short version of https.get
 */
const https = require("https");
const http = require("http");

/**
 * @param {import("url").UrlWithParsedQuery} url
 * @param {CredentialRequestOptions} [options]
 * @returns {Promise<Buffer>}
 */
module.exports = function (url, options = {}) {
	var data = [];
	return new Promise((res, rej) => {
		try { // try https first
			https.get(url, options, o => o
				.on("data", v => data.push(v))
				.on("end", () => res(Buffer.concat(data)))
				.on("error", rej));
		} catch (err) {
			http.get(url, options, o => o
				.on("data", v => data.push(v))
				.on("end", () => res(Buffer.concat(data)))
				.on("error", rej));
		}
	});
}
