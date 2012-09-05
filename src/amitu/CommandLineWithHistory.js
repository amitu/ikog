define(
    ["dojo/_base/declare", "amitu/CommandLine", "dojo/keys"], 
    function(declare, CommandLine, keys){
        return declare(CommandLine, {
            postCreate: function() {
                this.inherited(arguments);
                this.$domNode.on("keyup", function(evt){
                    var key = evt.charCode || evt.keyCode || 0;
                    if (key == keys.UP_ARROW) console.log("UP_ARROW");
                    if (key == keys.DOWN_ARROW) console.log("DOWN_ARROW");
                })
            }
        });
    }
);