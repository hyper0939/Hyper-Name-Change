let minLength = 3
let maxLength = 15

function IsValidName(name) {
    if (!name) return false;
    if (name.length < minLength || name.length > maxLength) return false;
    return /^[A-Za-zÄÖÜäöüß]+$/.test(name);
}

function UpdateValidationIcon($input, $icon) {
    const value = $input.val().trim();

    if (value.length === 0) {
        $icon.attr("src", "images/False.png");
        return;
    }

    $icon.attr("src", IsValidName(value) ? "images/True.png" : "images/False.png");
}

function ResetUI() {
    $(".InformationText").text("");
    $(".VornameInput").removeClass("InputError");
    $(".NachnameInput").removeClass("InputError");
}

$(document).ready(function() {
    $(".container").hide();

    $(".VornameInput").on("input", function() {
        const val = $(this).val().trim();
        const valid = val.length >= minLength && val.length <= maxLength && /^[A-Za-zÄÖÜäöüß]+$/.test(val);
        $(".VornameFalse").attr("src", val.length === 0 ? "images/False.png" : valid ? "images/True.png" : "images/False.png");
    });

    $(".NachnameInput").on("input", function() {
        const val = $(this).val().trim();
        const valid = val.length >= minLength && val.length <= maxLength && /^[A-Za-zÄÖÜäöüß]+$/.test(val);
        $(".NachnameFalse").attr("src", val.length === 0 ? "images/False.png" : valid ? "images/True.png" : "images/False.png");
    });

    $(".Close").on("click", function() {
        $.post(`https://${GetParentResourceName()}/Close`, JSON.stringify({}));
        $(".container").fadeOut(500);
    });

    $(".Confirm").on("click", function() {
        const firstname = $(".VornameInput").val().trim();
        const lastname = $(".NachnameInput").val().trim();

        if (!IsValidName(firstname) || !IsValidName(lastname)) {
            $(".InformationText").text(`Bitte gib einen gültigen Vor- und Nachnamen ein (${minLength}-${maxLength} Zeichen, nur Buchstaben).`);
            UpdateValidationIcon($(".VornameInput"), $(".VornameFalse"));
            UpdateValidationIcon($(".NachnameInput"), $(".NachnameFalse"));
            return;
        }

        const currentFirstname = $(".VornameInput").data("original");
        const currentLastname = $(".NachnameInput").data("original");

        if (firstname.toLowerCase() === currentFirstname?.toLowerCase() && lastname.toLowerCase() === currentLastname?.toLowerCase()) {
            $(".InformationText").text("Du hast deinen Namen nicht geändert.");
            return;
        }

        $.post(`https://${GetParentResourceName()}/Confirm`, JSON.stringify({
            firstname: firstname,
            lastname: lastname
        }));
    });

    $(document).on("keyup", function(event) {
        if (event.key === "Escape") {
            $.post(`https://${GetParentResourceName()}/Close`, JSON.stringify({}));
            $(".container").hide();
        }
    })

    window.addEventListener("message", function(event) {
        let data = event.data;

        if (data.action === "Show") {
            ResetUI();

            minLength = data.minLength || 3;
            maxLength = data.maxLength || 15;

            $(".VornameInput").val(data.firstname || "").data("original", data.firstname || "");
            $(".NachnameInput").val(data.lastname || "").data("original", data.lastname || "");
            $(".VornameInput").trigger("input");
            $(".NachnameInput").trigger("input");

            if (data.useItem) {
                $(".Price").text(`Item: ${data.item}`);
            } else {
                $(".Price").text(`${Number(data.price).toLocaleString("de-DE")}$`);
            }

            $(".container").fadeIn(500);

        } else if (data.action === "Hide") {
            $(".container").fadeOut(500);
        } else if (data.action === "Error") {
        }
    });
});