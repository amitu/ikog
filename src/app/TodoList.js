define(
    ["dojo/_base/declare", "dojo/_base/array", "app/TodoItem"], 
    function(declare, array, TodoItem) {
        return declare(null, {
            autosave: true,
            review: false,
            filter: "",
            current_task: undefined,
            current_task_id: 42,
            constructor: function(lines) {
                if (!lines) lines = "";
                lines = lines.split("\n");                
                this.todos = [];
                array.map(
                    lines, function(line) { if (line) this.add_task(line)}, this
                );
            },
            print_current: function() {
                ikog.print_line();
                if (this.current_task)
                    this.current_task.print_verbose(this.current_task_id)
                else
                    ikog.println("There are no tasks to be done.")
                ikog.print_line();              
            },
            save: function() {
                ikog.println("Saving...");
            },
            set_autosave: function (autosave) {
                this.autosave = autosave;
                ikog.println("ikog.todo_list.autosave = " + autosave);
            },
            set_review: function (review) {
                this.review = review;
                ikog.println("ikog.todo_list.review = " + review);
            },
            set_filter: function (filter) {
                this.filter = filter;
                for (i=0; i < this.todos.length; i++) {
                    var task = this.todos[i];
                    if (task.matches(this.filter)) {
                        this.current_task_id = i;
                        this.current_task = task;
                        break;
                    }
                }                
            }, 
            goto_next: function() {
                ikog.println("ikog.todo_list.next()");
            },
            goto_prev: function() {
                ikog.println("ikog.todo_list.prev()");
            },
            goto_top: function() {
                ikog.println("ikog.todo_list.top()");
            },
            goto_task: function(task) {
                ikog.println("ikog.todo_list.goto_task()");
            },
            create_immediate_task: function(line) {
                ikog.println("ikog.todo_list.create_immediate_task()");
            },
            kill_task: function(task) {
                ikog.println("kkog.todo_list.kill_task()");
            },
            archive_task: function(task) {
                ikog.println("kkog.todo_list.archive_task()");
            },
            replace_task: function(task) {
                ikog.println("kkog.todo_list.replace_task()");
            },
            substitute_task: function(task) {
                ikog.println("kkog.todo_list.substitute_task()");
            },
            edit_task: function(task) {
                ikog.println("kkog.todo_list.edit_task()");
            },
            modify_task: function(task) {
                ikog.println("kkog.todo_list.modify_task()");
            },
            extend_task: function(task) {
                ikog.println("kkog.todo_list.extend_task()");
            },
            make_first: function(task) {
                ikog.println("kkog.todo_list.make_first()");
            },
            move_task_down: function(task) {
                ikog.println("kkog.todo_list.move_task_down()");
            },
            move_task_up: function(task) {
                ikog.println("kkog.todo_list.move_task_up()");
            },
            list_tasks: function(rest) {
                ikog.print_line();
                for (i=0; i < this.todos.length; i++) {
                    var task = this.todos[i];
                    if (task.matches(this.filter, rest)) task.print(i);
                }
                ikog.print_line();
                if (this.current_task) 
                    this.current_task.print_as_current(this.current_task_id);
                else
                    ikog.println("Current:  no tasks")
                ikog.print_line();
            },
            list_tasks_by_context: function(line) {
                ikog.println("kkog.todo_list.list_tasks_by_context()");
            },
            list_tasks_by_project: function(line) {
                ikog.println("kkog.todo_list.list_tasks_by_project()");
            },
            list_tasks_by_date: function(line) {
                ikog.println("kkog.todo_list.list_tasks_by_date()");
            },
            add_task: function(line) {
                var new_item;
                try {
                    new_item = new TodoItem(line);
                } catch (e) {
                    ikog.print_error(
                        "Errors were found:\n" + e + "\nThe task was not added."
                    )                
                }
                if (new_item) {
                    this.todos.push(new_item);
                    this.sort_by_priority();
                    this.current_task = new_item;
                }
                return new_item;
            },
            add_note: function(line) {
                ikog.println("kkog.todo_list.add_note()");
            },
            sort_by_priority: function () {},
            toString: function() {
                return array.map(this.todos, function(todo) {
                    return todo.toString();
                }).join("\n");
            }
        });
    }
);