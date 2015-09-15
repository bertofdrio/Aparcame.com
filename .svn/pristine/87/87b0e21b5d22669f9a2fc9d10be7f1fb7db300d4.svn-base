#encoding: utf-8
require 'rails_helper'

describe BookingProcessor do

  let(:owner) do
    create(:owner)
  end

  let(:client) do
    create(:client)
  end
  
  before(:each) do
    client.bookings << build(:booking_next_month, user: client, carpark: owner.carparks.first)
  end

  context 'more than a week before first booking_time' do
    before(:each) do
      @date = client.bookings.first.booking_times.first.start_time - 1.weeks - 1.day
    end

    #subject { BookingProcessor.process_not_paid_bookings(@date) }

    it 'should not change client´s balance' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.not_to change { client.reload.balance }
    end

    it 'should not change owner´s balance' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.not_to change { owner.reload.balance }
    end

    it 'should not send any email to client' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.not_to change { ActionMailer::Base.deliveries.count }
    end

    it 'should not create charges' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.not_to change { Charge.count }
    end

    it 'should not create gate_tasks' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.not_to change { GateTask.count }
    end
  end

  context 'less than a week before first booking_time' do
    before(:each) do
      @date = client.bookings.first.booking_times.first.start_time - 1.weeks + 3.day
    end

    it 'decrease client´s balance' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.to change { client.reload.balance }.by(-BigDecimal(2.45, 3))
    end

    it 'increase owner´s balance' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.to change { owner.reload.balance }.by(BigDecimal(1.75, 3))
    end

    it 'send email to client' do
      BookingProcessor.process_not_paid_bookings(@date)
      expect(first_email.to).to include client.email
      expect(first_email.subject).to eq I18n.t('emails.booking_charge')

      # expect(mail.from).to eq ["from@example.com"]
      # expect(mail.body.encoded).to match edit_friendship_url(user, friend)
    end

    it 'send email to owner' do
      BookingProcessor.process_not_paid_bookings(@date)
      expect(last_email.to).to include owner.email
      expect(last_email.subject).to eq I18n.t('emails.booking_profit')
      # expect(mail.from).to eq ["from@example.com"]
      # expect(mail.body.encoded).to match edit_friendship_url(user, friend)
    end

    it 'set booking_times processed as paid' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.to change { client.bookings.first.booking_times.first.reload.paid }.to(true)
    end

    it 'not set booking_times not processed as paid' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.to_not change { client.bookings.first.booking_times.last.reload.paid }
    end

    it 'creates a charge' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.to change { Charge.count }.by(1)
    end

    it 'creates two gate_tasks' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.to change { GateTask.count }.by(2)
    end

  end

  context 'just one week before second booking_time' do

    before(:each) do
      @date = client.bookings.first.booking_times.second.start_time
    end

    it 'decrease client´s balance in double booking_time´s total_amount' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.to change { client.reload.balance }.by(-BigDecimal(4.9, 2))
    end

    it 'increase owner´s balance in double booking_time´s total_profit' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.to change { owner.reload.balance }.by(BigDecimal(3.5, 2))
    end

    it 'creates two charges' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.to change { Charge.count }.by(2)
    end

    it 'creates four gate_tasks' do
      expect { BookingProcessor.process_not_paid_bookings(@date) }.to change { GateTask.count }.by(4)
    end

  end

  describe 'process gate_tasks' do
    let(:date) { client.bookings.first.booking_times.first.start_time - 1.weeks + 3.day }

    before(:each) do
      BookingProcessor.process_not_paid_bookings(date)
      @first_booking_time = client.bookings.first.booking_times.first
      @gate_task_date = @first_booking_time.start_time - BookingTime::MINIMUN_MINUTES_SEGMENT.minutes
    end

    context '16 minutes before start_time of first booking_time' do
      it 'should not set the IN gate_task a sent' do
        expect { BookingProcessor.process_gate_tasks(@gate_task_date - 1.minutes) }.not_to change { GateTask.first.sent_at }
      end

      it 'should not send email to client' do
        expect { BookingProcessor.process_gate_tasks(@gate_task_date - 1.minutes) }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context '15 minutes before start_time of first booking_time' do
      before { FakeWeb.register_uri(:post, %r|https://ACf9c1983754ee00b4aaf834f74024b7e8:ec743800b7cdecc0965fa9e8304487d2@api.twilio.com/2010-04-01/Accounts/ACf9c1983754ee00b4aaf834f74024b7e8/Messages.json|,
                                    :body => '{
                                        "sid": "SM1f0e8ae6ade43cb3c0ce4525424e404f",
                                        "date_created": "Fri, 13 Aug 2010 01:16:24 +0000",
                                        "date_updated": "Fri, 13 Aug 2010 01:16:24 +0000",
                                        "date_sent": null,
                                        "account_sid": "AC228b97a5fe4138be081eaff3c44180f3",
                                        "to": "+15305431221",
                                        "from": "+15104564545",
                                        "body": "A Test Message",
                                        "status": "queued",
                                        "flags":["outbound"],
                                        "api_version": "2010-04-01",
                                        "price": null,
                                        "uri": "\/2010-04-01\/Accounts\/AC228ba7a5fe4238be081ea6f3c44186f3\/SMS\/Messages\/SM1f0e8ae6ade43cb3c0ce4525424e404f.json"
                                    }') }

      it 'set the IN gate_task a sent' do
        expect { BookingProcessor.process_gate_tasks(@gate_task_date) }.to change { GateTask.first.sent_at }
      end

      it 'send email to client' do
        BookingProcessor.process_gate_tasks(@gate_task_date)
        expect(last_email.to).to include client.email
        expect(last_email.subject).to eq I18n.t('emails.booking_info')
      end

      context 'and then 14 minutes after end_time of first booking_time' do
        before(:each) do
          BookingProcessor.process_gate_tasks(@gate_task_date)
          @gate_task_date_out = @first_booking_time.fixed_end_time + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes - 1.minutes
        end

        it 'should not set the IN gate_task a sent' do
          expect { BookingProcessor.process_gate_tasks(@gate_task_date_out) }.not_to change { GateTask.first.sent_at }
        end

        it 'should not send email to client' do
          expect { BookingProcessor.process_gate_tasks(@gate_task_date_out) }.not_to change { ActionMailer::Base.deliveries.count }
        end
      end

      context 'and then 15 minutes after end_time of first booking_time' do
        before(:each) do
          BookingProcessor.process_gate_tasks(@gate_task_date)
          @gate_task_date_out = @first_booking_time.fixed_end_time + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes
        end

        it 'set the OUT gate_task a sent' do
          expect { BookingProcessor.process_gate_tasks(@gate_task_date_out) }.to change { GateTask.second.sent_at }
        end

        it 'send email to client' do
          BookingProcessor.process_gate_tasks(@gate_task_date_out)
          expect(last_email.to).to include client.email
          expect(last_email.subject).to eq I18n.t('emails.booking_ended')
        end
      end
    end
  end

end