class ApplicationController < ActionController::Base
  require 'csv'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :admin?

  private

  def admin?
    admin_emails = YAML::load_file('config/superadmin.yml')
    admin_emails['superadmin'].include?(current_user.email)
  end
end
