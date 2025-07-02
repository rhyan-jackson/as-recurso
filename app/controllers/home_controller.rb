class HomeController < ApplicationController
  def index
    @customer = Current.user.customer
  end
end
