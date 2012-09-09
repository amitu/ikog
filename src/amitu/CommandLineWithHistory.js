define(
    ["dojo/_base/declare", "amitu/CommandLine", "dojo/keys"], 
    function(declare, CommandLine, keys){
        return declare(CommandLine, {
            history: null,
            index: 0,
            current_line: "",
            postCreate: function() {
                this.inherited(arguments);
                this.history = [];
                var widget = this;
                widget.$domNode.on("keyup", function(evt){
                    var key = evt.charCode || evt.keyCode || 0;
                    if (key == keys.UP_ARROW) widget.goup();
                    else if (key == keys.DOWN_ARROW) widget.godown();
                    else widget.gonormal(key);
                });
                this.on("command", function(cmd) {
                    this.history.push(cmd);
                });
                console.log(this);
            },
            goup: function() {
                // if index is zero, we have just started going up in history
                if (this.index >= this.history.length) return;
                if (this.index == 0) this.current_line = this.$domNode.val();
                this.index += 1;
                this.$domNode.val(this.history[this.history.length - this.index]);
            },
            godown: function() {
                if (this.index == 0) return;
                this.index -= 1;
                if (this.index == 0) this.$domNode.val(this.current_line);
                else { 
                    this.$domNode.val(
                        this.history[this.history.length - this.index]
                    );
                }
            },
            gonormal: function(key) {
                this.index = 0;
                this.current_line = "";
            }
        });
    }
);