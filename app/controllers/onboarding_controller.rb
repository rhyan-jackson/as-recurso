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
      if !@customer.update(username_params)
        flash[:alert] = "Este nome de utilizador já está registado."
        redirect_to wizard_path
        return
      end
    when :residency
      if params[:residency_choice] == "residente"
        @customer.update(residency_params)
      end
    when :top_up_suggest
      if params[:skip_top_up]
        # Skip
      else
        amount = params[:amount].to_f
        method = params[:payment_method]
        mobile = params[:mobile_number].to_s.strip.gsub(/\s+/, '')

        if mobile.blank? || mobile !~ /\A\d{9}\z/
          flash[:alert] = "Número de telemóvel inválido."
          redirect_to wizard_path
          return
        end

        if amount > 0 && Payment.methods.keys.include?(method)
          Payment.create!(
            customer: @customer,
            amount: amount,
            method: method
          )

          @customer.increment!(:balance, amount)
        end
      end
    end

    redirect_to next_wizard_path
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
