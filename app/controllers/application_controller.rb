class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def landing
  end

  def scrape
    render json: Scraper.new(:th).scrape
  end
end
