class OnboardingController < ApplicationController
  include Wicked::Wizard

  steps :username, :residency, :top_up_suggest

  before_action :load_customer

  def show
    render_wizard
  end

  def update
    case step
    when :username
      @customer.update(username_params)
    when :residency
      if params[:residency_choice] == "residente"
        @customer.update(residency_params)
      end
    when :top_up_suggest
      # Nothing to persist here unless you want to do something
    end

    render_wizard @customer
  end

  private

  def load_customer
    @customer = Current.user.customer || Current.user.create_customer!
  end

  def username_params
    params.require(:customer).permit(:username)
  end

  def residency_params
    params.require(:customer).permit(:id_card_number)
  end

  def finish_wizard_path
    root_path
  end
end
