class LeavesController < ApplicationController

  def index        
    @leaves = current_organization.leaves.accessible_by(current_ability)
    current_user.leave_details.each do |l|
      if l.assign_date.year == Date.today.year
        @leave_details = l
    end
    end
    @leave_types = current_organization.leave_types.all
    respond_to do |format|
      format.html # index.html.haml
      format.json { render json: @leaves }
    end
  end

  def show
    @leave = Leave.find(params[:id])

    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @leave }
    end
  end

  def new
    @leave = Leave.new
    @profile = current_user.profile
  end

  def create
    available_leaves = nil
    if current_user.leave_details != nil
      current_user.leave_details.each do |l|
        if l.assign_date.year == Date.today.year
          available_leaves = l.available_leaves
        end
          end
    end
    begin
      @leave = Leave.new(params[:leave])
      @leave.access_params(params[:leave], available_leaves)
    rescue 
      @leave = Leave.new
    end
    @leave.user = current_user
    user = User.find(current_user)
    @leave.organization = current_organization
    @user = User.find(current_user)
    @leave.status = "Pending"
    respond_to do |format|
      if @leave.save
        if user.roles == 'HR'
          user_role = current_organization.users.where(:roles => 'Admin').collect(&:email)
          @users = UserMailer.leaveReport(@leave, user, user_role).deliver
        elsif user.roles == 'Manager'
          user_role = current_organization.users.in(:roles => ['HR', 'Admin']).collect(&:email)
          @users = UserMailer.leaveReport(@leave, user, user_role).deliver
        elsif user.roles == 'Employee' && user.manager.nil?
          user_role = current_organization.users.in(:roles => ['HR', 'Admin']).collect(&:email)
          @users = UserMailer.leaveReport(@leave, user, user_role).deliver
        else
          user_role = current_organization.users.in(:roles => ['Admin', 'HR']).collect(&:email).push(user.manager.email)
          @users = UserMailer.leaveReport(@leave, user, user_role).deliver
          format.json {render json: @leave, status: :created}
        end
	format.html {redirect_to leaves_path, notice: 'Your request has been noted' }
        format.json {render json: @leave, status: :created}
      else
        @profile = current_user.profile
        format.html {render action: "new"}
	format.json { render json: @leave.errors, status: :unprocessable_entity }
      end
  end

  end

  def edit
    @leave = Leave.find(params[:id])
  end

  def update
    @leave = Leave.find(params[:id])

    respond_to do |format|
      if @leave.update_attributes(params[:leave])
        format.html { redirect_to leaves_path, notice: 'Leave is successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @leave.errors, status: :unprocessable_entity }
      end
    end
  end

  def approve
    @leave = Leave.find(params[:id])
    authorize! :approve_leave, @leave
    if request.put?
p "In put request"
      @leave.status = "Approved"
p params
@leave.update_attributes(params[:leave])
      user = User.find(current_user)
  p "Leave saved"
      UserMailer.approveLeave(@leave, user).deliver    
p "sent mail"
            UserMailer.approveLeave(@leave, user).deliver    
      leave_details = @leave.user.leave_details
      leave_details.each do |l|
        if l.assign_date.year == Time.zone.now.year
          tmp_num = l.available_leaves[@leave.leave_type.id.to_s].to_i
          tmp_num = tmp_num - @leave.number_of_days
          l.available_leaves[@leave.leave_type.id.to_s] = tmp_num
          l.save
  p "calculations done"
      redirect_to leaves_path
        end
      end
    end
  end

  def rejectStatus
    @leave = Leave.find(params[:id])
    authorize! :reject_leave, @leave
    if request.put?
      user = User.find(current_user)
      @leave.status = "Rejected"
      @leave.update_attributes(params[:leave])
       UserMailer.rejectStatusLeave(@leave, user).deliver
      redirect_to leaves_path
    end
  end

  def destroy 
    @leave = Leave.find(params[:id])
    user = User.find(current_user)
    if current_user.roles == 'Admin'
      @leave.destroy
      UserMailer.cansleLeave(@leave, user).deliver
      redirect_to leaves_url, notice: 'Applied leave is deleted successfully.'
    else
      if @leave.status == 'Pending'
        @leave.destroy
        user_r = current_organization.users.where(:roles => 'Admin').collect(&:email)
        UserMailer.destroyLeave(user, user_r).deliver
	        redirect_to leaves_url, notice: 'Your applied leave is deleted successfully.'
      else
        redirect_to leaves_path, notice: 'You not cancel the leave.'
      end
    end  
  end

end
