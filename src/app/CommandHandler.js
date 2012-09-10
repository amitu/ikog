define(["dojo/_base/declare"], function(declare){
    return declare(null, {
        "install": function() { ikog.install_command_handler(this) },
        "uninstall": function() { ikog.reset_command_handler() }
    });
});