# -*- encoding : utf-8 -*-
class AvatarsController < ApplicationController
  before_filter :load_item
  def new
    @avatar = @item.avatars.build
  end

  def create
    (1..15).each do |a|
      if params['photo_'+a.to_s]
        params[:avatar][:photo] = params['photo_'+a.to_s]
        @avatar = @item.avatars.build(params[:avatar])
        @avatar.caption = "" if params[:avatar][:caption] == t(:photo_caption)
        if @avatar.save
          flash[:notice] = t(:upload_picture)
          #      @item.update_attribute("item_status", params[:item_status])
        else
          flash[:notice] = t(:cant_save_picture)
        end
      end
    end
    return redirect_to items_path
  end

  def edit
    @avatars = @item.avatars
    @avatar = @avatars.first
  end
  
  def update
    (1..15).each do |a|
      if params['photo_'+a.to_s]
        params[:avatar][:photo] = params['photo_'+a.to_s]
        @avatar = @item.avatars.build(params[:avatar])
        @avatar.caption = "" if params[:avatar][:caption] == t(:photo_caption)
        if @avatar.save
          flash[:notice] = t(:upload_picture)
          #      @item.update_attribute("item_status", params[:item_status])
        else
          flash[:notice] = t(:cant_save_picture)
        end
      end
    end
    return redirect_to items_path
  end
  

  def destroy
    @avatar = Avatar.find_by_id(params[:id])
    if @avatar.destroy
      return redirect_to new_item_avatar_path(@item)
    else
      flash[:notice] = t(:problem_deletin_picture)
      return render :action =>"new"
    end
  end

  protected
  def load_item
    @item = Item.find_by_id(params[:item_id])
  end
end