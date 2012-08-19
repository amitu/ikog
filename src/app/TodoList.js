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
		}
	});
});