define(
    [
        "require", "dojo/_base/lang", "dojo/query", "dojo/parser",
        "dojo/dom-construct", "dojo/window", "app/Pager", "app/PausePager",
        "./LSTodoList", "dojo/json", "dojo/text!./templates/banner.html",
        "dojo/text!./templates/info.html", "dojo/text!./templates/help.html",
        "dojo/text!./templates/quick.html", "app/ParseTodoList",
        "amitu/NodeList-on_enter", "amitu/NodeList-focus",
        "dijit/layout/ContentPane", "dijit/Dialog",
        "dijit/layout/BorderContainer", "dijit/form/Button"
    ], 
    function(
        require, lang, query, parser, dc, win, Pager, PausePager, LSToDoList,
        JSON, bannertxt, infotxt, helptxt, quicktxt, ParseTodoList
    ) {
        var ikog = {
            MAGIC_TAG: "#!<^",
            ENCRYPTION_MARKER: "{}--xx",
            print_current: true,
            log_id: 0,
            pager: undefined,
            init: function() {
                ikog.print_banner();
                parser.parse();
                var backend = $.jStorage.get("ikog_backend");
                if  (backend === null)
                    return ikog.show_backend_selector();
                ikog.select_backend(backend);
                ikog.$inp = query("#inp");
                ikog.$inp.focus().on_enter(function(line){
                    ikog.process_line(line);
                    ikog.print_current_if_required();
                }, true); //on_ctrl("l", function(){ this.clear_screen() });
                query("body").on("click", function(){ ikog.$inp.focus(); });
            },
            select_backend: function(backend) {
                $.jStorage.set("ikog_backend", backend);
                if (backend === "localstore")
                    this.todo_list = new LSToDoList();
                else if (backend === "parse") {
                    this.todo_list = new ParseTodoList();
                }
                else {
                    ikog.print_error("Invalid backend: " + backend);
                    return ikog.show_backend_selector();
                }
                ikog.print_current_if_required();
            },
            show_backend_selector: function () {
                storage_picker.show();
            },
            println: function(msg){
                ikog.log_id += 1;
                dc.place(
                    "<pre class='log_msg' id='log_msg_" + ikog.log_id + "'>" + 
                    msg + "</pre>", "log"
                );
                win.scrollIntoView("log_msg_" + ikog.log_id);
            },
            print_error: function(msg) {
                this.println("ERROR: " + msg);
            },
            print_line: function() {
                this.println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            },
            print_current_if_required: function(){
                if (!this.print_current) return;
                this.todo_list.print_current();
            },
            clear_screen: function() {
                dc.empty("log");
                this.println(bannertxt);
            },
            print_banner: function () {
                ikog.println(bannertxt);
                ikog.println("Enter HELP for instructions.");         
            },
            page: function(lines) {
                ikog.pager = new Pager(lines);
                if (ikog.pager.done()) this.pager = undefined;
            },
            show_help: function() {
                ikog.pager = new PausePager(helptxt.split("\n"));
            },
            parse_input: function(line) {
                var cmd = "", rest = "", orig = line;
                if (line.indexOf(this.MAGIC_TAG) == 0)
                    this.print_error(
                        "You cannot begin lines with the sequence " + this.MAGIC_TAG
                    )
                else if (line.indexOf(this.ENCRYPTION_MARKER) == 0)
                    this.print_error(
                        "You cannot begin lines with the sequence " + this.ENCRYPTION_MARKER
                    )
                else {
                    var n = line.indexOf(" ")
                    if (n >= 0) {
                        cmd = line.substring(0, n);
                        rest = line.substring(n + 1);
                    }
                    else {
                        cmd = line;
                        rest = "";
                    }
                }
                // TODO: handle shortcuts
                return {cmd: cmd, rest: rest, orig: orig};
            },
            next_task: function() {}, // TODO
            process_line: function(line) {
                this.print_current = true;
                if (this.pager) {
                    this.print_current = false;
                    return this.pager.process_line(line);
                }

                ikog.println(">>> " + line);
                
                line = this.parse_input(line);
                
                var cmd = line.cmd.toUpperCase();
                
                if (cmd == "") {
                    if (this.review) {
                        this.next_task();
                    }
                }
                else if (cmd == "?") {
                    this.print_current = false;
                    return this.println(quicktxt);
                }
                else if (cmd == "CLS" || cmd == "CLEARSCREEN") 
                    return this.clear_screen();
                else if (cmd == "HELP") {
                    this.print_current = false;
                    return this.show_help();
                }
                else if (cmd == "VER" || cmd == "VERSION") {
                    this.print_current = false;
                    return this.println(infotxt);
                }
                else if (cmd == "SAVE" || cmd == "S") this.todo_list.save()
                else if (cmd == "AUTOSAVE" || cmd == "AS") {
                    if (line.rest == "") {
                        this.print_error(
                            "You must enter ON or OFF for the autosave command"
                        );
                        this.print_current = false;                        
                    }
                    else
                        this.todo_list.set_autosave(
                            line.rest.toUpperCase() == "ON"
                        )              
                }
                else if (cmd == "REVIEW" || cmd == "REV") {
                    if (line.rest == "") {
                        this.print_error(
                            "You must enter ON or OFF for the review command"
                        );
                        this.print_current = false;                        
                    }
                    else
                        this.todo_list.set_review(
                            line.rest.toUpperCase() == "ON"
                        )              
                }
                else if (cmd == "BACKEND") this.show_backend_selector()
                else if (cmd == "V0") this.todo_list.set_review(false)
                else if (cmd == "V1") this.todo_list.set_review(true)
                else if (cmd == "FILTER" || cmd == "FI" || cmd == "=")
                    this.todo_list.set_filter(line.rest)
                else if (cmd == "NEXT" || cmd == "N") this.todo_list.goto_next()
                else if (cmd == "PREV" || cmd == "P") this.todo_list.goto_prev()
                else if (cmd == "TOP" || cmd == "T" || cmd == "0")
                    this.todo_list.goto_top()
                else if (cmd == "GO" || cmd == "G") 
                    this.todo_list.goto_task(line.rest)
                else if (cmd == "IMMEDIATE" || cmd == "I" || cmd == "++")
                    this.todo_list.create_immediate_task(line.rest)
                else if (cmd == "KILL" || cmd == "K" || cmd == "-" || cmd == "X")
                    this.todo_list.kill_task(line.rest)
                else if (cmd == "ARCHIVE" || cmd == "DONE")
                    this.todo_list.archive_task(line.rest)
                else if (cmd == "REP" || cmd == "R") 
                    this.todo_list.replace_task(line.rest)
                else if (cmd == "SUB" || cmd == "S") 
                    this.todo_list.substitute_task(line.rest)
                else if (cmd == "EDIT" || cmd == "E") 
                    this.todo_list.edit_task(line.rest)
                else if (cmd == "MOD" || cmd == "M") 
                    this.todo_list.modify_task(line.rest)
                else if (cmd == "EXTEND" || cmd == "E") 
                    this.todo_list.extend_task(line.rest)
                else if (cmd == "FIRST" || cmd == "F") 
                    this.todo_list.make_first(line.rest)
                else if (cmd == "DOWN" || cmd == "D") 
                    this.todo_list.move_task_down(line.rest)
                else if (cmd == "UP" || cmd == "U") 
                    this.todo_list.move_task_up(line.rest)
                else if (cmd == "LIST" || cmd == "L") {
                    this.todo_list.list_tasks(line.rest);
                    this.print_current = false;
                }
                else if (cmd == "@") 
                    this.todo_list.list_tasks_by_context(line.rest)
                else if (cmd == ":P") 
                    this.todo_list.list_tasks_by_project(line.rest)
                else if (cmd == ":D") 
                    this.todo_list.list_tasks_by_date(line.rest)
                else if (cmd == "ADD" || cmd == "A" || cmd == "+") 
                    if (lang.trim(line.rest) == "") {
                        this.print_error("You must enter task description");
                        this.print_current = false;
                    }
                    else {
                        if (!this.todo_list.add_task(line.rest))
                            this.print_current = false;
                    }
                else if (cmd == "NOTE" || cmd == "NOTES")
                    this.todo_list.add_note(line.rest)
                else if (line.orig.length > 10) {
                    if (!this.todo_list.add_task(line.orig))
                        this.print_current = false;
                }
                else if (cmd.length > 0) {
                    this.print_error("Didn't understand. (Make sure you have a space after the command or your\nentry is longer than 10 characters)")
                    this.print_current = false;
                }                   
            }
        }
        window.ikog = ikog;
        window.$ = {toJSON: JSON.stringify, evalJSON: JSON.parse};
        require(["jstorage.js", "dojo/domReady!"], function(){ ikog.init(); });
        return ikog;
    }
);
