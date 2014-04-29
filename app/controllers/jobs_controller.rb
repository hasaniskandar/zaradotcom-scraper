class JobsController < ApplicationController
  before_action :set_job, :check_download!, only: %i[download download_other]

  def download
    send_data @job.result, filename: "zaradotcom-th-#{@job.id}.json", type: :json
  end

  def download_other
    send_data @job.other, filename: "zaradotcom-th-#{@job.id}-without-price.json", type: :json
  end

  def index
    @jobs = Job.select(:id, :status, :created_at, :updated_at).order(id: :desc)
  end

  def new
    job = Job.create!
    Resque.enqueue ScrapeJob, job.id, :th

    redirect_to root_url
  end

private

  def check_download!
    raise ActionController::RoutingError, "Not Found" unless @job.done?
  end

  def set_job
    @job = Job.find(params[:id])
  end
end
