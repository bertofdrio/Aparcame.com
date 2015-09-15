#encoding: UTF-8
require 'rails_helper'

describe RentsController, type: :controller do

  describe 'guess access' do

    before(:each) do
      # sign_in nil
      @rent = create(:rent)
    end

    describe 'GET #index' do
      it 'requires login' do
        get :index, carpark_id: @rent.carpark
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'GET #show' do
      it 'requires login' do
        get :show, id: @rent, carpark_id: @rent.carpark
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'GET #new' do
      it 'requires login' do
        get :new, carpark_id: @rent.carpark
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'POST #create' do
      it 'requires login' do
        post :create, carpark_id: @rent.carpark, rent: attributes_for(:rent)
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'DELETE #destroy' do
      it "requires login" do
        delete :destroy, id: @rent, carpark_id: @rent.carpark
        expect(response).to redirect_to new_user_session_path
      end
    end

  end

  describe 'user access' do

    before(:all) do
      @user = create(:user)
    end

    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in(@user)
    end

    context 'user is not the owner' do
      before(:each) do
        @rent = create(:rent)
      end

      describe 'GET #index' do
        it 'show unauthorized text in notice' do
          get :index, carpark_id: @rent.carpark
          expect(flash[:notice]).to eq I18n.t('text.general.unauthorized')
        end
      end

      describe 'GET #show' do
        it 'show unauthorized text in notice' do
          get :show, id: @rent, carpark_id: @rent.carpark
          expect(flash[:notice]).to eq I18n.t('text.general.unauthorized')
        end
      end

      describe 'GET #new' do
        it 'show unauthorized text in notice' do
          get :new, carpark_id: @rent.carpark
          expect(flash[:notice]).to eq I18n.t('text.general.unauthorized')
        end
      end

      describe 'POST #create' do
        it 'show unauthorized text in notice' do
          post :create, carpark_id: @rent.carpark, rent: attributes_for(:rent)
          expect(flash[:notice]).to eq I18n.t('text.general.unauthorized')
        end
      end

      describe 'DELETE #destroy' do
        it 'show unauthorized text in notice' do
          delete :destroy, id: @rent, carpark_id: @rent.carpark
          expect(flash[:notice]).to eq I18n.t('text.general.unauthorized')
        end
      end
    end

    context 'user is the owner' do

      before(:all) do
        @carpark = create(:carpark, user: @user)
      end

      describe 'GET #index' do
        before :each do
          @rents = Array.new
          carpark = @carpark
          @rents.push(create(:rent, carpark: carpark))
          @rents.push(create(:rent, carpark: carpark))
          get :index, carpark_id: carpark
        end

        it 'populates an array of rents' do
          expect(assigns(:rents)).to match_array @rents.to_a
        end

        it 'render the :index template' do
          expect(response).to render_template :index
        end
      end

      describe 'GET #show' do
        before(:each) do
          carpark = @carpark
          @rent = create(:rent, carpark: carpark)
          get :show, id: @rent, carpark_id: @rent.carpark
        end

        it 'assigns the requested rent to @rent' do
          expect(assigns(:rent)).to eq @rent
        end

        it 'renders the :show template' do
          expect(response).to render_template :show
        end

        # context 'rent not exist' do
        #   before(:each) do
        #     carpark = create(:carpark, user: @user)
        #     @rent = create(:rent, carpark: carpark)
        #     get :show, id: 'notexist', carpark_id: @rent.carpark
        #   end
        #
        #   it 'response 404' do
        #     expect(response.status).to eq 404
        #   end
        #
        #   it 'renders error page' do
        #     expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
        #   end
        # end
      end

      describe 'GET #new' do

        it 'assigns a new Rent to @rent' do
          get :new, carpark_id: @carpark
          expect(assigns(:rent)).to be_a_new Rent
        end

        it 'renders the :new template' do
          get :new, carpark_id: @carpark
          expect(response).to render_template :new
        end
      end

      describe 'POST #create' do

        context 'with valid attributes' do
          it 'saves the new rent in the database' do
            expect { post :create, carpark_id: @carpark, rent: attributes_for(:rent) }.to change(Rent, :count).by(1)
          end
          it 'redirects to rents#show' do
            post :create, carpark_id: @carpark, rent: attributes_for(:rent)
            expect(response).to redirect_to carpark_rent_path(@carpark, assigns[:rent])
          end
        end

        context 'with invalid attributes' do
          before(:each) do
            @rent = create(:rent, carpark: @carpark)
          end

          it 'does not save the new rent in the database' do
            expect {
              post :create,
                   carpark_id: @carpark,
                   rent: attributes_for(:rent, name: @rent.name)
            }.not_to change(Rent, :count)
          end

          it 're-renders the :new template' do
            post :create, carpark_id: @carpark, rent: attributes_for(:rent, name: @rent.name)
            expect(response).to render_template :new
          end
        end
      end

      describe 'DELETE #destroy' do
        before :each do
          @rent = create(:rent_next_month, carpark: @carpark)
        end

        context 'with availabilities without bookings' do
          it 'deletes the rent' do
            expect { delete :destroy, id: @rent, carpark_id: @carpark }.to change(Rent, :count).by(-1)
          end

          it 'deletes the availabilities' do
            expect { delete :destroy, id: @rent, carpark_id: @carpark }.to change(Availability, :count).by(-@rent.availabilities.count)
          end

          it 'redirects to rents#index' do
            delete :destroy, id: @rent, carpark_id: @carpark
            expect(response).to redirect_to carpark_rents_path(@carpark)
          end

          it "show error message" do
            delete :destroy, id: @rent, carpark_id: @carpark
            expect(flash[:notice]).to eq I18n.t('text.general.successfully_destroyed', name: Rent.model_name.human)
          end
        end

        context 'with availabilities with bookings' do
          before(:each) do
            booking = create(:booking, carpark: @carpark)
            booking.booking_times << create(:booking_time, booking: booking,
                                            start_time: @rent.availabilities.first.start_time + 1.hour,
                                            end_time: @rent.availabilities.first.end_time - 1.hour)
          end

          it "doesn't delete the rent" do
            expect { delete :destroy, id: @rent, carpark_id: @carpark }.to_not change(Rent, :count)
          end

          it "deletes the availabilities without bookings" do
            expect { delete :destroy, id: @rent, carpark_id: @carpark }.to change(Availability, :count).by(-@rent.availabilities.count + 1)
          end

          it "redirects to rent#show" do
            delete :destroy, id: @rent, carpark_id: @carpark
            expect(response).to redirect_to carpark_rent_path(@carpark, @rent)
          end

          it "show error message" do
            delete :destroy, id: @rent, carpark_id: @carpark
            expect(flash[:notice]).to match_array [I18n.t('activerecord.errors.messages.restrict_dependent_destroy.many', record: Rent.human_attribute_name(:availabilities).downcase)]
          end
        end
      end
    end
  end

end