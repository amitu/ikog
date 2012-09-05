define(
    [
        "dojo/_base/declare", "dijit/_WidgetBase", "dojo/Evented",
        "dojo/keys", "dojo/query", "dojo/NodeList-manipulate"
    ], function(declare, _WidgetBase, Evented, keys, query){
        return declare([_WidgetBase, Evented], {
            postCreate: function() {
                var self = this;
                var $domNode = query(this.domNode);
                $domNode.focus().on("keypress", function(evt) {
                    var key = evt.charCode || evt.keyCode || 0;
                    if (key != keys.ENTER) return;
                    self.emit("command", $domNode.val());
                    $domNode.val("");
                });
            }
        });
    }
);