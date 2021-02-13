class HomesController < ApplicationController

  def index
    @homes = Home.by_discount.all.delete_if{|h| h.archived}
  end

  def archive
    if @home = Home.by_property_id.key(params['property_id'].to_i).first
      @home.update_attributes(archived: !@home.archived)
    end
    redirect_to :back
  end

  def like
    if @home = Home.by_property_id.key(params['property_id'].to_i).first
      @home.update_attributes(liked: !@home.liked)
    end
    redirect_to :back
  end
end
