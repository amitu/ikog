define(
    [
        "require", "dojo/_base/lang", "dojo/query", "dojo/parser",
        "dojo/dom-construct", "dojo/window", "app/Pager", "app/PausePager",
        "./LSTodoList", "./TodoCommandHandler", "dojo/json",
        "dojo/text!./templates/banner.html", "dojo/text!./templates/help.html",
        "app/ParseTodoList", "dijit/registry", "amitu/NodeList-focus",
        "dijit/layout/ContentPane", "dijit/Dialog",
        "dijit/layout/BorderContainer", "dijit/form/Button",
        "amitu/CommandLineWithHistory"
    ], 
    function(
        require, lang, query, parser, dc, win, Pager, PausePager, LSToDoList,
        TodoCommandHandler, JSON, bannertxt, helptxt, ParseTodoList, registry
    ) {
        var ikog = {
            log_id: 0,
            init: function() {
                ikog.print_banner();
                parser.parse();
                this.default_command_handler = new TodoCommandHandler();
                this.reset_command_handler();
                registry.byId("inp").on("command", ikog.handle_command);
                query("body").on("click", function(){ query("#inp").focus(); });
                var backend = $.jStorage.get("ikog_backend");
                if  (backend === null)
                    return ikog.show_backend_selector();
                ikog.select_backend(backend);
            },
            handle_command: function(command) {
                ikog.current_command_handler.handle_command(command);
            },
            reset_command_handler: function() {
               this.current_command_handler = this.default_command_handler;
            },
            install_command_handler: function(handler) {
                this.current_command_handler = handler;
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
                ikog.todo_list.print_current();
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
            clear_screen: function() {
                dc.empty("log");
                this.println(bannertxt);
            },
            print_banner: function () {
                ikog.println(bannertxt);
                ikog.println("Enter HELP for instructions.");         
            },
            page: function(lines) {
                new Pager(lines);
            },
            show_help: function() {
                new PausePager(helptxt.split("\n"));
            }
        }
        window.ikog = ikog;
        window.$ = {toJSON: JSON.stringify, evalJSON: JSON.parse};
        require(["jstorage.js", "dojo/domReady!"], function(){ ikog.init(); });
        return ikog;
    }
);
