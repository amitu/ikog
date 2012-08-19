define(
    ["dojo/query", "dojo/_base/lang", "dijit/focus"], 
    function(query, lang, focusUtil) {
        var NodeList = query.NodeList;
        lang.extend(NodeList, {
            focus: function(){
                if (this.length > 0) 
                {
                    var first = this[0];
                    focusUtil.focus(first);
                }
                return this; // dojo.NodeList
            }
        });
        return NodeList;
    }
);
