class ScrapeJob
  @queue = :scrape

  def self.perform(job_id, country_id)
    Scraper.new(country_id).scrape(job_id)
  end
end
