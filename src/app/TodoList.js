define(
    ["dojo/_base/declare", "dojo/_base/array", "app/TodoItem", "dojo/topic"], 
    function(declare, array, TodoItem, topic) {
        return declare(null, {
            MAGIC_TAG: "#!<^",
            ENCRYPTION_MARKER: "{}--xx",
            autosave: true,
            dirty: false,
            review: false,
            filter: "",
            current_task: undefined,
            current_task_id: -1,
            constructor: function(lines) {
                if (!lines) lines = "";
                lines = lines.split("\n");                
                this.todos = [];
                array.map(
                    lines, function(line) { if (line) this.add_task(line)}, this
                );
                topic.publish("todolist/initialized");
                topic.publish("todolist/clean");
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
                ikog.println("SAVE NOT IMPLEMENTED");
            },
            print_autosave: function() {
                ikog.println("autosave=" + !!this.autosave)
            },
            set_autosave: function (autosave) {
                this.autosave = autosave;
                this.print_autosave();
                this.save_if_autosave();                
                topic.publish("todolist/autosave", autosave);
            },
            print_review: function() {
                ikog.println("review=" + !!this.review)
            },
            set_review: function (review) {
                this.review = review;
                this.print_review();
                ikog.println("ikog.todo_list.review = " + review);
                this.save_if_autosave();
                topic.publish("todolist/review", review);
            },
            set_filter: function (filter) {
                this.filter = filter;
                this.goto_top();
                this.save_if_autosave();                
                topic.publish("todolist/filter", filter);
            },
            goto_next: function() {
                var filtered_tasks = this._filtered_tasks();
                if (filtered_tasks.length === 0) return;
                this.current_task_id += 1;
                if (filtered_tasks.length <= this.current_task_id)
                    this.current_task_id = 0;
                this.current_task = filtered_tasks[this.current_task_id];
                this.save_if_autosave();
                topic.publish("todolist/itemswitched")
            },
            goto_prev: function() {
                var filtered_tasks = this._filtered_tasks();
                if (filtered_tasks.length === 0) return;
                this.current_task_id -= 1;
                if (this.current_task_id < 0)
                    this.current_task_id = filtered_tasks.length - 1;
                this.current_task = filtered_tasks[this.current_task_id];
                this.save_if_autosave();                
                topic.publish("todolist/itemswitched")
            },
            goto_top: function() {
                var filtered_tasks = this._filtered_tasks();
                if (filtered_tasks.length) {
                    this.current_task = filtered_tasks[0];
                    this.current_task_id = 0;
                }
                this.save_if_autosave();                
                topic.publish("todolist/itemswitched")
            },
            goto_task: function(task) {
                var filtered_tasks = this._filtered_tasks();
                if (filtered_tasks.length === 0) return;
                task = parseInt(task);
                if (task < 0) task = 0;
                if (task >= filtered_tasks.length) task = filter.length - 1;
                this.current_task_id = task;
                this.current_task = filtered_tasks[this.current_task_id];
                this.save_if_autosave();                
                topic.publish("todolist/itemswitched")
            },
            create_immediate_task: function(line) {
                ikog.println("ikog.todo_list.create_immediate_task()");
                this.save_if_autosave();                
            },
            kill_task: function(task) {
                ikog.println("kkog.todo_list.kill_task()");
                this.save_if_autosave();          
            },
            archive_task: function(task) {
                ikog.println("kkog.todo_list.archive_task()");
                this.save_if_autosave();                
            },
            replace_task: function(task) {
                ikog.println("kkog.todo_list.replace_task()");
                this.save_if_autosave();                
            },
            substitute_task: function(task) {
                ikog.println("kkog.todo_list.substitute_task()");
                this.save_if_autosave();                
            },
            edit_task: function(task) {
                ikog.println("kkog.todo_list.edit_task()");
                this.save_if_autosave();                
            },
            modify_task: function(task) {
                ikog.println("kkog.todo_list.modify_task()");
                this.save_if_autosave();                
            },
            extend_task: function(task) {
                ikog.println("kkog.todo_list.extend_task()");
                this.save_if_autosave();                
            },
            make_first: function(task) {
                ikog.println("kkog.todo_list.make_first()");
                this.save_if_autosave();                
            },
            move_task_down: function(task) {
                ikog.println("kkog.todo_list.move_task_down()");
                this.save_if_autosave();                
            },
            move_task_up: function(task) {
                ikog.println("kkog.todo_list.move_task_up()");
                this.save_if_autosave();                
            },
            _filtered_tasks: function(rest) {
                var todos = [];
                for (i=0; i < this.todos.length; i++) {
                    var task = this.todos[i];
                    if (task.matches(this.filter, rest)) todos.push(task);
                }                
                return todos;
            },
            list_tasks: function(rest) {
                ikog.print_line();
                var filtered_tasks = this._filtered_tasks(rest);
                for (i=0; i < filtered_tasks.length; i++) 
                    filtered_tasks[i].print(i);
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
                var projects = {};
                for (i=0; i < this.todos.length; i++) {
                    var task = this.todos[i];
                    if (task.projects.length === 0) {
                        if (projects["No Project"]) 
                            projects["No Project"].push(task);
                        else
                            projects["No Project"] = [task];
                        continue;
                    }
                    for (j=0; j < task.projects.length; j++) {
                        if (projects[task.projects[j]])
                            projects[task.projects[j]].push(task);
                        else
                            projects[task.projects[j]] = [task];
                    }
                }
                ikog.print_line();
                var first = true;
                for (project in projects) {
                    if (first) first = false;
                    else ikog.println("&nbsp;");
                    ikog.println(project);
                    for (i=0; i < projects[project].length; i ++)
                        projects[project][i].print(i);
                }
                ikog.print_line();
                if (this.current_task) 
                    this.current_task.print_as_current(this.current_task_id);
                else
                    ikog.println("Current:  no tasks")
                ikog.print_line();
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
                    if (!this.current_task) this.current_task = new_item;
                    this.save_if_autosave();
                    topic.publish("todolist/newtask", new_item);
                }
                return new_item;
            },
            add_note: function(line) {
                ikog.println("kkog.todo_list.add_note()");
                this.save_if_autosave();
            },
            save_if_autosave: function () {
                this.dirty = true;
                topic.publish("todolist/dirty");
                if (this.autosave) this.save();
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