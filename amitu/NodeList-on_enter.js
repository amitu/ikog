define(
	["dojo/query", "dojo/_base/lang", "dojo/NodeList-manipulate"], 
	function(query, lang) {
		var NodeList = query.NodeList;
		lang.extend(NodeList, {
			on_enter: function(callback){
				var ENTER_KEY = 13;      
				this.on("keypress", function(evt){
	                var key = evt.charCode || evt.keyCode || 0;
	                if (key != ENTER_KEY) return;
					var $this = query(this);
	                var value = $this.val();
	                if (value == "") return;

	                if (!callback(value)) $this.val("");
	                return false;
				});
				return this; // dojo.NodeList
			}
		});
		return NodeList;
	}
);
