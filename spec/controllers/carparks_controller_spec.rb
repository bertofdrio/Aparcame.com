#encoding: UTF-8
require 'rails_helper'

describe CarparksController, type: :controller do

  describe 'guess access' do

    before(:each) do
      # sign_in nil
    end

    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'GET #show' do
      it 'requires login' do
        carpark = create(:carpark)
        get :show, id: carpark
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'GET #calendar' do
      it 'requires_login' do
        @carpark = create(:carpark)
        get :calendar, id: @carpark
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'GET #get_availabilities' do
      it 'requires_login' do
        @carpark = create(:carpark_few_availabilities)
        get :get_availabilities, id: @carpark, format: :json
        expect(response.status).to be 401
      end
    end

    describe 'PATCH #update' do
      it 'requires login' do
        @carpark = create(:carpark)
        patch :update, id: @carpark, format: :js
        expect(response.status).to be 401
      end
    end

    describe 'PATCH #update_bookings' do
      it 'requires login' do
        @carpark = create(:carpark)
        #xhr :patch, :update_bookings, id: @carpark, format: :js
        patch :update_bookings, id: @carpark, format: :js
        expect(response.status).to be 401
      end
    end
  end

  describe 'user access' do

    let(:user) { create(:user) }

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user)
      sign_in(@user)
      sign_in(user)
    end

    describe 'GET #index' do
      before :each do
        @carpark = create(:carpark, user: user)
      end

      it "populates an array of carparks" do
        get :index
        expect(assigns(:carparks)).to match_array [@carpark]
      end

      it 'render the :index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #show' do

      shared_examples_for 'details of carpark' do
        it 'assigns the requested carpark to @carpark' do
          get :show, id: @carpark
          expect(assigns(:carpark)).to eq @carpark
        end

        it "renders the :show template" do
          get :show, id: @carpark
          expect(response).to render_template :show
        end
      end

      context 'user is the owner' do
        before(:each) do
          @carpark = create(:carpark, user: user)
        end

        it_behaves_like 'details of carpark'

        it "shows the field profit" do
          get :show, id: @carpark
          # expect(response).to have_content(I18n.t('views.carpark.profit'))
        end
      end

      context 'user is not the owner' do
        before(:each) do
          @carpark = create(:carpark)
        end

        it_behaves_like 'details of carpark'

        it 'does not show the field profit' do
          get :show, id: @carpark
          expect(response).not_to have_content(I18n.t('views.carpark.profit'))
        end

      end

      context 'carpark not exist' do
        it 'response 404' do
          get :show, id: 'notexist'
          expect(response.status).to eq 404
        end

        it 'renders error page' do
          get :show, id: 'notexist'
          expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
        end
      end
    end

    describe 'GET #calendar' do

      shared_examples_for 'carpark not exist' do
        it 'response 404' do
          get :calendar, id: 'notexist'
          expect(response.status).to eq 404
        end

        it 'renders error page' do
          get :calendar, id: 'notexist'
          expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
        end
      end

      context 'user is the owner' do
        before(:each) do
          @carpark = create(:carpark, user: user)
        end

        it_behaves_like 'carpark not exist'

        it 'assigns the requested carpark to @carpark' do
          get :calendar, id: @carpark
          expect(assigns(:carpark)).to eq @carpark
        end

        it 'renders the calendar template' do
          get :calendar, id: @carpark
          expect(response).to render_template :calendar
        end
      end

      context 'user is not the owner' do
        before(:each) do
          @carpark = create(:carpark)
        end

        it_behaves_like 'carpark not exist'

        it 'assigns the requested carpark to @carpark' do
          get :calendar, id: @carpark
          expect(assigns(:carpark)).to eq @carpark
        end

        it 'renders the calendar_bookings template' do
          get :calendar, id: @carpark
          expect(response).to render_template :calendar_bookings
        end
      end
    end

    describe 'GET #get_availabilities' do

      shared_examples '#get_availabilities' do
        context 'without date' do
          before(:each) do
            get :get_availabilities, id: @carpark, format: :json
          end

          it 'renders get_availabilities template' do
            expect(response).to render_template(:get_availabilities)
          end

          it 'assigns the requested availabilities to @availabilities' do
            expect(assigns(:availabilities)).to match_array []
          end
        end

        context 'with date in the same month' do
          before(:each) do
            @date = (Date.today + 1.month).beginning_of_month
            get :get_availabilities, id: @carpark, date: @date, format: :json
          end

          it 'renders get_availabilities template' do
            expect(response).to render_template(:get_availabilities)
          end

          it 'assigns the requested availabilities to @availabilities' do
            expect(assigns(:availabilities)).to eq @carpark.rents.first.availabilities
          end

          it 'returns JSON-formatted availabilities' do
            expect(response.body).to have_content @carpark.rents.first.availabilities.to_json(:only => [:id, :start_time, :end_time])
          end
        end

        context 'with date in the month after' do
          before(:each) do
            @date = (Date.today + 2.month).beginning_of_month
            get :get_availabilities, id: @carpark, date: @date, format: :json
          end

          it 'renders get_availabilities template' do
            expect(response).to render_template(:get_availabilities)
          end

          it 'assigns an empty array to @availabilities' do
            expect(assigns(:availabilities)).to match_array []
          end
        end
      end

      context 'user is no the owner' do
        render_views

        before(:each) do
          @carpark = create(:carpark_few_availabilities)
        end

        it_behaves_like '#get_availabilities'
      end

      context 'user is the owner' do
        render_views

        before(:each) do
          @carpark = create(:carpark_few_availabilities, user: user)
        end

        it_behaves_like '#get_availabilities'
      end
    end

    describe 'PATCH #update' do

      before(:each) do
        @carpark = create(:carpark, user: user)
        @rent = create(:rent, carpark: @carpark)

        @availability = build(:availability)
      end

      context 'carpark not exist' do
        it 'response 404' do
          patch :update, id: 'notexist', format: :js
          expect(response.status).to eq 404
        end

        it 'renders error page' do
          patch :update, id: 'notexist', format: :js
          expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
        end
      end

      context "with valid attributes" do
        def update
          @carpark_attributes = {id: @carpark.id,
                                 rents_attributes: [id: @rent.id,
                                                    availabilities_attributes: [start_time: @availability.start_time,
                                                                                end_time: @availability.end_time]]}

          patch :update, id: @carpark, carpark: @carpark_attributes, format: :js
        end

        it "updates the carpark in the database" do
          expect { update }.to change(Availability, :count).by(1)
        end

        it 'response with status 200' do
          update
          expect(response.status).to eq 200
        end
      end

      context "with invalid attributes" do
        def update
          @carpark_attributes = {id: @carpark.id,
                                 rents_attributes: [id: @rent.id,
                                                    availabilities_attributes: [start_time: nil,
                                                                                end_time: @availability.end_time]]}

          patch :update, id: @carpark, carpark: @carpark_attributes, format: :js
        end

        it "does not update the carpark attributes" do
          expect { update }.to_not change(Availability, :count)
        end

        it "response with status 422" do
          update
          expect(response.status).to eq 422
        end

        it "renders #update template" do
          update
          expect(response).to render_template :update
        end
      end

    end

    describe 'PATCH #update_bookings' do

      context 'user is the owner' do
        before(:each) do
          @carpark = create(:carpark, user: user)
          xhr :patch, :update_bookings, id: @carpark, format: :js
        end

        # it 'response 404' do
        #   expect(response.status).to eq 404
        # end

        it 'response 302' do
          expect(response.status).to eq 302
        end

        # it 'renders error page' do
        #   expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
        # end
      end

      context 'user is not the owner' do
        before(:each) do
          @carpark = create(:carpark_few_availabilities)

          @availability = @carpark.rents.first.availabilities.first
        end

        context "with valid attributes" do
          def update
            @carpark_attributes = {id: @carpark.id,
                                   bookings_attributes: [user_id: user.id, name: 'General', license: '1111-AAA', phone: '123456789',
                                                         booking_times_attributes: [start_time: @availability.start_time + 1.hour,
                                                                                    end_time: @availability.end_time - 1.hour]]}

            patch :update_bookings, id: @carpark, carpark: @carpark_attributes, format: :js
          end

          it "saves the new booking" do
            expect { update }.to change(Booking, :count).by(1)
          end

          it "saves the new booking_time in the database" do
            expect { update }.to change(BookingTime, :count).by(1)
          end

          it 'response with status 200' do
            update
            expect(response.status).to eq 200
          end
        end

        context "with invalid attributes" do
          def update
            @carpark_attributes = {id: @carpark.id,
                                   bookings_attributes: [user_id: user.id, name: 'General', license: '1111-AAA', phone: '123456789',
                                                         booking_times_attributes: [start_time: nil,
                                                                                    end_time: @availability.end_time - 1.hour]]}

            patch :update_bookings, id: @carpark, carpark: @carpark_attributes, format: :js
          end

          it "does not save the booking" do
            expect { update }.to_not change(Booking, :count)
          end

          it "does not save the booking_time" do
            expect { update }.to_not change(BookingTime, :count)
          end

          it "response with status 422" do
            update
            expect(response.status).to eq 422
          end

          it "renders #update template" do
            update
            expect(response).to render_template :update
          end
        end
      end
    end

    describe 'GET #get_bookings' do

      shared_examples '#get_bookings' do
        context 'without date' do
          before(:each) do
            get :get_bookings, id: carpark, format: :json
          end

          it 'renders get_bookings template' do
            expect(response).to render_template(:get_bookings)
          end

          it 'populates an array with the booking_times of current month' do
            expect(assigns(:booking_times)).to match_array []
          end
        end

        context 'with date' do

          let(:date) { (Date.today + 1.month).beginning_of_month }

          context 'without any other params' do

            before { get :get_bookings, id: carpark, date: date, format: :json }

            it 'renders get_bookings template' do
              expect(response).to render_template(:get_bookings)
            end

            it 'populates an array with the booking_times of date´s month' do
              expect(assigns(:booking_times)).to match_array all_booking_times
            end

            it 'returns JSON-formatted booking_times' do
              expect(response.body).to have_content all_booking_times.to_json(:only => [:id, :start_time, :end_time])
            end
          end

          context 'with param user_id' do
            context 'without param paid' do
              before { get :get_bookings, id: carpark, date: date, user_id: user.id, format: :json }
              let(:all_my_booking_times) { [my_booking_times, my_paid_booking_times] }

              it 'renders get_bookings template' do
                expect(response).to render_template(:get_bookings)
              end

              it 'populates an array with the booking_times of the user' do
                expect(assigns(:booking_times)).to match_array all_my_booking_times
              end

              it 'returns JSON-formatted booking_times' do
                expect(response.body).to have_content all_my_booking_times.to_json(:only => [:id, :start_time, :end_time])
              end

            end

            context 'with param paid' do
              before { get :get_bookings, id: carpark, date: date, user_id: user.id, paid: true, format: :json }

              it 'renders get_bookings template' do
                expect(response).to render_template(:get_bookings)
              end

              it 'populates an array with the booking_times of the user' do
                expect(assigns(:booking_times)).to match_array my_paid_booking_times
              end

              it 'returns JSON-formatted booking_times' do
                expect(response.body).to have_content my_paid_booking_times.to_json(:only => [:id, :start_time, :end_time])
              end
            end
          end

          context 'with param not_user_id' do
            before { get :get_bookings, id: carpark, date: date, not_user_id: user.id, format: :json }

            it 'renders get_bookings template' do
              expect(response).to render_template(:get_bookings)
            end

            it 'populates an array with the booking_times of others users' do
              expect(assigns(:booking_times)).to match_array other_booking_times
            end

            it 'returns JSON-formatted booking_times' do
              expect(response.body).to have_content other_booking_times.to_json(:only => [:id, :start_time, :end_time])
            end
          end
        end
      end

      context 'user is no the owner' do
        render_views

        before(:each) do
          all_booking_times
        end

        let(:next_month) { (Date.today + 1.month).beginning_of_month }
        let(:carpark) { create(:carpark) }
        let(:my_booking) { create(:booking, carpark: carpark, user: user) }
        let(:my_booking_times) { create(:booking_time_with_availability, booking: my_booking, start_time: next_month + 7.hours, end_time: next_month + 9.hours) }
        let(:my_paid_booking_times) { create(:booking_time_with_availability, booking: my_booking, start_time: next_month + 1.day + 7.hours, end_time: next_month + 1.day + 9.hours, paid: true) }
        let(:other_booking) { create(:booking, carpark: carpark) }
        let(:other_booking_times) { create(:booking_time_with_availability, booking: other_booking, start_time: next_month + 2.day + 7.hours, end_time: next_month + 2.day + 9.hours) }
        let(:all_booking_times) {[my_booking_times, my_paid_booking_times, other_booking_times]}

        it_behaves_like '#get_bookings'
      end

      # context 'user is the owner' do
      #   render_views
      #
      #   before(:each) do
      #     @carpark = create(:carpark_few_availabilities, user: @user)
      #   end
      #
      #   it_behaves_like '#get_bookings'
      # end
    end

    describe 'GET #clear', focus: true do
      context 'carpark not exist' do

        let(:carpark) { create(:carpark) }

        before(:each) do
          get :clear, id: 'notexist', format: :js
        end

        it 'response 404' do
          expect(response.status).to eq 404
        end

        it 'renders error page' do
          expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
        end
      end

      context 'user is no the owner' do

        let(:carpark) { create(:carpark) }

        before(:each) do
          get :clear, id: carpark, format: :js
        end

        it 'response 302' do
          expect(response.status).to eq 302
        end
        #
        # it 'renders error page' do
        #   expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
        # end
      end

      context 'user is the owner' do
        let(:carpark) { create(:carpark_few_availabilities, user: user) }
        let(:booking) { create(:booking_time_with_availability, booking: create(:booking, carpark: carpark))}

        before { carpark; booking }

        it 'delete all availabilities without bookings' do
          expect { get :clear, id: carpark, format: :js }.to change(Availability, :count).by(-3)
        end
      end
    end

    describe 'GET #clear_month', focus: true do
      context 'carpark not exist' do

        let(:carpark) { create(:carpark) }

        before(:each) do
          get :clear_month, id: 'notexist', format: :js
        end

        it 'response 404' do
          expect(response.status).to eq 404
        end

        it 'renders error page' do
          expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
        end
      end

      context 'user is no the owner' do

        let(:carpark) { create(:carpark) }

        before(:each) do
          get :clear_month, id: carpark, format: :js
        end

        it 'response 302' do
          expect(response.status).to eq 302
        end
      end

      context 'user is the owner' do
        let(:carpark) { create(:carpark_few_availabilities, user: user) }
        let(:date) { DateTime.now.beginning_of_month }
        let(:today_availability) { create(:availability, rent: carpark.rents.first, start_time: date + 2.days + 2.hours, end_time: date + 2.days + 4.hours) }
        before { Timecop.freeze(date); carpark; today_availability }

        context 'without param date' do
          it 'delete availabilities of the current month without bookings' do
            expect { get :clear_month, id: carpark, format: :js }.to change(Availability, :count).by(-1)
          end
        end

        context 'with param date' do
          it 'delete availabilities of the specified month without bookings' do
            expect { get :clear_month, id: carpark, date: (Date.today + 1.month).beginning_of_month, format: :js }.to change(Availability, :count).by(-3)
          end
        end
      end
    end
  end
end