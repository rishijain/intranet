class LeaveDetailsController < ApplicationController
  before_action :authenticate_user!

  def update_available_leave
    leave_details = LeaveDetail.find(params[:id])
    leave_details.available_leave[leave_type] = params[:value]
    leave_details.save 
    render nothing: true
  end 

  private
    def leave_type
      if ["Sick", "Casual", "TotalPaid", "CurrentPaid"].include?(params[:type])
        return params[:type]
      else
        raise
      end
    end
end
