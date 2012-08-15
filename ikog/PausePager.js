define(["dojo/_base/declare", "ikog/Pager"], function(declare, Pager) {
	return declare(Pager, {
		PAUSE: "!PAUSE!",
		print_once: function() {
			var lines = this.remaining_lines;
			var i = 0;
			for (i = 0; i < lines.length; i++)
			{
				if (lines[i] == this.PAUSE) break;
			}
			console.log("print_once");
			console.log("remaining_lines", this.remaining_lines);
			this.remaining_lines = lines.slice(i+1);
			console.log("remaining_lines", this.remaining_lines);
			var lines_to_display = lines.slice(0, i);
			console.log("lines_to_display", lines_to_display);
			for (i=0; i < lines_to_display.length; i++)
			{
				this.ikog.println(lines_to_display[i]);
			}
			if (!this.done()) {
				this.ikog.println(
					"--- Press enter for more. Enter s to skip ---"
				);
			}
		}
	});
});
