define(
    ["dojo/query", "dojo/_base/lang", "dojo/NodeList-manipulate"], 
    function(query, lang) {
        var NodeList = query.NodeList;
        lang.extend(NodeList, {
            on_ctrl: function(key, callback){
                this.on("keypress", function(evt){
                    var charOrCode = evt.charCode || evt.keyCode;
                    console.log("charOrCode", charOrCode, evt);
                    if (evt.ctrlKey && charOrCode == key) callback();
                });
                return this; // dojo.NodeList
            }
        });
        return NodeList;
    }
);
