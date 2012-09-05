define(
    ["dojo/_base/declare", "./TodoList", "dojo/topic"], 
    function(declare, TodoList, topic) {
        return declare(TodoList, {
            constructor: function() {
                this.inherited(arguments, [$.jStorage.get("ikog_tasks")]);
            },
            save: function() {
                topic.publish("todolist/saving");
                $.jStorage.set("ikog_tasks", this.toString());
                this.dirty = false;
                if (!this.autosave) ikog.println("Saved.");
                topic.publish("todolist/saved");
                topic.publish("todolist/clean");
            }
        });
    }
);
