define(
	[
	    "dojo/query", "dojo/text!ikog/banner.txt", "amitu/NodeList-on_enter",
	    "amitu/NodeList-focus", 
	], 
	function(query, banner) {
		return {
			main: function() {
				Parse.initialize(
	                "hhWd0GF98p5ZwW3Z5LcR7jWsZhxt2OVocDjmuPfs", 
	                "tF8ygbZgKxQIXRF3DjuyvmkiI3n8nGoFaX8cEqx0"
	            );
				query("#inp").focus().on_enter(function(line){
					this.println(line)
				});
				this.print_banner();
			},
			println: function(msg){
				console.log(msg);
			},
			print_banner: function () {
				console.log(banner);
				this.println("Enter HELP for instructions.");	      
			}
		}
	}
);
