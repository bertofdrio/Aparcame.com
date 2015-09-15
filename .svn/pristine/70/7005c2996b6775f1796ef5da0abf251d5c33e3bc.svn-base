var carparkPath = "";
function refreshCalendar(carpark_path, current_user) {
    var calendar = jQuery('#calendario');

    calendar.find('td').removeClass("disponible");
    calendar.find('td').removeClass("reservada");
    calendar.find('td').removeClass("mireserva");

    getAvailabilities(carpark_path, current_user);

    carparkPath = carpark_path;
}

function getAvailabilities(carpark_path, current_user) {
    var url = carpark_path + "/get_availabilities.json?date='" + fechaActual.toString("yyyy-MM-ddTHH:mm:ss.000Z") + "'";
    jQuery.getJSON(url, function getAvailabilitiesCallback(data) {
            getElementsCallback(data, "disponible");
            getMyBookings(carpark_path, current_user);
        }
    );
}

// Obtener mis reservas sobre la plaza
function getMyBookings(carpark_path, current_user) {
    var url = carpark_path + "/get_bookings.json?date='" + fechaActual.toString("yyyy-MM-ddTHH:mm:ss.000Z") + "'";
    url += "&paid=0";
    url += "&user_id=" + current_user + "";
    jQuery.getJSON(url, function (data) {
            getElementsCallback(data, "mireserva");
            getMyPaidBookings(carpark_path, current_user);
        }
    );
}

// Obtener mis reservas pagadas sobre la plaza
function getMyPaidBookings(carpark_path, current_user) {
    var url = carpark_path + "/get_bookings.json?date='" + fechaActual.toString("yyyy-MM-ddTHH:mm:ss.000Z") + "'";
    url += "&paid=1";
    url += "&user_id=" + current_user + "";
    jQuery.getJSON(url, function (data) {
            getElementsCallback(data, "pagada");
            getOtherBookings(carpark_path, current_user);
        }
    );
}

// Obtener resto de reservas sobre la plaza
function getOtherBookings(carpark_path, current_user) {
    var url = carpark_path + "/get_bookings.json?date='" + fechaActual.toString("yyyy-MM-dd") + "'";
    url += "&not_user_id=" + current_user + "";
    jQuery.getJSON(url, function (data) {
            getElementsCallback(data, "reservada");
        }
    );
}

// Confirmar reservas
function saveBookings(carparkId, currentUser) {
    var anio = fechaActual.toString("yyyy");
    var mes = fechaActual.toString("MM");
    var postData = {};
    var carpark = {};
    var bookings_attributes = [];
    var booking_times_attributes = [];
    var booking = {};

    postData["_method"] = "put";

    // **************************************************************
    // 1 - obtener las horas y dias y ordenar
    // **************************************************************
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

    // **************************************************************
    // 2 - identificar inicio y fin de tramos
    // **************************************************************
    var indexInicio = aHoras[0];
    var indexFin = aHoras[0];
    var tramos = [];
    var tramo = {};

    if (aHoras.length == 1) {
        tramo = {};
        tramo["inicio"] = indexInicio;
        tramo["fin"] = indexFin;
        tramos.push(tramo);
    }
    for (j = 1; j < aHoras.length; j++) {
        var hora = aHoras[j];
        // si es consecutiva seguimos acumulando, sino guardamos y reseteamos indices
        if (hora == indexFin + 1) {
            indexFin = hora;
            // sino llegamos al final seguimos
            if (!(j != aHoras.length - 1)) {
                tramo = {};
                tramo["inicio"] = indexInicio;
                tramo["fin"] = indexFin;
                tramos.push(tramo);
            }
        }
        else {
            tramo = {};
            tramo["inicio"] = indexInicio;
            tramo["fin"] = indexFin;
            tramos.push(tramo);

            if (j == aHoras.length - 1) // si llegamos al final
            {
                tramo = {};
                tramo["inicio"] = hora;
                tramo["fin"] = hora;
                tramos.push(tramo);
            }
            else {
                indexInicio = hora;
                indexFin = hora;
            }
        }

    }
    console.log(tramos);

    // **************************************************************
    // 3 - recorrer los tramos y construir las reservas a enviar
    // **************************************************************
    for (var j = 0; j < tramos.length; j++) {
        indexInicio = tramos[j].inicio;
        indexFin = tramos[j]["fin"];

        console.log("Creando disponibilidades " + j);
        // Crear disponibilidad
        {
            for (var i = 0; i < aDias.length; i++) {
                var dia = aDias[i] + 1;
                var booking_time = {};
                var horaInicio = Math.floor(indexInicio / 4);
                var minutoInicio = (indexInicio % 4) * 15;
                var horaFin = Math.floor((indexFin) / 4);
                var minutoFin = ((indexFin) % 4) * 15;
                console.log("Booking: " + dia + " - " + horaInicio + " - " + minutoInicio);
                console.log("Booking: " + dia + " - " + horaFin + " - " + minutoFin);

                booking_time["start_time(3i)"] = dia;       // dia
                booking_time["start_time(2i)"] = mes;       // mes
                booking_time["start_time(1i)"] = anio;      // año
                booking_time["start_time(4i)"] = horaInicio;  // hora
                booking_time["start_time(5i)"] = minutoInicio;  // minutos

                booking_time["end_time(3i)"] = dia;       // dia
                booking_time["end_time(2i)"] = mes;       // mes
                booking_time["end_time(1i)"] = anio;      // año
                booking_time["end_time(4i)"] = horaFin;   // hora
                booking_time["end_time(5i)"] = minutoFin;  // minutos
                booking_times_attributes.push(booking_time);
            }
        }
    }

    booking['license'] = $("#license").val();
    booking['phone'] = $("#phone").val();
    booking['name'] = $("#booking_name").val();
    booking['user_id'] = currentUser;
    booking["booking_times_attributes"] = booking_times_attributes;
    bookings_attributes.push(booking);
    carpark["bookings_attributes"] = bookings_attributes;
    postData["carpark"] = carpark;
    postData["id"] = carparkId;
    //postData["commit"] = "Guardar cambios";
    //postData["locale"] = "es";

    jQuery.ajax({
        url: carparkPath + '/update_bookings.js',
        data: postData,
        type: 'POST',
        dataType: 'html',
        success: function () {
            cleanSelection();
            refreshCalendar(carparkPath, currentUser);
        },
        statusCode: {
            422: function (errors) {
                $("#error_explanation").remove()
                $('#booking_selector').prepend(errors['responseText']);
            },

            200: function (data) {
                eval(data);
            }
        }
    });
}
