class ScrapeJob
  @queue = :scrape

  def self.perform(job_id, country_id)
    job = Job.find job_id
    job.in_progress!

    begin
      result = Scraper.new(country_id).scrape.group_by { |item| item["price"].present? }
      job.update(
        result: result[true].to_json_without_active_support_encoder,
        other:  result[false].each { |item| item.delete "price" }.to_json_without_active_support_encoder
      )
    rescue
      job.error!
      raise
    end
  end
end
