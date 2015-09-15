require 'rails_helper'

feature 'Devise' do

  describe 'create new user' do
    let!(:user) { create(:user) }

    scenario 'with invalid email not be able to register' do
      visit root_path
      click_link 'header_sign_up'

      within 'form' do
        find('#user_email').set 'invalidemail'
        find('#user_password').set 'password'
        find('#user_password_confirmation').set 'password'

        click_button 'Sign up'
      end

      expect(current_path).to eq user_registration_path
    end

    scenario 'with not unique email not be able to register' do
      visit root_path
      click_link 'header_sign_up'

      within 'form' do
        find('#user_email').set user.email
        find('#user_password').set 'password'
        find('#user_password_confirmation').set 'password'

        click_button 'Sign up'
      end

      expect(current_path).to eq user_registration_path
    end

  end

  describe 'confirm user' do
    let!(:user) { create(:not_confirmed_user) }

    scenario 'with not unique email not be able to register' do
      raw_confirmation_token, db_confirmation_token = Devise.token_generator.generate(User, :confirmation_token)
      user.update_attribute(:confirmation_token, db_confirmation_token)
      visit user_confirmation_url(confirmation_token: raw_confirmation_token)
    end

  end
end