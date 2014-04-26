class ScrapeJob
  @queue = :scrape

  def self.perform(job_id, country_id)
    job = Job.find job_id
    job.in_progress!

    begin
      job.update result: Scraper.new(country_id).scrape.to_json
    rescue
      job.error!
      raise
    end
  end
end
