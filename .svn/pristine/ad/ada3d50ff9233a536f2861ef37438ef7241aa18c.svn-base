require 'rails_helper'

feature 'Admin panel' do

  describe 'an admin user' do
    let!(:user) { create(:admin) }

    background do
      login_with_admin(user)
    end

    scenario 'should be able to access' do
      expect(current_path).to eq rails_admin.dashboard_path
      expect(page).to have_content('Dashboard')
    end
  end

  describe 'a regular user' do
    let!(:user) { create(:user) }

    background do
      login_with(user)
      visit rails_admin.dashboard_path
    end

    scenario 'should not be able to access' do
      expect(current_path).to eq new_admin_session_path
      expect(page).to have_content(I18n.t('devise.failure.unauthenticated'))
    end
  end

end