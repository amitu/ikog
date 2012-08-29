define(
    ["dojo/_base/declare", "./TodoList"], 
    function(declare, TodoList) {
        return declare(TodoList, {
            constructor: function() {
                this.puser = Parse.User.current(); 
                var lines = this.puser.get("ikog_tasks");
                if (!lines) lines = "";
                lines = lines.split("\n");
                this.inherited(arguments, [lines]);
            },
            save: function() {
                this.puser.set("ikog_tasks", this.toString());
                this.puser.save(null, {
                    success: function() {ikog.println("Saved.") },
                    error: function() { 
                        ikog.println("PANICL: Error Saving List") 
                    }
                })
            }
        });
    }
);
