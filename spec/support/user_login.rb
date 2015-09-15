module Macros
  module UserLogin
    def login_with(user, options = {})
      options.reverse_merge!(password: 'password')

      visit root_path
      click_link 'header_login'

      within 'form' do
        find('#user_email').set user.email
        find('#user_password').set options[:password]

        click_button 'Log in'
      end
    end

    def login_with_admin(user, options = {})
      visit rails_admin.dashboard_path

      within 'form' do
        find('#admin_email').set user.email
        find('#admin_password').set user.password

        click_button 'Log in'
      end
    end

    def logout
      visit root_path
      click_link('Sign out')
    end
  end
end