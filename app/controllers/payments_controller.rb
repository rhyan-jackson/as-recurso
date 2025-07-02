class PaymentsController < ApplicationController
  before_action :set_customer

  def index
    @payments = @customer.payments.order(created_at: :desc)
  end

  def new
    @payment = @customer.payments.new
  end

  def create
    @payment = @customer.payments.new(payment_params)
    @customer.increment!(:balance, @payment.amount)

    if @payment.save
      redirect_to root_path, notice: "Pagamento registado com sucesso."
    else
      render :new
    end
  end

  private

  def set_customer
    @customer = Current.user.customer
  end

  def payment_params
    params.require(:payment).permit(:amount, :method)
  end
end
