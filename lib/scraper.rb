class Scraper
  DEFAULT_USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36"

  def initialize(country_id, user_agent: DEFAULT_USER_AGENT)
    @country_id = country_id
    @page       = Watir::Browser.new :phantomjs, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.phantomjs("phantomjs.page.settings.userAgent" => user_agent)
  end

  def scrape
    open_store @country_id
    fetch
  end

protected

  def fetch
    items = []

    # collect item urls
    map_groups("ul#mainNavigationMenu > li > a", stop: "LOOKBOOK").each do |group|
      goto group

      map_groups("ul#mainNavigationMenu > li.current > ul > li > a").each do |group|
        items |= map_items group

        map_groups("ul#mainNavigationMenu > li.current > ul > li.current > ul > li > a").each do |group|
          items |= map_items group
        end
      end
    end

    # collect item details
    items.map do |url|
      goto url

      if @page.element(css: "#product").exists? && !@page.element(css: "#bundleRightMenu").exists?
        group = []

        @page.elements(css: "ul#mainNavigationMenu li.current > a").each_with_index do |element, i|
          text = element.attribute_value(:text)
          group << (i.zero? && text != "TRF" ? text.humanize : text)
        end

        { source:    @page.url,
          title:     @page.title,
          group:     group.join(" "),
          photo_url: @page.elements(css: "#product .image-big, #product .related-image").map { |element| element.attribute_value(:src) }.detect(&:present?),
          price:     @page.elements(css: "#product .price").map(&:text).detect(&:present?)
        }
      end
    end.compact
  end

  def goto(url, retries = 2)
    @page.goto url
  rescue
    retries -= 1
    retries < 0 ? raise : retry
  end

  def map_groups(selector, stop: nil)
    # make sure the menu shown
    toggle = @page.element(css: "#toggleMenuLnk")
    toggle.click if toggle.exists? && toggle.visible?

    list = []

    @page.elements(css: selector).each do |element|
      break if stop && element.text == stop

      list << element.attribute_value(:href) if element.visible?
    end

    list
  end

  def map_items(url)
    return [] if @page.url == url

    goto url

    @page.elements(css: "#product-list .product > a, a._product-link").map { |element| element.attribute_value(:href) }
  end

  def open_store(country_id)
    goto "http://www.zara.com/"

    @page.element(css: "#selStore .arrow").click
    @page.a(href: "http://www.zara.com/#{country_id}/").click
    @page.element(css: "#wwButtom").click
  end
end
