define(
	[
	    "require", "dojo/query", "dojo/parser", "dojo/text!app/banner.txt",
        "dojo/dom-construct", "dojo/window", "app/Pager", "app/PausePager",
        "dojo/text!app/quick.txt", "dojo/text!app/help.txt",
        "amitu/NodeList-on_enter", "amitu/NodeList-focus",
        "dijit/layout/ContentPane", "dijit/layout/BorderContainer"        
	], 
	function(		
		require, query, parser, bannertxt, dc, win, Pager, PausePager, quicktxt,
        helptxt
	) {
		var ikog = {
			init: function() {
				parser.parse();
				Parse.initialize(
	                "hhWd0GF98p5ZwW3Z5LcR7jWsZhxt2OVocDjmuPfs", 
	                "tF8ygbZgKxQIXRF3DjuyvmkiI3n8nGoFaX8cEqx0"
	            );
				ikog.$inp.focus().on_enter(function(line){
					ikog.process_line(line);
				}, true);
				query("body").on("click", function(){ ikog.$inp.focus(); });
				ikog.print_banner();
			},
			println: function(msg){
				ikog.log_id += 1;
				dc.place(
					"<pre class='log_msg' id='log_msg_" + ikog.log_id + "'>" + 
					msg + "</pre>", "log"
				);
				win.scrollIntoView("log_msg_" + ikog.log_id);
			},
			clear_screen: function() {
				dc.empty("log");
			},
			print_banner: function () {
				ikog.println(bannertxt);
				ikog.println("Enter HELP for instructions.");	      
			},
			page: function(lines) {
				ikog.pager = new Pager(lines);
				if (ikog.pager.done()) this.pager = undefined;
			},
			show_help: function() {
				ikog.pager = new PausePager(helptxt.split("\n"));
			},
			process_line: function(line) {
				console.log("process_line", line, this.pager);
				if (this.pager) return this.pager.process_line(line);
				ikog.println(line);
				if (line == "?") return this.println(quicktxt);
				if (line == "cls") return this.clear_screen();
				if (line == "help") return this.show_help();
			}
		}
		ikog.$inp = query("#inp");
		ikog.log_id = 0;
		ikog.pager = undefined;
		window.ikog = ikog;
		require(["dojo/domReady!"], function(){ikog.init()});
		return ikog;
	}
);
