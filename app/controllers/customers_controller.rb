class CustomersController < ApplicationController
  before_action :set_customer, only: [ :edit, :update, :destroy ]

  def new
    @customer = Current.user.build_customer
  end

  def create
    @customer = Current.user.build_customer(customer_params)
    if @customer.save
      redirect_to root_path, notice: "Customer profile created successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to root_path, notice: "Customer profile updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @customer.destroy
    redirect_to root_path, notice: "Customer profile deleted."
  end

  private

  def set_customer
    @customer = current_user.customer
    redirect_to root_path, alert: "Not authorized" unless @customer
  end

  def customer_params
    params.require(:customer).permit(:username, :balance, :id_card_number, :status)
  end
end
