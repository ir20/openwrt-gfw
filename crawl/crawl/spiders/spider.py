import scrapy
import re
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor

class UrlSpider(CrawlSpider):
    name = "url"
    start_urls = ["https://downloads.openwrt.org/releases/19.07.0/targets/"]

    rules = (
        Rule(LinkExtractor(allow=("https://downloads.openwrt.org/releases/19.07.0/targets/.*/openwrt-sdk")), callback="parse_item", process_request="method_head"),
        Rule(LinkExtractor(allow=("https://downloads.openwrt.org/releases/19.07.0/targets/.*/$"), deny=("kmods/$", "packages/$")))
    )

    def parse_item(self, response):
        return {
            "arch": re.compile("targets/(.*)/openwrt-sdk").search(response.url).groups()[0].replace("/", "-"),
            "url": response.url
        }

    def method_head(self, request, response):
        request.method = "HEAD"
        return request
