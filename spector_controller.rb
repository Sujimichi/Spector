class SpectorController < ApplicationController
  require 'spector'    

  def index   
    @spector = Spector.new
    @data = @spector.go
  end

end
