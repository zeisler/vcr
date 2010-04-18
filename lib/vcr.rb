require 'vcr/cassette'
require 'vcr/config'
require 'vcr/cucumber_tags'
require 'vcr/deprecations'
require 'vcr/structs'

require 'vcr/extensions/net_read_adapter'

require 'vcr/http_stubbing_adapters/base'

module VCR
  extend self

  def current_cassette
    cassettes.last
  end

  def insert_cassette(*args)
    cassette = Cassette.new(*args)
    cassettes.push(cassette)
    cassette
  end

  def eject_cassette
    cassette = cassettes.pop
    cassette.eject if cassette
    cassette
  end

  def use_cassette(*args)
    insert_cassette(*args)
    yield
  ensure
    eject_cassette
  end

  def config
    yield VCR::Config
  end

  def cucumber_tags(&block)
    main_object = eval('self', block.binding)
    yield VCR::CucumberTags.new(main_object)
  end

  def http_stubbing_adapter
    @http_stubbing_adapter ||= begin
      adapter = case VCR::Config.http_stubbing_adapter
        when :fakeweb
          VCR::HttpStubbingAdapters::FakeWeb
        when :webmock
          VCR::HttpStubbingAdapters::WebMock
        else
          raise ArgumentError.new("The http stubbing adapter is not configured correctly.  You should set it to :webmock or :fakeweb.")
      end

      adapter.check_version!
      adapter.http_connections_allowed = false
      adapter
    end
  end

  private

  def cassettes
    @cassettes ||= []
  end
end