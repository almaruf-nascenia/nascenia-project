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

  #THIS ACTION RESETS ALL THE PAGINATION SESSION VALUES
  #THE RESULT PER PAGE VALUES ARE SET TO 10 FOR DEFAULT 10 RESULTS PER PAGE
  #THE PAGE NUMBER MUST BE SET TO 1, BECAUSE THE CHANGE IN RESULT PER PAGE OPTION REQUIRES SHOWING THE FIRST PAGE ON LOAD
  def reset_session_values
    session[:project_index] = 10
    session[:project_index_page_number] = 1
    session[:project_index_for_all] = 10
    session[:project_index_page_number_for_all] = 1
    session[:project_assign] = 10
    session[:project_assign_page_number] = 1
    session[:developer_index] = 10
    session[:developer_index_page_number] = 1
    session[:developer_index_for_all] = 10
    session[:developer_index_page_number_for_all] = 1
    session[:developer_engagement] = 10
    session[:developer_engagement_page_number] = 1
  end

  #THIS ACTION RESETS THE PAGINATION SESSION VALUES OF DEVELOPER PAGES
  def reset_developer_session_values
    session[:developer_index] = 10
    session[:developer_index_page_number] = 1
    session[:developer_index_for_all] = 10
    session[:developer_index_page_number_for_all] = 1
    session[:developer_engagement] = 10
    session[:developer_engagement_page_number] = 1
  end

  #THIS ACTION RESETS THE PAGINATION SESSION VALUES OF PROJECTS INDEX PAGE
  def reset_projects_session_values
    session[:project_index] = 10
    session[:project_index_page_number] = 1
    session[:project_index_for_all] = 10
    session[:project_index_page_number_for_all] = 1

  end

  #THIS ACTION RESETS THE PAGINATION SESSION VALUES OF PROJECTS ASSIGNMENT PAGE
  def reset_project_assign_session_values
    session[:project_assign] = 10
    session[:project_assign_page_number] = 1
  end


end
