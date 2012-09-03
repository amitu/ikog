define(["dojo/_base/declare", "dojo/_base/lang"], function(declare, lang) {
    return declare(null, {
        constructor: function (line) {
            this.actions = [];
            this.task = "";
            this.projects = [];
            this.priority = -1;
            this.when = "";
            this.created = (new Date()).toISOString();
            this.nullDate = undefined;
            this.parse(line);
        },
        print_verbose: function(i) {
            ikog.println("[" + i + "] " + this.task);
            ikog.println("Priority: " + this.priority);
            ikog.println("Context:  " + this.actions.join(","));
            if (this.projects.length) 
                ikog.println("Project:  " + this.projects.join(","));
            if (this.when)
                ikog.println("When: [" + this.when + "]");
            ikog.println("Created: [2009-03-10]" );
        },
        print: function(i) {
            ikog.println("[" + i + "] " + this.task);
        },
        print_as_current: function(i) {
            ikog.println("Current: [" + i + "] " + this.task);
        },
        parse_date: function(word){
            return undefined;
        },
        parse: function(line) {
            var words = line.split(" ")
            var start = 0
            for (i=0; i < words.length; i++) {
                var word = words[i];
                var wl = word.length;
                var wt = lang.trim(word);
                var wordUC = lang.trim(word).toUpperCase()
                if (wl == 0) continue;
                
                if (word[0] == "@" && wl > 1) 
                    this.actions.push(wt);
                else if (word[0]== "#" && wl > 1 && self.priority == -1) {
                    var pri = parseInt(word.substring(1));
                    if (pri == NaN) throw "Did not understand priority."
                    if (pri < 1)  pri = 0
                    if (pri > 10) pri = 10
                    this.priority = pri;
                }
                else if (wordUC.substring(0, 2) == ":P" && len(word) > 2)
                    this.projects.append(wt.substring(2))
                else if (wordUC.substring(0, 2) == ":D" && len(word) > 2)
                    this.when = this.parse_date(wt.substring(2))
                else
                    this.task = this.task + wt + " "
            }
            if (this.actions.length == 0) this.actions.push("@Anywhere")            
        },
        toString: function() {
            return this.task;
        }
    });
});