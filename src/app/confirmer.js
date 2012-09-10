define(
    ["dojo/_base/declare", "dojo/_base/lang", "./CommandHandler"], 
    function(declare, lang, CommandHandler){
        var Confirmer = declare(CommandHandler, {
            message: "Are you sure you want to do this?",
            yes: "Yes",
            no: "No",
            cb:  function(){ ikog.println("Ok") },
            nocb: function(){ ikog.println("Cancelled")},
            constructor: function(kwargs) {
                lang.mixin(this, kwargs);
                this.yesl = this.yes.toLowerCase();
                this.nol = this.no.toLowerCase();
                this.install();
                this.print_prompt();
            },
            print_prompt: function() {
                ikog.println(
                    this.message + " [" + this.yes + "/" + this.no + "]"
                );                
            },
            handle_command: function(command) {
                ikog.println(command);
                var cl = command.toLowerCase();
                if (cl != this.yesl && cl != this.nol) {
                    ikog.print_error("Incorrect reply, try again.")
                    this.print_prompt()
                    return;                    
                }
                if (cl == this.yesl) this.cb();
                else this.nocb();
                this.uninstall();
            }
        });
        return function(args) {
            if (typeof args == "function") args = {cb: args};
            return new Confirmer(args);
        }
    }
);