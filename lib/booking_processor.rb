class BookingProcessor
  def self.process_not_paid_bookings (date = nil)
    BookingTime.transaction do
      date = DateTime.now unless date != nil

      BookingTime.where('paid = :paid AND start_time <= :paid_date',
                        paid: false, paid_date: date + 1.week).lock(true).each do |booking_time|

        user = booking_time.booking.user
        balance = booking_time.booking.user.balance

        # puts t("Tarifa: %{amount}", amount: booking_time.total_amount)
        # puts t("Saldo: %{balance}", balance: balance)
        # puts t("Nuevo saldo: %{new_balance}", new_balance: balance - booking_time.total_amount)


        if balance - booking_time.total_amount < 0
          # no hay suficiente saldo y eliminamos la reserva
          booking_time.delete

          # Evento de cancelacion
          # $query_event = "insert into events (id_user, msg, type, parameters) values (?, ?, ?, ?);";
          # $parametros = array ($reserva->id_carpark, date('m', strtotime($reserva->start_time)), date('m', strtotime($reserva->start_time)), $reserva->start_time);
          # $this->db->query($query_event, array ($reserva->id_user, "", 2, serialize($parametros)));

        else
          # actualizar saldo del usuario y del propietario
          user.update_balance(-booking_time.total_amount)
          booking_time.booking.carpark.user.update_balance(booking_time.total_profit)

          booking_time.paid = true
          booking_time.save
          # crear las tareas de apertura de puertas
          GateTask.create(booking_time: booking_time,
                          user_phone: booking_time.booking.phone,
                          garage_phone: booking_time.booking.carpark.garage.phone,
                          time: booking_time.start_time - BookingTime::MINIMUN_MINUTES_SEGMENT.minutes,
                          action: :in)

          GateTask.create(booking_time: booking_time,
                          user_phone: booking_time.booking.phone,
                          garage_phone: booking_time.booking.carpark.garage.phone,
                          time: booking_time.fixed_end_time + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes,
                          action: :out)

          # crear cobro
          Charge.create(booking_time: booking_time, paid_at: date)

          # email para los usuarios
          UserMailer.booking_time_client_email(booking_time).deliver_later
          UserMailer.booking_time_owner_email(booking_time).deliver_later

        end
      end
    end
  end

  def self.process_gate_tasks(date = nil)
    GateTask.transaction do
      date = DateTime.now unless date != nil

      GateTask.where('sent_at is null AND time <= :date',
                     date: date).lock(true).each do |gate_task|

        # enviar sms y marcarlo como enviado
        if gate_task.in?
        #   #$mensajes[] = sprintf ("ADDNUM +34%s", $tarea->user_phone);
       else
        #   #$mensajes[] = sprintf ("DELNUM +34%s", $tarea->user_phone);
        #
        end

        gate_task.sent_at = date
        gate_task.save

        # enviar emails al cliente
        if gate_task.in?
          UserMailer.gate_task_in_email(gate_task.booking_time).deliver_later
        else
          UserMailer.gate_task_out_email(gate_task.booking_time).deliver_later
        end
      end
    end
  end
end