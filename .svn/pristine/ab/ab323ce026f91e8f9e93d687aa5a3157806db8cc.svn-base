#encoding: UTF-8
require 'rails_helper'
require 'support/geocoding'

describe GaragesController, type: :controller do

  shared_examples_for 'public access to garages' do

    before :each do
      @garage = create(:garage)
      FakeWeb.allow_net_connect = false
    end

    describe 'GET #index' do
      context 'without params' do
        it "populates an array of garages" do
          get :index
          expect(assigns(:garages)).to match_array [@garage]
        end

        it 'render the :index template' do
          get :index
          expect(response).to render_template :index
        end
      end

      context 'with address without alternates' do
        before do
          register_without_alternates
        end

          it "populates an empty array of alternate addresses" do
            get :index, search_address: 'Calle Uria, Oviedo'
            expect(assigns(:alternate_addresses)).to match_array []
          end

          it "populates an array of garages" do
            get :index, search_address: 'Calle Uria, Oviedo'
            expect(assigns(:garages)).to match_array [@garage]
          end

          it 'render the :index template' do
            get :index, search_address: 'Calle Uria, Oviedo'
            expect(response).to render_template :index
          end
      end

      context 'with address with alternates' do
          before do
            register_with_alternates
          end

          it "populates an array of alternate addresses" do
            get :index, search_address: 'Calle Uria'
            expect(assigns(:alternate_addresses)).to match_array ["Calle Uría, Gijón", "Calle Uría, Madrid"]
          end

          it "populates an array of garages" do
            get :index, search_address: 'Calle Uria'
            expect(assigns(:garages)).to match_array [@garage]
          end

          it 'render the :index template' do
            get :index, search_address: 'Calle Uria'
            expect(response).to render_template :index
          end
      end
    end
  end

  describe 'guess access' do

    before(:each) do
      # sign_in nil
    end

    it_behaves_like "public access to garages"

    describe 'GET #show' do
      it 'requires login' do
        garage = create(:garage)
        get :show, id: garage
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

    it_behaves_like "public access to garages"

    describe 'GET #show' do
      before(:each) do
        @garage = create(:garage)
        @other_carpark = create(:carpark, garage: @garage)
      end

      it 'assigns the requested garage to @garage' do
        get :show, id: @garage
        expect(assigns(:garage)).to eq @garage
      end

      it 'assigns the carparks of the requested garage to @other_carparks' do
        get :show, id: @garage
        expect(assigns(:other_carparks)).to match_array [@other_carpark]
      end

      it "renders the :show template" do
        get :show, id: @garage
        expect(response).to render_template :show
      end

      context 'user has a carpark in garage' do
        it 'assigns the carparks which the user is owner of to @your_carparks' do
          @your_carpark = create(:carpark, garage: @garage, user: @user)
          get :show, id: @garage
          expect(assigns(:your_carparks)).to match_array [@your_carpark]
        end
      end

      context 'garage not exist' do
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
  end
end