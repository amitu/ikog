define(["dojo/_base/declare"], function(declare) {
	return declare(null, {
		LINES_IN_PAGE: 12,
		remaining_lines: [],
		ikog: undefined,
		constructor: function(ikog, lines) {
			this.ikog = ikog;
			this.remaining_lines = lines;
			this.print_once();
		},
		dump_state: function() {
			console.log("LINES_IN_PAGE", this.LINES_IN_PAGE);
			console.log("remaining_lines", this.remaining_lines);
			console.log("ikog", this.ikog);
		},
		print_once: function() {
			var lines = this.remaining_lines;
			this.remaining_lines = lines.slice(this.LINES_IN_PAGE);
			var lines_to_display = lines.slice(0, this.LINES_IN_PAGE);
			for (i=0; i < lines_to_display.length; i++)
			{
				this.ikog.println(lines_to_display[i]);
			}
			if (!this.done()) {
				this.ikog.println(
					"--- Press enter for more. Enter s to skip ---"
				);
			}		
		},
		done: function() {
			return this.remaining_lines.length == 0;
		},
		process_line: function(line) {
			if (line == "s") {
				this.ikog.println("Skipped.");
				this.ikog.pager = undefined;
				return;
			}
			this.print_once();
			if (this.done()) this.ikog.pager = undefined;
		}
	})
});