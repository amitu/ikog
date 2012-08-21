define(
    ["dojo/_base/declare", "./TodoList"], 
    function(declare, TodoList) {
        return declare(TodoList, {
            constructor: function() {
                var lines = $.jStorage.get("ikog_tasks");
                if (!lines) lines = "";
                lines = lines.split("\n");
                this.inherited(arguments, [lines]);
            },
            save: function() {
                $.jStorage.set("ikog_tasks", this.toString());
                ikog.println("LSTodoList.save()");
            }
        });
    }
);
