define(["dojo/_base/declare"], function(declare) {
    return declare(null, {
        autosave: true,
        review: false,
        filter: "",
        print_current: function() {
            ikog.print_line();
            ikog.println("[00] send mail to coupan owners");
            ikog.println("Priority: 05")
            ikog.println("Context:  @Anywhere")
            ikog.println("Created: [2009-03-10]")
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
            ikog.println("ikog.todo_list.filter = " + filter);          
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
        make_last: function(task) {
            ikog.println("kkog.todo_list.make_last()");
        },
        move_task_down: function(task) {
            ikog.println("kkog.todo_list.move_task_down()");
        },
        move_task_up: function(task) {
            ikog.println("kkog.todo_list.move_task_up()");
        },
        list_tasks: function(line) {
            ikog.println("kkog.todo_list.list_tasks()");
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
            ikog.println("kkog.todo_list.add_task()");
        },
        add_note: function(line) {
            ikog.println("kkog.todo_list.add_note()");
        }
    });
});