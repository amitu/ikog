define(
    [
        "dojo/_base/declare", "dojo/text!./templates/quick.html",
        "dojo/_base/lang", "dojo/text!./templates/info.html",
        "./CommandHandler", "./confirmer"
    ], function(declare, quicktxt, lang, infotxt, CommandHandler, confirmer){
        return declare(CommandHandler, {
            handle_command: function(command) {
                this.process_line(command);
                this.print_current_if_required();                                
            },
            parse_input: function(line) {
                var cmd = "", rest = "", orig = line;
                if (line.indexOf(ikog.todo_list.MAGIC_TAG) == 0)
                    ikog.print_error(
                        "You cannot begin lines with the sequence " + 
                        ikog.todo_list.MAGIC_TAG
                    )
                else if (line.indexOf(ikog.todo_list.ENCRYPTION_MARKER) == 0)
                    ikog.print_error(
                        "You cannot begin lines with the sequence " +
                        ikog.todo_list.ENCRYPTION_MARKER
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
            print_current_if_required: function(){
                if (!this.print_current) return;
                ikog.todo_list.print_current();
            },
            process_line: function(line) {
                this.print_current = true;
                ikog.println(">>> " + line);
                
                line = this.parse_input(line);
                
                var cmd = line.cmd.toUpperCase();
                
                if (cmd == "") {
                    if (ikog.todo_list.is_review()) {
                        ikog.todo_list.next_task();
                    }
                }
                else if (cmd == "?") {
                    this.print_current = false;
                    return ikog.println(quicktxt);
                }
                else if (cmd == "CLS" || cmd == "CLEARSCREEN") 
                    return ikog.clear_screen();
                else if (cmd == "HELP") {
                    this.print_current = false;
                    return ikog.show_help();
                }
                else if (cmd == "VER" || cmd == "VERSION") {
                    this.print_current = false;
                    return ikog.println(infotxt);
                }
                else if (cmd == "SAVE" || cmd == "S") ikog.todo_list.save()
                else if (cmd == "AUTOSAVE" || cmd == "AS") {
                    if (line.rest == "") ikog.todo_list.print_autosave();
                    else
                        ikog.todo_list.set_autosave(
                            line.rest.toUpperCase() == "ON"
                        )              
                    this.print_current = false;
                }
                else if (cmd == "REVIEW" || cmd == "REV") {
                    if (line.rest == "") ikog.todo_list.print_review();
                    else
                        ikog.todo_list.set_review(
                            line.rest.toUpperCase() == "ON"
                        )              
                    this.print_current = false;
                }
                else if (cmd == "BACKEND") {
                    if (ikog.todo_list.is_dirty())
                        confirmer({
                            cb:ikog.show_backend_selector, 
                            message: "There are unsaved changes, they will be lost, do you want to continue?"
                        })
                    else ikog.show_backend_selector()
                    this.print_current = false;
                }
                else if (cmd == "V0") ikog.todo_list.set_review(false)
                else if (cmd == "V1") ikog.todo_list.set_review(true)
                else if (cmd == "FILTER" || cmd == "FI" || cmd == "=")
                    ikog.todo_list.set_filter(line.rest)
                else if (cmd == "NEXT" || cmd == "N") ikog.todo_list.goto_next()
                else if (cmd == "PREV" || cmd == "P") ikog.todo_list.goto_prev()
                else if (cmd == "TOP" || cmd == "T" || cmd == "0")
                    ikog.todo_list.goto_top()
                else if (cmd == "GO" || cmd == "G") {
                    if (line.rest == "") {
                        ikog.print_error(
                            "You must enter task id for GO command."
                        );
                        this.print_current = false;                        
                    }
                    else
                        ikog.todo_list.goto_task(line.rest);
                }
                else if (cmd == "IMMEDIATE" || cmd == "I" || cmd == "++")
                    ikog.todo_list.create_immediate_task(line.rest)
                else if (cmd == "KILL" || cmd == "K" || cmd == "-" || cmd == "X")
                    ikog.todo_list.kill_task(line.rest)
                else if (cmd == "ARCHIVE" || cmd == "DONE")
                    ikog.todo_list.archive_task(line.rest)
                else if (cmd == "REP" || cmd == "R") 
                    ikog.todo_list.replace_task(line.rest)
                else if (cmd == "SUB" || cmd == "S") 
                    ikog.todo_list.substitute_task(line.rest)
                else if (cmd == "EDIT" || cmd == "E") 
                    ikog.todo_list.edit_task(line.rest)
                else if (cmd == "MOD" || cmd == "M") 
                    ikog.todo_list.modify_task(line.rest)
                else if (cmd == "EXTEND" || cmd == "E") 
                    ikog.todo_list.extend_task(line.rest)
                else if (cmd == "FIRST" || cmd == "F") 
                    ikog.todo_list.make_first(line.rest)
                else if (cmd == "DOWN" || cmd == "D") 
                    ikog.todo_list.move_task_down(line.rest)
                else if (cmd == "UP" || cmd == "U") 
                    ikog.todo_list.move_task_up(line.rest)
                else if (cmd == "LIST" || cmd == "L") {
                    ikog.todo_list.list_tasks(line.rest);
                    this.print_current = false;
                }
                else if (cmd == "@") {
                    ikog.todo_list.list_tasks_by_context(line.rest);
                    this.print_current = false;
                }
                else if (cmd == "#") {
                    ikog.todo_list.list_tasks_by_project(line.rest);
                    this.print_current = false;
                }
                else if (cmd == ":D")  {
                    ikog.todo_list.list_tasks_by_date(line.rest);
                    this.print_current = false;
                }
                else if (cmd == "ADD" || cmd == "A" || cmd == "+") 
                    if (lang.trim(line.rest) == "") {
                        ikog.print_error("You must enter task description");
                        this.print_current = false;
                    }
                    else {
                        if (!ikog.todo_list.add_task(line.rest))
                            this.print_current = false;
                    }
                else if (cmd == "NOTE" || cmd == "NOTES")
                    ikog.todo_list.add_note(line.rest)
                else if (line.orig.length > 10) {
                    if (!ikog.todo_list.add_task(line.orig))
                        this.print_current = false;
                }
                else if (cmd.length > 0) {
                    ikog.print_error("Didn't understand. (Make sure you have a space after the command or your\nentry is longer than 10 characters)")
                    this.print_current = false;
                }                   
            }            
        });
    }
);