class WorkersController < ApplicationController

  def index
    @workers = Worker.includes(:detail)
  end

end