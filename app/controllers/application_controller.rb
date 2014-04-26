class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def landing
  end

  def scrape
    if params[:id]
      job = Job.find params[:id]

      render json: job
    else
      job = Job.create!
      Resque.enqueue ScrapeJob, job.id, params[:country_id]

      redirect_to scrape_url(params[:country_id], job)
    end
  end
end
