define(["dojo/_base/declare", "app/Pager"], function(declare, Pager) {
	return declare(Pager, {
		PAUSE: "!PAUSE!",
		print_once: function() {
			var lines = this.remaining_lines;
			var i = 0;
			for (i = 0; i < lines.length; i++)
			{
				if (lines[i] == this.PAUSE) break;
			}
			this.remaining_lines = lines.slice(i+1);
			var lines_to_display = lines.slice(0, i);
			for (i=0; i < lines_to_display.length; i++)
			{
				ikog.println(lines_to_display[i]);
			}
			if (!this.done())
				ikog.println("--- Press enter for more. Enter s to skip ---");
		}
	});
});
