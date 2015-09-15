var carparkPath = "";
function refreshCalendar(carpark_path) {

    var calendar = jQuery('#calendario');

    calendar.find('td').removeClass("disponible");
    calendar.find('td').removeClass("reservada");

    getAvailabilities(carpark_path);
    getAllBookings (carpark_path);

    carparkPath = carpark_path;
}


function getAvailabilities(carpark_path) {
    var url = carpark_path + "/get_availabilities.json?date='" + fechaActual.toString("yyyy-MM-ddTHH:mm:ss.000Z") + "'";
    jQuery.getJSON(url, function getAvailabilitiesCallback(data) {
                            getElementsCallback(data, "disponible");
                        }
    );
}

// Obtener todas las reservas sobre la plaza
function getAllBookings(carpark_path) {
    var url = carpark_path + "/get_bookings.json?date='" + fechaActual.toString("yyyy-MM-ddTHH:mm:ss.000Z") + "'";
    jQuery.getJSON(url, function getAllBookingsCallback(data) {
                            getElementsCallback(data, "reservada");
                        }
    );
}


// limpiar todas las disponibilidades
function clearAvailabilities() {
    var postData = {};
    postData["_method"] = "delete";

    jQuery.ajax({
        url: carparkPath + "/clear.js",
        data: postData,
        type: 'POST',
        dataType: 'html',
        success: function () {
            refreshCalendar(carparkPath);
        }
    });
}

// limpiar todas las disponibilidades del mes actual
function clearMonthAvailabilities() {
    var postData = {};
    postData["_method"] = "delete";
    postData["date"] = fechaActual.toString("yyyy-MM-dd");

    jQuery.ajax({
        url: carparkPath + "/clear_month.js",
        data: postData,
        type: 'POST',
        dataType: 'html',
        success: function () {
            refreshCalendar(carparkPath);
        }
    });
}


// Confirmar disponibilidades
function saveAvailabilities(carparkId) {
    console.log("*********saveAvailabilities************");
    var anio = fechaActual.toString("yyyy");
    var mes = fechaActual.toString("MM");
    var postData = {};
    var carpark = {};
    var availabity_attributes = [];
    var rent_attributes = [];
    var rent = {};

    //alert (jQuery('#dias > table > tbody > tr > td.disponible').length);
    var aDias = [];
    var aHoras = [];
    jQuery('#days_table').find('> table > tbody > tr > td.disponible').each(function () {
        var index = jQuery(this).index();
        aDias.push(index);
    });

    jQuery('#horas').find('> table > tbody > tr > td.disponible').each(function () {
        var index = jQuery(this).index();
        aHoras.push(index);
    });

    aHoras.sort(numOrdA);
    console.log("Dias:" + aDias);
    console.log("Horas:" + aHoras);

    // identificar inicio y fin de tramos
    var indexInicio = aHoras[0];
    var indexFin = aHoras[0];
    var tramos = [];
    var section = {};

    if (aHoras.length == 1) {
        section = {};
        section["inicio"] = indexInicio;
        section["fin"] = indexFin;
        tramos.push(section);
    }
    for (var j = 1; j < aHoras.length; j++) {
        var hora = aHoras[j];
        // si es consecutiva seguimos acumulando, sino guardamos y reseteamos indices
        if (hora == indexFin + 1) {
            indexFin = hora;
            // sino llegamos al final seguimos
            if (!(j != aHoras.length - 1)) {
                section = {};
                section["inicio"] = indexInicio;
                section["fin"] = indexFin;
                tramos.push(section);
            }
        }
        else {
            section = {};
            section["inicio"] = indexInicio;
            section["fin"] = indexFin;
            tramos.push(section);

            if (j == aHoras.length - 1) // si llegamos al final
            {
                var finalSection = {};
                finalSection["inicio"] = hora;
                finalSection["fin"] = hora;
                tramos.push(finalSection);
            }
            else {
                indexInicio = hora;
                indexFin = hora;
            }
        }

    }
    console.log(tramos);

    // recorremos los tramos y creamos los objetos a enviar
    for (j = 0; j < tramos.length; j++) {
        indexInicio = tramos[j].inicio;
        indexFin = tramos[j]["fin"];

        console.log("Creando disponibilidades " + j);
        // Crear disponibilidad
        {
            for (var i = 0; i < aDias.length; i++) {
                var dia = aDias[i] + 1;
                var availabity = {};
                var horaInicio = Math.floor(indexInicio / 4);
                var minutoInicio = (indexInicio % 4) * 15;
                var horaFin = Math.floor((indexFin) / 4);
                var minutoFin = ((indexFin) % 4) * 15;
                console.log("Availability: " + dia + " - " + horaInicio + " - " + minutoInicio);
                console.log("Availability: " + dia + " - " + horaFin + " - " + minutoFin);

                availabity["start_time(3i)"] = dia;       // dia
                availabity["start_time(2i)"] = mes;       // mes
                availabity["start_time(1i)"] = anio;      // año
                availabity["start_time(4i)"] = horaInicio;  // hora
                availabity["start_time(5i)"] = minutoInicio;  // minutos

                availabity["end_time(3i)"] = dia;       // dia
                availabity["end_time(2i)"] = mes;       // mes
                availabity["end_time(1i)"] = anio;      // año
                availabity["end_time(4i)"] = horaFin;   // hora
                availabity["end_time(5i)"] = minutoFin;  // minutos
                availabity_attributes.push(availabity);
            }
        }
    }

    postData["_method"] = "put";
    rent['id'] = $("#rent").val();
    rent["availabilities_attributes"] = availabity_attributes;
    rent_attributes.push(rent);
    carpark['rents_attributes'] = rent_attributes;
    postData["carpark"] = carpark;
    postData["id"] = carparkId;
    //postData["commit"] = "Guardar cambios";
    //postData["locale"] = "es";

    //console.log(JSON.stringify(postData));

    if (aHoras.length > 0 && aDias.length > 0)
        jQuery.ajax({
            url: "/carparks/" + carparkId,
            data: postData,
            type: 'POST',
            dataType: 'html',
            success: function () {
                cleanSelection();
                refreshCalendar(carparkPath);
            },
            statusCode: {
                422: function (errors) {
                    $("#error_explanation").remove()
                    $('#selector').append(errors['responseText']);
                },

                200: function (data) {
                    eval(data);
                }
            }
        });
    return postData;
}
