define(
    ["dojo/_base/declare", "./TodoList"], 
    function(declare, TodoList) {
        return declare(TodoList, {
            constructor: function() {
                this.puser = Parse.User.current(); 
                this.inherited(arguments, [this.puser.get("ikog_tasks")]);
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
