define(
    ["dojo/_base/declare", "./TodoList"], 
    function(declare, TodoList) {
        return declare(TodoList, {
            constructor: function() {
                this.inherited(arguments, [$.jStorage.get("ikog_tasks")]);
            },
            save: function() {
                $.jStorage.set("ikog_tasks", this.toString());
                ikog.println("Saved.");
            }
        });
    }
);
