define(["dojo/_base/declare"], function(declare) {
    return declare(null, {
        constructor: function (line) {
            this.actions = [];
            this.task = "";
            this.projects = [];
            this.priority = -1;
            this.when = "";
            this.created = (new Date()).toISOString();
            this.error = "";
            this.nullDate = undefined;
            this.parse(line);
        },
        print: function() {
            ikog.println("[00] send mail to coupan owners");
            ikog.println("Priority: 05");
            ikog.println("Context:  @Anywhere");
            ikog.println("Created: [2009-03-10]" );
        },
        parse: function(line) {
            if (line == "foo") throw "eff you!"; 
            this.task = line;
        },
        toString: function() {
            return this.task;
        }
    });
});