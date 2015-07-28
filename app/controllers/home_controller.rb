class HomeController < ApplicationController
  skip_before_filter :check_super_admin
  def index

  end

end
