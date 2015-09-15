var fechaActual = Date.today();

function getMonthNavigator() {
    var navegador = $('#navegador');
    navegador.empty();
    navegador.append('<button class="pure-button" onClick="navigateToMonth (-1)"><i class="fa fa-arrow-left"></i> ' + getMonthString(-1) + '</button>');
    navegador.append('<span class="navegador-titulo">' + fechaActual.toString("yyyy/MM") + '</span>');
    navegador.append('<button class="pure-button" onClick="navigateToMonth (1)">' + getMonthString(1) + ' <i class="fa fa-arrow-right"></i></button>');
}

function getMonthString(addedMonths) {
    return fechaActual.clone().addMonths(addedMonths).toString("yyyy/MM");
}

function navigateToMonth(addedMonths)
{
    fechaActual.addMonths(addedMonths);
    getMonthNavigator();
    generarTablaDias();
    generarCalendario();
    refreshCalendar(carparkPath);
}


function onInit() {
    jQuery.ajaxSetup({
        'beforeSend': function (xhr) {
            xhr.setRequestHeader("Accept", "text/javascript")
        }
    });

    getMonthNavigator();
    generarTablaDias();
    generarCalendario();

    jQuery("#days_table").mousedown(mouseDown);
    jQuery("#horas").mousedown(mouseDown);
}

// Generar tabla de dias
function generarTablaDias() {
    var daysTable = jQuery('#days_table').find('table');
    var fecha = fechaActual.clone().moveToFirstDayOfMonth();
    var dias = fechaActual.clone().moveToLastDayOfMonth().toString("dd");

    // cabecera de la tabla
    daysTable.empty();
    daysTable.append('<tr>');
    for (var i = 0; i < dias; i++) {
        var dia = fecha.toString("ddd");
        var row = daysTable.find('tr');
        if (!(dia == "Sat" || dia == "Sun")) {
            row.append('<th>' + (i + 1) + '</th>');
        } else {
            row.append('<th class="weekend">' + (i + 1) + '</th>');
        }
        fecha.addDays(1);
    }
    daysTable.append('</tr>');

    // Fila de los días estableciendo estilo para el fin de semana
    fecha = fechaActual.clone().moveToFirstDayOfMonth();
    daysTable.append('<tr>');
    for (i = 0; i < dias; i++) {
        dia = fecha.toString("ddd");
        if (dia == "Sat" || dia == "Sun") {
            daysTable.find('tr:last-child').append('<td class="weekend">' + '</td>');
        }
        else
            daysTable.find('tr:last-child').append('<td></td>');
        fecha.addDays(1);
    }
    daysTable.append('</tr>');

}

// Generar calendario
function generarCalendario() {
    var calendarTable = jQuery('#calendario').find('table');
    var hora = new Date().clearTime();
    calendarTable.empty();
    calendarTable.append('<tr>');

    calendarTable.find('tr').append('<th class="day">' + 'Día' + '</th>');
    for (var i = 0; i < 24; i++) {
        calendarTable.find('tr').append('<th colspan="4">' + (hora.toString("HH:mm")) + '</th>');
        hora.addHours(1);
    }
    calendarTable.append('</tr>');

    var dias = fechaActual.clone().moveToLastDayOfMonth().toString("dd");
    for (i = 0; i < dias; i++) {
        calendarTable.append('<tr>');
        calendarTable.append('</tr>');

        calendarTable.find('tr:last-child').append('<td class="day">' + (i + 1) + '</td>');
        for (var j = 0; j < 96; j++) {
            if(j % 4 == 0)
                calendarTable.find('tr:last-child').append('<td class="initHourCell">' + '</td>');
            else
                calendarTable.find('tr:last-child').append('<td>' + '</td>');
        }
    }
}

function cleanSelection() {
    jQuery('#horas').find('td').removeClass("disponible");
    jQuery('#days_table').find('td').removeClass("disponible");
}

function seleccionarFinesSemana() {
    jQuery('#days_table').find('.weekend').addClass("disponible");
}

function seleccionarLaborables() {
    jQuery('#days_table').find(':not(.weekend)').addClass("disponible");
}

function seleccionarTodos() {
    jQuery('#days_table').find('td').addClass("disponible");
}

// procesa los datos de tramos obtenidos de una plaza
function getElementsCallback(data, elementClass) {
    for (var i = 0; i < data.times.length; i++) {
        var element = data.times[i];
        var start_time = (Date.parseExact(element.start_time, "yyyy-MM-ddTHH:mm:ss.000Z"));
        var end_time = (Date.parseExact(element.end_time, "yyyy-MM-ddTHH:mm:ss.000Z"));
        var day = start_time.toString("d");
        var indexInit = start_time.toString("H") * 4 + (start_time.toString("m") / 15) + 1;
        var indexEnd = end_time.toString("H") * 4 + (end_time.toString("m") / 15) + 1;
        console.log(day + "-" + indexInit + "-" + indexEnd);
        for (var j = indexInit; j <= indexEnd; j++) {
            var celda = jQuery('#calendario').find('tr:eq(' + day + ') td:eq(' + j + ')');
            celda.removeClass("disponible");
            celda.toggleClass(elementClass + " " + element.id);
        }
    }
}


// funcion de ordenacion
function numOrdA(a, b) {
    return (a - b);
}

// ---------------------------------------------------------------------------------------------------------------------
// Manejo de click y arrastre sobre las tablas de dias y horas
// ---------------------------------------------------------------------------------------------------------------------
function setCellState(celda, estado) {
    if (celda.nodeName != "TD")
        return;

    var index = jQuery(celda).index();
    console.log("SetEstado " + index + " " + jQuery(celda).hasClass("disponible") + " " + estado);
    if (jQuery(celda).hasClass("disponible") && estado != "disponible") {
        jQuery(celda).removeClass("disponible");
    }

    if (!jQuery(celda).hasClass("disponible") && estado == "disponible") {
        jQuery(celda).toggleClass("disponible");
    }
}


var getNewCellState = function (celda) {
    if (jQuery(celda).hasClass("disponible"))
        return "";
    else
        return "disponible";
};

var mouseDown = function (event) {
    console.log("mouseDown" + event.currentTarget.id);

    var celda = event.target;
    var calendario = event.currentTarget;
    var estado = getNewCellState(celda);

    var select = function (event) {
        console.log("Select: " + event.target.nodeName);
        if (event.target.nodeName == "TD")
            setCellState(event.target, estado);
    };

    var stop = function () {
        jQuery(calendario).unbind('mouseover', select)
            .unbind('mouseleave', stop)
            .unbind('mouseup', stop);
    };

    //trace('start', estado);
    setCellState(event.target, estado);

    jQuery(calendario).mouseup(stop)
        .mouseleave(stop)
        .mouseover(select);

    return false;
};