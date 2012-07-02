# -*- encoding : utf-8 -*-
class OffersController < ApplicationController
  def new
    if !user_signed_in?
      session[:item] = params[:item_id]
      session[:return] = params[:return]
      session[:pick_up] = params[:pick_up]
      flash[:notice] = "Please login to continue."
      redirect_to new_user_session_path
    else
      session[:item] = nil
      params[:return] = session[:return] unless session[:return].blank?
      params[:pick_up] = session[:pick_up] unless session[:pick_up].blank?
    end

    session[:start_date] = nil
    session[:end_date] = nil
    
    @item = Item.find params[:item_id]
    
    @booked_dates = []
    @manage_dates_array = []
    @offers = @item.offers.where("(status = 'Approved' or status LIKE '%Paid%' or status LIKE '%Confirmed%' or status LIKE '%Accepted%') and parent_id is NULL")
    @offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates
    
    @map = GMap.new("map")
    @map.control_init(:map_type => false, :small_zoom => true)
    coordinates = [@item.latitude,@item.longitude]
    @map.center_zoom_init(coordinates, 15)
    @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.popup_storz_display_name, :info_window => "#{@item.title}"))

    #    @offer = Offer.find_by_item_id_and_user_id_and_status(@item.id ,current_user.id,"Pending")

    if @offer.blank?
      @offer = @item.offers.build
      @offer.offer_messages.build
    end
    @number_of_days = (DateTime.strptime(params[:return], "%m/%d/%Y").to_datetime - DateTime.strptime(params[:pick_up], "%m/%d/%Y").to_datetime).to_i
    @number_of_days += 1
    @calculated_price = calculate_price(@number_of_days, @item)
  end

  def create
    @offer = Offer.find_by_item_id_and_user_id_and_status(params[:item_id],current_user.id,"Pending")
    @item = Item.find params[:item_id]
    
    @booked_dates = []
    @manage_dates_array = []
    #    offers = @item.offers(:conditions => ["status != 'applied' and parent_id is NULL"])    
    @offers = @item.offers.where("(status = 'Approved' or status LIKE '%Paid%' or status LIKE '%Confirmed%' or status LIKE '%Accepted%') and parent_id is NULL")
    @offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates
    
    unless @offer.blank?
      params[:offer][:rental_start_date] = DateTime.strptime(params[:offer][:rental_start_date], "%m/%d/%Y").to_time
      params[:offer][:rental_end_date] = DateTime.strptime(params[:offer][:rental_end_date], "%m/%d/%Y").to_time
      params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time if params[:offer][:cancellation_date] != "mm/dd/yy"

      @offer.update_attributes(params[:offer])
      redirect_to  new_item_offer_payment_path(@item,@offer)
    else
      params[:offer][:rental_start_date] = DateTime.strptime(params[:offer][:rental_start_date], "%m/%d/%Y").to_time
      params[:offer][:rental_end_date] = DateTime.strptime(params[:offer][:rental_end_date], "%m/%d/%Y").to_time
      params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time if params[:offer][:cancellation_date] != "mm/dd/yy"
      if params[:offer][:gathering_deadline] != "mm/dd/yy" and !params[:offer][:gathering_deadline].blank?
        params[:offer][:gathering_deadline] = DateTime.strptime(params[:offer][:gathering_deadline], "%m/%d/%Y").to_time
      end
            
      @offer = Offer.new(params[:offer].merge(:item_id => params[:item_id]).merge(:user_id => current_user.id).merge(:status => "pending"))

      if @offer.save!
        session[:return] = nil
        session[:pick_up] = nil
        
        @offer.update_attribute(:status, "Applied")

        #        @offer.update_attributes(:cancellation_date => (@offer.updated_at + 24.hours))
        redirect_to  new_item_offer_payment_path(@item,@offer)
      else
        render :new
      end
    end
  end

  def edit
    if !user_signed_in?
      session[:edit_item] = params[:item_id]
      session[:edit_offer] = params[:id]
      flash[:notice] = "Please login to continue."
      redirect_to new_user_session_path
    else
      session[:edit_item] = nil
      session[:edit_offer] = nil
    end
    @comment = Comment.new
    @item = Item.find params[:item_id]
    
    @booked_dates = []
    @manage_dates_array = []
    @offers = @item.offers.where("(status = 'Approved' or status LIKE '%Paid%' or status LIKE '%Confirmed%' or status LIKE '%Accepted%') and parent_id is NULL")   
    offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates
    
    @offer = Offer.find params[:id]
    @offer.offer_messages.build
    load_map

  end

  def load_map
    @map = GMap.new("map")
    @map.control_init(:map_type => false, :small_zoom => true)
    coordinates = [@item.latitude,@item.longitude]
    @map.center_zoom_init(coordinates, 15)
    @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.popup_storz_display_name, :info_window => "#{@item.title}"))
  end

  def update
    @item = Item.find params[:item_id]
    @offer = Offer.find params[:id]

    @booked_dates = []
    @manage_dates_array = []
    @offers = @item.offers.where("(status = 'Approved' or status LIKE '%Paid%' or status LIKE '%Confirmed%' or status LIKE '%Accepted%') and parent_id is NULL")
    offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates

    params[:offer][:rental_start_date] = DateTime.strptime(params[:offer][:rental_start_date], "%m/%d/%Y").to_time
    params[:offer][:rental_end_date] = DateTime.strptime(params[:offer][:rental_end_date], "%m/%d/%Y").to_time
    params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time

    @offer.attributes = params[:offer]


    if @offer.changed?
      if @offer.save
        current_user.send_message(@offer.user != current_user ? @offer.user : @item.user, :topic => "Offer Updated", :body => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been modified by #{@offer.user != current_user ? "Owner": "Renter"}. Please review to accept or decline.".html_safe)
        @notification = Notification.new(:user_id => @offer.user != current_user ? @offer.user.id : @item.user.id, :notification_type =>"offer_updated", :description => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been modified by #{@offer.user != current_user ? "Owner": "Renter"}. Please review to accept or decline.".html_safe)
        @notification.save
        flash[:notice] = "Offer updated and notification sent"
        redirect_to "/"
      else
        load_map
        flash[:notice] = "Offer was Not updated Successfully!"
        render :edit
      end
    else
      load_map
      flash[:notice] = "Please change any term to send your suggestion, thanks."
      render :edit
    end
  end

  def accept
    unless params[:item_id].blank?
      @item = Item.find params[:item_id]
    end
    @offer = Offer.find params[:id]
    payment = @offer.payment
    #    if payment.purchase("charge").status == 3
    #    payment.save!
    unless @item.blank?
      if current_user.id == @offer.user_id
        @item.update_attribute("item_status","Reserved")
        flash[:notice] = "Offer accepted"
        current_user.send_message(@item.user, :topic => "Offer Accepted", :body => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> made by #{@offer.user.popup_storz_display_name} on #{@item.title} has been accepted".html_safe)
        @notification = Notification.new(:user_id => @item.user.id, :notification_type =>"offer_accepted", :description => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> made by #{@offer.user.popup_storz_display_name} on #{@item.title} has been accepted".html_safe)
        @notification.save      
      else
        @item.update_attribute("item_status","Reserved")
        flash[:notice] = "Offer accepted."
        current_user.send_message(@offer.user, :topic => "Offer Accepted", :body => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been accepted by the owner.".html_safe)
        @notification = Notification.new(:user_id => @offer.user.id, :notification_type =>"offer_accepted", :description => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been accepted by the owner.".html_safe)
        @notification.save
        flash[:flash] = "Offer accepted."
        #      redirect_to "/"
      end
    end
    @offer.update_attribute("status", "Accepted")
    redirect_to "/"
    #    else
    #      flash[:flash] = "There is some problem in charging renter card, please contact Administrator, thanks."
    #      redirect_to "/"
    #    end
  end

  def decline
    @item = Item.find params[:item_id]
    @offer = Offer.find params[:id]
    if current_user.id == @offer.user_id
      @offer.update_attribute("status", "Declined")
      flash[:notice] = "Offer declined"
      current_user.send_message(@item.user, :topic => "Offer Declined", :body => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> made by #{@offer.user.popup_storz_display_name} on #{@item.title} has been declined".html_safe)
      @notification = Notification.new(:user_id => @item.user.id, :notification_type =>"offer_declined", :description => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> made by #{@offer.user.popup_storz_display_name} on #{@item.title} has been declined".html_safe)
      @notification.save
    else
      @offer.update_attribute("status", "Declined")
      flash[:notice] = "Offer declined"
      current_user.send_message(@offer.user, :topic => "Offer Declined", :body => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been declined by the owner".html_safe)
      @notification = Notification.new(:user_id => @offer.user.id, :notification_type =>"offer_declined", :description => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been declined by the owner".html_safe)
      @notification.save
    end
    redirect_to "/"
  end

  #  def payment_charge
  #    sdfdsf
  #    if payment.purchase("charge").status == 3
  #    else
  #      flash[:flash] = "There is some problem in charging renter card, please contact Administrator, thanks."
  #      redirect_to "/"
  #    end
  #  end
  
  def join_gathering
    @offer = Offer.find(params[:id])
  end
  
  def join
    @offer = Offer.find(params[:id])
    @item = @offer.item
    message = params[:user_message]
    new_offer = @offer.dup
    new_offer.user_id = current_user.id
    new_offer.parent_id = @offer.id
    new_offer.save
    @offer.members << current_user
    gathering_member = GatheringMember.find(:first,:conditions => ["offer_id = ? and user_id = ?",@offer.id,current_user.id])
    gathering_member.update_attributes({"user_message" => message, "status" => "Applied"})
    
    current_user.send_message(@offer.user, :topic => "Applied for Gathering", :body => "A new <a href='http://#{request.host_with_port}/#{dashboard_path(current_user.id)}'>user </a> have applied for your <a href='http://#{request.host_with_port}/items/#{@item.id}'> gathering</a>".html_safe)
    @notification = Notification.new(:user_id => @offer.user_id, :notification_type =>"gathering_joined", :description => "A new <a href='http://#{request.host_with_port}/#{dashboard_path(current_user.id)}'>user </a> have applied for your <a href='http://#{request.host_with_port}/items/#{@item.id}'> gathering</a>".html_safe)
    @notification.save
    
    flash[:notice] = "Successfully applied for the gathering."
    redirect_to  new_item_offer_payment_path(@item,@offer)
    #    redirect_to "/items/show/#{offer.item_id}"
  end
  
  def approve_gathering_request
    offer = Offer.find(params[:id])
    if offer.is_gathering
      
      gathering_member = GatheringMember.find(:first, :conditions => ["offer_id = ? and user_id = ?",params[:id],params[:mem]])
      gathering_member.update_attribute("status", "Approved")
      
      new_offer = Offer.new
      new_offer = offer.dup
      new_offer.parent_id = offer.id
      new_offer.user_id = params[:mem]
      new_offer.status = "Approved"
      
      if new_offer.save
        payment = PaymentsController.new
        payment.capture_gathering_commission(offer)
        
        reqs = GatheringMember.find(:all, :conditions => ["status = 'Approved' and offer_id = #{offer.id}"])
        if reqs.size == offer.persons_in_gathering.to_i
          #          offer.update_attribute("status","joinings approved")
          offer.update_attribute("status","all joinings approved")
        end
        user =User.find(gathering_member.user_id)
        current_user.send_message(user, :topic => "Joining Approved", :body => "Your joining request for <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> gathering</a> is approved.".html_safe)
        @notification = Notification.new(:user_id => gathering_member.user_id, :notification_type =>"joining_approved", :description => "Your joining request for <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> gathering</a> is approved.".html_safe)
        @notification.save
        
        flash[:notice] = "Offer accepted successfully!"
      else
        flash[:notice] = "Offer can't be accepted right now.Please try again or later."
      end
    else
      if offer.update_attribute("status", "Confirmed")
        flash[:notice] = "Offer accepted successfully!"
      else
        flash[:notice] = "Offer can't be accepted right now.Please try again or later."
      end
    end
    redirect_to "/items/created_coming_gatherings"
  end
  
  def decline_gathering_request
    offer = Offer.find(params[:id])
    if offer.is_gathering
      gathering_member = GatheringMember.find(:first, :conditions => ["offer_id = ? and user_id = ?",params[:id],params[:mem]])
      if gathering_member.destroy
        flash[:notice] = "Request declined."
        user = User.find(gathering_member.user_id)
        current_user.send_message(user, :topic => "Joining Declined", :body => "Your joining request for <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> gathering</a> is declined.".html_safe)
        @notification = Notification.new(:user_id => gathering_member.user_id, :notification_type =>"joining_declined", :description => "Your joining request for <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> gathering</a> is declined.".html_safe)
        @notification.save
      else
        flash[:notice] = "Request can't be declined now. Please try again or later."
      end      
    else
      if offer.update_attribute("status", "Rejected")
        flash[:notice] = "Offer rejected successfully!"
      else
        flash[:notice] = "Offer can't be rejected right now.Please try again or later."
      end
    end
    redirect_to gatherings_items_path
  end
  
  def send_gathering_deadline
    @gathering = Offer.find(params[:id])
  end
  
  def update_gathering_deadline
    offer = Offer.find(params[:offer][:id])
    params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time
    offer.update_attributes({"cancellation_date"=>params[:offer][:cancellation_date], "status" => "joinings approved"})
    flash[:notice] = "Response date updated successfully"
    redirect_to "/items/created_coming_gatherings"
  end
  
  protected

  def calculate_price(number_of_days, item)
    ppm = item.price_per_month.nil? ? 0 : item.price_per_month
    ppw = item.price_per_week.nil? ? 0 : item.price_per_week
    ppd = item.price.nil? ? 0 : item.price

    months = number_of_days/30
    weeks = (number_of_days-(30 * months))/7
    days = number_of_days - (30 * months) - (weeks * 7)
    months * ppm  + weeks * ppw + days * ppd
  end

  def payment_charge
    if payment.purchase("charge").status == 3
    else
      flash[:flash] = "There is some problem in charging renter card, please contact Administrator, thanks."
      redirect_to "/"
    end
  end

end
