class JobsController < ApplicationController
  before_action :set_job, only: :show

  def index
    @jobs = Job.select(:id, :status, :created_at, :updated_at).order(id: :desc)
  end

  def show
    raise ActionController::RoutingError, "Not Found" unless @job.done?

    send_data @job.result, filename: "zaradotcom-th.json", type: :json
  end

  def new
    job = Job.create!
    Resque.enqueue ScrapeJob, job.id, :th

    redirect_to root_url
  end

private

  def set_job
    @job = Job.find(params[:id])
  end
end
