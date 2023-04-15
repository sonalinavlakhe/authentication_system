class ApplicationController < ActionController::Base
  add_flash_types :danger, :warning, :info, :success
  protect_from_forgery
end
