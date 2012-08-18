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
			MAGIC_TAG: "#!<^",
			ENCRYPTION_MARKER: "{}--xx",
			print_current: true,
			review: false,
			init: function() {
				parser.parse();
				Parse.initialize(
	                "hhWd0GF98p5ZwW3Z5LcR7jWsZhxt2OVocDjmuPfs", 
	                "tF8ygbZgKxQIXRF3DjuyvmkiI3n8nGoFaX8cEqx0"
	            );
				ikog.$inp.focus().on_enter(function(line){
					ikog.process_line(line);
					ikog.print_current_if_required();
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
			print_line: function() {
				this.println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
			},
			print_current_if_required: function(){
				if (!this.print_current) return;
				this.print_line();
				this.println("[00] send mail to coupan owners");
				this.println("Priority: 05")
				this.println("Context:  @Anywhere")
				this.println("Created: [2009-03-10]")
				this.print_line();				
			},
			clear_screen: function() {
				dc.empty("log");
			},
			print_banner: function () {
				ikog.println(bannertxt);
				ikog.println("Enter HELP for instructions.");	      
				this.print_current_if_required();
			},
			page: function(lines) {
				ikog.pager = new Pager(lines);
				if (ikog.pager.done()) this.pager = undefined;
			},
			show_help: function() {
				ikog.pager = new PausePager(helptxt.split("\n"));
			},
			parse_input: function(line) {
				var cmd = "", rest = "", orig = line;
				if (line.indexOf(this.MAGIC_TAG) == 0)
	                this.print_error(
						"You cannot begin lines with the sequence " + this.MAGIC_TAG
					)
				else if (line.indexOf(this.ENCRYPTION_MARKER) == 0)
	                this.print_error(
						"You cannot begin lines with the sequence " + this.ENCRYPTION_MARKER
					)
				else {
	                var n = line.indexOf(" ")
	                if (n >= 0) {
	                    cmd = line.substring(0, n);
	                    rest = line.substring(n + 1);
					}
	                else {
	                    cmd = line;
	                    rest = "";
					}
				}
				// TODO: handle shortcuts
		        return {cmd: cmd, rest: rest, orig: orig};
			},
			next_task: function() {}, // TODO
			process_line: function(line) {
				console.log("process_line", line, this.pager);
				this.print_current = true;
				if (this.pager) {
					this.print_current = false;
					return this.pager.process_line(line);
				}

				ikog.println(">>> " + line);
				
				line = this.parse_input(line);
				
				var cmd = line.cmd.toUpperCase();
				
				if (cmd == "") {
					if (this.review) {
						this.next_task();
					}
				}
				else if (cmd == "?") {
					this.print_current = false;
					return this.println(quicktxt);
				}
				else if (cmd == "CLS") return this.clear_screen();
				else if (cmd == "HELP") {
					this.print_current = false;
					return this.show_help();
				}
				
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
