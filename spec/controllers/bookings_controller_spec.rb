#encoding: UTF-8
require 'rails_helper'

describe BookingsController, type: :controller do

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

    describe 'GET #edit' do
      it 'requires login' do
        booking = create(:booking)
        get :edit, id: booking
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'PATCH #update' do
      it "requires login" do
        patch :update, id: create(:booking), contact: attributes_for(:booking)
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'DELETE #destroy' do
      it "requires login" do
        delete :destroy, id: create(:booking)
        expect(response).to redirect_to new_user_session_path
      end
    end

  end

  describe 'user access' do

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user)
      sign_in(@user)
    end

    describe 'GET #index' do
      before :each do
        @bookings = Array.new
        @bookings.push(create(:booking, user: @user))
        @bookings.push(create(:booking, user: @user))
      end

      it "populates an array of bookings" do
        get :index
        expect(assigns(:bookings)).to match_array @bookings.to_a
      end

      it 'render the :index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #edit' do

      context 'user is the owner' do
        before(:each) do
          @booking = create(:booking, user: @user)
        end

        it 'assigns the requested booking to @booking' do
          get :edit, id: @booking
          expect(assigns(:booking)).to eq @booking
        end

        it "renders the :show template" do
          get :edit, id: @booking
          expect(response).to render_template :edit
        end
      end

      context 'user is not the owner' do
        before(:each) do
          @booking = create(:booking)
        end

        it "show unauthorized text in notice" do
          get :edit, id: @booking
          expect(flash[:notice]).to eq I18n.t('text.general.unauthorized')
        end
      end

      context 'booking not exist' do
        it 'response 404' do
          get :edit, id: 'notexist'
          expect(response.status).to eq 404
        end

        it 'renders error page' do
          get :edit, id: 'notexist'
          expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
        end
      end
    end

    describe 'PATCH #update' do
      context 'user is not the owner' do
        before(:each) do
          @booking = create(:booking)
        end

        it "show unauthorized text in notice" do
          patch :update, id: @booking, booking: attributes_for(:booking)
          expect(flash[:notice]).to eq I18n.t('text.general.unauthorized')
        end
      end

      context 'user is the owner' do
        before(:each) do
          @booking = create(:booking, user: @user,
            name: 'Weekly',
            license: '9999-ZZZ',
            phone: '999999999')
        end

        context "with valid attributes" do
          it "locates the requested @booking" do
            patch :update, id: @booking, booking: attributes_for(:booking)
            expect(assigns(:booking)).to eq(@booking)
          end

          it "changes @booking's attributes" do
            patch :update, id: @booking,
                booking: attributes_for(:booking, name: 'Monthly', license: '1111-AAA', phone: '123456789')
            @booking.reload
            expect(@booking.name).to eq('Monthly')
            expect(@booking.license).to eq('1111-AAA')
            expect(@booking.phone).to eq('123456789')
          end

          it "redirects to the bookings" do
            patch :update, id: @booking, booking: attributes_for(:booking)
            expect(response).to redirect_to bookings_url
          end

          it "show success message" do
            patch :update, id: @booking, booking: attributes_for(:booking)
            expect(flash[:notice]).to eq I18n.t('text.general.successfully_updated', name: Booking.model_name.human)
          end

          it "send email to the user" do
            patch :update, id: @booking, booking: attributes_for(:booking)
            expect(last_email.to).to include @user.email
            expect(last_email.subject).to eq I18n.t('emails.update_booking')
          end

        end

        context "some booking_time is paid" do
          before(:each) do
            @booking.booking_times << create(:booking_time_with_availability, booking: @booking, paid: true)
          end

          it "redirects to the bookings" do
            patch :update, id: @booking, booking: attributes_for(:booking)
            expect(response).to redirect_to bookings_url
          end

          it "does not change the booking's attributes" do
            patch :update, id: @booking, booking: attributes_for(:booking, name: 'Monthly')
            @booking.reload
            expect(@booking.name).not_to eq('Monthly')
            expect(@booking.name).to eq('Weekly')
          end

          it "show error message" do
            patch :update, id: @booking, booking: attributes_for(:booking)
            expect(flash[:notice]).to eq I18n.t('text.booking.cannot_edit')
          end
        end

        context "with invalid attributes" do
          it "does not update the booking" do
            patch :update, id: @booking, booking: attributes_for(:booking, license: '1111-AAA', phone: nil)
            @booking.reload
            expect(@booking.license).not_to eq('Monthly')
            expect(@booking.phone).to eq('999999999')
          end
          it "re-renders the :edit template" do
            patch :update, id: @booking, booking: attributes_for(:invalid_booking)
            expect(response).to render_template :edit
          end
        end
      end
    end

    describe "PATCH show_booking_times" do
      before :each do
        @booking = create(:booking, user: @user)
        @booking.booking_times << create(:booking_time_with_availability, booking: @booking, paid: true)
        patch :show_booking_times, id: @booking, format: :js
      end

      subject { response }

      it {is_expected.to render_template :show_booking_times}

      it "populates an array of booking_times" do
        expect(assigns(:booking_times)).to eq(@booking.booking_times)
      end

      it 'assigns the requested booking to @booking' do
        expect(assigns(:booking)).to eq @booking
      end

      # it "redirects to contacts#index" do
      #   patch :hide_contact, id: @contact
      #   expect(response).to redirect_to contacts_url
      #   end
      # end
    end

    describe "PATCH hide_booking_times" do
      before :each do
        @booking = create(:booking, user: @user)
        @booking.booking_times << create(:booking_time_with_availability, booking: @booking, paid: true)
        patch :hide_booking_times, id: @booking, format: :js
      end

      subject { response }

      it {is_expected.to render_template :hide_booking_times}

      it "populates an empty array of booking_times" do
        expect(assigns(:booking_times)).to eq(nil)
      end

      it 'assigns the requested booking to @booking' do
        expect(assigns(:booking)).to eq @booking
      end
    end

    describe 'DELETE #destroy' do
      before :each do
        @booking = create(:booking, user: @user)
      end

      context 'with booking_times already paid' do
        before :each do
          @booking.booking_times << create(:booking_time_with_availability, booking: @booking, paid: true)
          @booking.booking_times << create(:booking_time_with_availability, booking: @booking, paid: false)
        end

        it "doesn't delete the booking" do
          expect { delete :destroy, id: @booking}.to_not change(Booking, :count)
        end

        it "deletes the booking_times not paid" do
          expect { delete :destroy, id: @booking}.to change(BookingTime, :count).by(-1)
        end

        it "redirects to bookings#index" do
          delete :destroy, id: @booking
          expect(response).to redirect_to bookings_url
        end

        it "show error message" do
          delete :destroy, id: @booking
          expect(flash[:notice]).to match_array [I18n.t('activerecord.errors.messages.restrict_dependent_destroy.many', record: Booking.human_attribute_name(:booking_times).downcase)]
        end

        it "send email to the user" do
          delete :destroy, id: @booking
          expect(last_email.to).to include @user.email
          expect(last_email.subject).to eq I18n.t('emails.update_booking')
        end
      end

      context 'with booking_times not paid' do
        before :each do
          @booking.booking_times << create(:booking_time_with_availability, booking: @booking, paid: false)
          @booking.booking_times << create(:booking_time_with_availability, booking: @booking, paid: false)
        end

        it "deletes the booking" do
          expect { delete :destroy, id: @booking }.to change(Booking, :count).by(-1)
        end

        it "deletes the booking_times" do
          expect { delete :destroy, id: @booking}.to change(BookingTime, :count).by(-2)
        end

        it "redirects to bookings#index" do
          delete :destroy, id: @booking
          expect(response).to redirect_to bookings_url
        end

        it "show success message" do
          delete :destroy, id: @booking
          expect(flash[:notice]).to eq I18n.t('text.general.successfully_destroyed', name: Booking.model_name.human)
        end

        it "send email to the user" do
          delete :destroy, id: @booking
          expect(last_email.to).to include @user.email
          expect(last_email.subject).to eq I18n.t('emails.delete_booking')
        end
      end
    end

  end



end