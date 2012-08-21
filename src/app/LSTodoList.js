define(
    ["dojo/_base/declare", "./TodoList"], 
    function(declare, TodoList) {
        return declare(TodoList, {
            constructor: function() {
                var lines = $.jStorage.get("ikog_tasks");
                if (!lines) lines = [];
                console.log("LSTodoList.constructor: ", lines);
                this.inherited(arguments, [lines]);
            },
            save: function() {
                $.jStorage.set("ikog_tasks", ["hi there"]);
                ikog.println("LSTodoList.save()");
            }
        });
    }
);
