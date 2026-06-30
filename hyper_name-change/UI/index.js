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
    $("InformationText").text("");
    $("VornameInput").removeClass("InputError");
    $("NachnameInput").removeClass("InputError");
}

$(document).ready(function() {
    $(".container").hide();

    $("VornameInput").on("input", function() {
        UpdateValidationIcon($(this), $(".VornameFalse"));
    });

    $("NachnameInput").on("input", function() {
        UpdateValidationIcon($(this), $(".NachnameFalse"));
    });

    $(".Close").on("click", function() {
        $.post(`https://${GetParentResourceName()}/Close`, JSON.stringify({}));
        $(".container").hide();
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

            $(".VornameInput").val(data.firstname || "");
            $(".NachnameInput").val(data.lastname || "");

            UpdateValidationIcon($(".VornameInput"), $(".VornameFalse"));
            UpdateValidationIcon($(".NachnameInput"), $(".NachnameFalse"));

            if (data.useItem) {
                $(".Price").text(`Item: ${data.item}`);
            } else {
                $(".Price").text(`${Number(data.price).toLocaleString("de-DE")}$`);
            }

            $(".container").show();
            $(".VornameInput").trigger("focus");

        } else if (data.action === "Hide") {
            $(".container").hide();
        } else if (data.action === "Error") {
        }
    });
});