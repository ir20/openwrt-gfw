import scrapy
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor

class UrlSpider(CrawlSpider):
    name = "url"
    start_urls = ["https://downloads.openwrt.org/releases/19.07.4/targets/"]

    rules = (
        Rule(LinkExtractor(allow=("https://downloads.openwrt.org/releases/19.07.4/targets/.*/openwrt-sdk"), deny_extensions=()), callback="parse_item", process_request="method_head"),
        Rule(LinkExtractor(allow=("https://downloads.openwrt.org/releases/19.07.4/targets/.*/$"), deny=("kmods/$", "packages/$")))
    )

    def parse_item(self, response):
        return { "url": response.url }

    def method_head(self, request, response):
        request.method = "HEAD"
        return request
