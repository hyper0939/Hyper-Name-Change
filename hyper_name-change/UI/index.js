$(document).ready(function() {
    $(".container").hide();

    window.addEventListener("message", function(event) {
        let data = event.data;

        if (data.action === "Show") {
            
        } else if (data.action === "Hide") {
            
        }
    });
});