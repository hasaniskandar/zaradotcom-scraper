class Scraper
  DEFAULT_USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36"

  def initialize(country_id, user_agent: DEFAULT_USER_AGENT)
    @country_id = country_id
    @page       = Watir::Browser.new :phantomjs, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.phantomjs("phantomjs.page.settings.userAgent" => user_agent)
  end

  def scrape(job_id)
    job = Job.find(job_id)
    job.in_progress!

    begin
      open_store @country_id
      job.result = fetch
    rescue
      job.error!
      raise
    end

    job.done!
  end

private

  def collect_items(url, group:)
    return if @page.url == url

    goto url

    @items += @page.elements(css: "#product-list .product > a, a._product-link").map do |a|
      { source: a.attribute_value(:href),
        group:  group.titleize
      }
    end
  end

  def fetch
    @items  = []

    menu("ul#mainNavigationMenu > li > a", stop: "PICTURES").each do |first|
      goto first[:url]

      menu("ul#mainNavigationMenu > li.current > ul > li > a").each do |second|
        collect_items second[:url], group: "#{first[:text]} #{second[:text]}"

        menu("ul#mainNavigationMenu > li.current > ul > li.current > ul > li > a").each do |third|
          collect_items third[:url], group: "#{first[:text]} #{second[:text]} #{third[:text]}"
        end
      end
    end

    fetch_item_details
  end

  def fetch_item_details
    @items.each do |item|
      goto item[:source]

      item.merge!(
        title:     @page.title,
        photo_url: @page.element(css: "#product .image-big").attribute_value(:src),
        price:     @page.element(css: "#product .price").text
      )
    end
  end

  def menu(selector, stop: nil)
    @page.element(css: "#toggleMenuLnk").click # make sure the menu shown

    @page.elements(css: selector).map do |a|
      break if stop && a.text == stop

      { text: a.text,
        url:  a.attribute_value(:href)
      } if a.text.present?
    end.compact
  end

  def goto(url, retries = 2)
    @page.goto url
  rescue
    retries -= 1
    retries < 0 ? raise : retry
  end

  def open_store(country_id)
    goto "http://www.zara.com/"

    @page.element(css: "#selStore .arrow").click
    @page.a(href: "http://www.zara.com/#{country_id}/").click
    @page.element(css: "#wwButtom").click
  end
end
