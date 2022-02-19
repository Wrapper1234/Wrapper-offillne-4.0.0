const fUtil = require("../misc/file");
const stuff = require("./info");
const rpc = require("../misc/rpc");
const http = require("http");
const env = require("../env");

if (env.DARK_MODE == "y") {
	var globalcss = '/pages/css/global.css';
	var createcss = '/pages/css/create.css';
} else {
	var globalcss = '/pages/css/global-light.css';
	var createcss = '/pages/css/create-light.css';
}
/**
 * @param {http.IncomingMessage} req
 * @param {http.ServerResponse} res
 * @param {import("url").UrlWithParsedQuery} url
 * @returns {boolean}
 */
module.exports = function (req, res, url) {
	if (req.method != "GET") return;
	const query = url.query;

	var attrs, params, rpcValue;
	switch (url.pathname) {
		case "/selectThemeOnEdit": {
			rpcValue = "th";
			params = {
				flashvars: {
					movieId: "",
					version: process.env.WRAPPER_VER,
					build: process.env.WRAPPER_BLD,
				},
			};
			break;
		}

		default:
			return;
	}
	res.setHeader("Content-Type", "text/html; charset=UTF-8");
	Object.assign(params.flashvars, query);
	if (env.RPC == "y") {
		rpc.setActivity(rpcValue);
	}
	// if you're seeing this, just know i hate doing this stuff - spark
	res.end(`<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<link rel="icon" href="../../favicon.ico" type="image/png">
	<title>Theme List</title>
	<meta name="description" content="Wrapper: Offline's Theme List">
	<link rel="stylesheet" type="text/css" href="/pages/css/modern-normalize.css">
	<link rel="stylesheet" type="text/css" href="${globalcss}">
	<link rel="stylesheet" type="text/css" href="${createcss}">
	<script>
		function characterThemes() {
			document.getElementById("creation_type").style.display = "none";
			document.getElementById("character_themes").style.display = "block";
			document.getElementById("back").style.display = "block";
		}
		
		function movieThemes() {
			document.getElementById("creation_type").style.display = "none";
			document.getElementById("movie_themes").style.display = "block";
			document.getElementById("back").style.display = "block";
		}
		
		function creationType() {
			document.getElementById("creation_type").style.display = "block";
			document.getElementById("character_themes").style.display = "none";
			document.getElementById("movie_themes").style.display = "none";
			document.getElementById("back").style.display = "none";
		}
		
		function showCredits() {
			document.getElementById("credits").style.display="block";
			document.getElementById("credits_button").style.display="none";
		}
	</script>
</head>
<body>

<header>
	<a href="/">
		<h1 style="margin:0"><img id="logo" src="/pages/img/list_logo.svg" alt="Wrapper: Offline"/></h1>
	</a>
	<nav id="headbuttons">
		<a class="button_small" id="back" onclick="creationType()" style="display: none">BACK</a>
	</nav>
</header>

<main>
	
<div id="creation_type" style="display: unset">
	<h1>Pick a creation to continue.</h1>

	<div id="column1">
		<div class="theme pick_creation">
			<div onclick="characterThemes()">
				<img src="/pages/img/themelist/Character.png" alt="Create a character">
				<p>Character</p>
			</div>
		</div>
		<div class="theme pick_creation">
			<div onclick="movieThemes()">
				<img src="/pages/img/themelist/Movie.png" alt="Make a movie">
				<p>Movie</p>
			</div>
		</div>
	</div>
</div>

<div id="character_themes" style="display: none">
	<h1>Select a theme for your character <small>One conatins a theme for your movie.</small></h1>

	<div id="column1">
		<div class="theme">
			<a href="http://localhost:4343/cc_browser?themeId=family">
				<img src="/pages/img/themelist/Comedy_World.jpg" alt="Comedy World">
				<p>Comedy World</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/cc_browser?themeId=cc2">
				<img src="/pages/img/themelist/lil_Peepz.jpg" alt="Lil' Peepz">
				<p>Lil' Peepz</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/cc_browser?themeId=anime">
				<img src="/pages/img/themelist/Anime.jpg" alt="Anime">
				<p>Anime</p>
			</a>
		</div>
	</div><br />

	<div id="column3">
		<div class="theme">
			<a href="http://localhost:4343/cc_browser?themeId=ninjaanime">
				<img src="/pages/img/themelist/Ninja_Anime.jpg" alt="Ninja Anime">
				<p>Ninja Anime</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/cc_browser?themeId=spacecitizen">
				<img src="/pages/img/themelist/Space_Citizens.jpg" alt="Space Citizens">
				<p>Space Citizens</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/cc_browser?themeId=chibi">
				<img src="/pages/img/themelist/Chibi_Peepz.jpg" alt="Chibi Peepz">
				<p>Chibi Peepz</p>
			</a>
		</div>
	</div><br />

	<div id="column4">
		<div class="theme">
			<a href="http://localhost:4343/cc_browser?themeId=ninja">
				<img src="/pages/img/themelist/Chibi_Ninjas.jpg" alt="Chibi Ninjas">
				<p>Chibi Ninjas</p>
			</a>
		</div>
	</div><br />
</div>

<div id="movie_themes" style="display: none">
	<h1>Select a theme for your movie</h1>
	
	<div id="column1">
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=custom&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Comedy_World.jpg" alt="Comedy World">
				<p>Comedy World</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=yugandar&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Yugandars_World_2.0.jpg" alt="Yugandar's World 2.0">
				<p>Yugandar's World 2.0</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=action&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/lil_Peepz.jpg" alt="Lil' Peepz">
				<p>Lil' Peepz</p>
			</a>
		</div>
	</div><br />

	<div id="column2">
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=retro&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Cartoon_Classics.jpg" alt="Cartoon Classics">
				<p>Cartoon Classics</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=politics2&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Election_2012.jpg" alt="White Houserz">
				<p>White Houserz</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=politic&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Politics_and_Celebrity.png" alt="Politics &amp; Celebrity">
				<p>Politics &amp; Celebrity</p>
			</a>
		</div>
	</div><br />

	<div id="column3">
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=stick&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Stick_Figure.jpg" alt="Stick Figure">
				<p>Stick Figure</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=anime&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Anime.jpg" alt="Anime">
				<p>Anime</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=ninjaanime&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Ninja_Anime.jpg" alt="Ninja Anime">
				<p>Ninja Anime</p>
			</a>
		</div>
	</div><br />

	<div id="column4">
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=spacecitizen&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Space_Citizens.jpg" alt="Space Citizens">
				<p>Space Citizens</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=chibi&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Chibi_Peepz.jpg" alt="Chibi Peepz">
				<p>Chibi Peepz</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=ninja&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Chibi_Ninjas.jpg" alt="Chibi Ninjas">
				<p>Chibi Ninjas</p>
			</a>
		</div>
	</div><br />
	<div id="column5">
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=animal&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Lil_Petz_World.jpg" alt="Lil' Petz World">
				<p>Lil' Petz World</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=space&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Space_Peepz.jpg" alt="Space Peepz">
				<p>Space Peepz</p>
			</a>
		</div>
		<!--EXTRATHEME<div class="theme">
			<a href="http://localhost:4343/go_full?tray=toonadv&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Toon_Adventure.png" alt="Toon Adventure">
				<p>Toon Adventure</p>
			</a>
		</div>EXTRATHEME-->
	</div>
	<!--EXTRATHEME<div id="column6">
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=underdog&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/UnderDog.png" alt="Saturday Morning TV">
				<p>Saturday Morning TV</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=willie&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Willie_Nelson.jpg" alt="Willie Nelson">
				<p>Willie Nelson</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=fullenergy&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Full_Energy.png" alt="Full Energy">
				<p>Full Energy</p>
			</a>
		</div>
	</div>
	<div id="column7">
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=akon&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Akon.jpg" alt="AKON">
				<p>AKON</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=ben10&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Ben_10.png" alt="Ben 10">
				<p>Ben 10</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=botdf&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/botdf.jpg" alt="BOTDF">
				<p>Blood on the Dance Floor</p>
			</a>
		</div>
	</div>
	<div id="column8">
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=bunny&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Happy_Bunny.png" alt="It's Happy Bunny">
				<p>It's Happy Bunny</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=chowder&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Chowder.png" alt="Chowder">
				<p>Chowder</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=domo&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Domo.png" alt="Domo">
				<p>Domo</p>
			</a>
		</div>
	</div>
	<div id="column9">
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=monkeytalk&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/SuperRica_&_Rashy.png" alt="SuperRica &amp; Rashy">
				<p>SuperRica &amp; Rashy</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=christmas&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Holiday_and_Seasonal.png" alt="Holiday &amp; Seasonal">
				<p>Holiday &amp; Seasonal</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=bizmodels&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Business_Models.jpg" alt="Business Models">
				<p>Business Models</p>
			</a>
		</div>
	</div>
	<div id="column10">
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=sticklybiz&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Stickly_Business.jpg" alt="Stickly Business">
				<p>Stickly Business</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=vietnam&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/lil_Peepz.jpg" alt="Jungle Warfare">
				<p>Jungle Warfare</p>
			</a>
		</div>
		<div class="theme">
			<a href="http://localhost:4343/go_full?tray=monstermsh&movieId=${params.flashvars.movieId}">
				<img src="/pages/img/themelist/Monsters_Mayhem.png" alt="Monsters Mayhem">
				<p>Monsters Mayhem</p>
			</a>
		</div>
	</div>EXTRATHEME-->
</div>

</main>

<footer>
	<nav id="foot-left">
		<span title="Wrapper: Offline v${params.flashvars.version}, build ${params.flashvars.build}">v${params.flashvars.version}</span>
		<a href="https://localhost:4664/faq.html">FAQ</a>
		<a href="https://localhost:4664">Server Page</a>
		<a href="https://discord.gg/yhGAetN">Wrapper: Offline Discord</a>
	</nav>
</footer>

</body></html>`)
	return true;
};
