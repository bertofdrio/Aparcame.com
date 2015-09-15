class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_locale

  def action_missing(m, *args, &block)
    Rails.logger.error(m)
    redirect_to '/*path'
  end

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html", :status => 404 }
      format.js { render :file => "#{Rails.root}/public/404.html", :status => 404 }
    end
  end

  private

  def extract_locale_from_accept_language_header
    # request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    begin
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    rescue
      'en'
    end
  end

  def set_locale
    if self.kind_of? RailsAdmin::ApplicationController
      I18n.locale = :en
    else
      I18n.locale = session[:locale] unless session[:locale].nil?
      I18n.locale = (extract_locale_from_accept_language_header || I18n.default_locale) if session[:locale].nil?
      session[:locale] = I18n.locale
    end
  end
end
