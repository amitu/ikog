define(
    ["dojo/_base/declare", "dojo/topic", "./TodoList"], 
    function(declare, topic, TodoList) {
        return declare(TodoList, {
            constructor: function() {
                this.puser = Parse.User.current(); 
                this.inherited(arguments, [this.puser.get("ikog_tasks")]);
            },
            save: function() {
                var orig = this.toString();
                this.puser.set("ikog_tasks", orig);
                if (!this.autosave) ikog.println("Saving...");
                topic.publish("todolist/saving");
                this.puser.save(null, {
                    success: function() {
                        if (!this.autosave) ikog.println("Saved.");
                        topic.publish("todolist/saved");
                        if (orig == this.toString()) {
                            this.dirty = false;
                            topic.publish("todolist/clean");
                        }
                    },
                    error: function() { 
                        ikog.println("PANICL: Error Saving List") 
                    }
                });
            }
        });
    }
);
