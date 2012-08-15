define(
	[
	    "dojo/query", "dojo/parser", "dojo/text!ikog/banner.txt", 
		"dojo/dom-construct", "dojo/window", "amitu/NodeList-on_enter", 
		"amitu/NodeList-focus",
	], 
	function(query, parser, banner, dc, win) {
		var ikog = {
			main: function() {
				parser.parse();
				Parse.initialize(
	                "hhWd0GF98p5ZwW3Z5LcR7jWsZhxt2OVocDjmuPfs", 
	                "tF8ygbZgKxQIXRF3DjuyvmkiI3n8nGoFaX8cEqx0"
	            );
				query("#inp").focus().on_enter(function(line){
					ikog.println(line);
				});
				ikog.print_banner();
			},
			println: function(msg){
				ikog.log_id += 1;
				console.log(msg);
				dc.place(
					"<pre class='log_msg' id='log_msg_" + ikog.log_id + "'>" + 
					msg + "</pre>", "log"
				);
				win.scrollIntoView("log_msg_" + ikog.log_id);
			},
			print_banner: function () {
				ikog.println(banner);
				ikog.println("Enter HELP for instructions.");	      
			}
		}
		ikog.$log = query("#log");
		ikog.log_id = 0;
		return ikog;
	}
);
