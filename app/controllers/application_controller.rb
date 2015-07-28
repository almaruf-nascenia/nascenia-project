class ApplicationController < ActionController::Base
  require 'csv'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message

  end

  def check_super_admin
    redirect_to root_url, :alert => 'You are not authorized to access requested page' unless current_user && current_user.super_admin?
  end
end
