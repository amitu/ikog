define(
    ["dojo/query", "dojo/_base/lang", "dojo/keys", "dojo/NodeList-manipulate"], 
    function(query, lang, keys) {
        var NodeList = query.NodeList;
        lang.extend(NodeList, {
            on_enter: function(callback, allow_empty){
                this.on("keypress", function(evt){
                    var key = evt.charCode || evt.keyCode || 0;
                    if (key != keys.ENTER) return;
                    var $this = query(this);
                    var value = $this.val();
                    if (!allow_empty && value == "") return;

                    if (!callback(value)) $this.val("");
                    return false;
                });
                return this; // dojo.NodeList
            }
        });
        return NodeList;
    }
);
