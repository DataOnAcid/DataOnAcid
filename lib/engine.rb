require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'yaml'

class DataOnAcid < Sinatra::Base

  def initialize
    super

    @renderers = load_renderers
  end

  configure do
    disable :protection
    set :root, File.join(File.dirname(__FILE__), "..")
  end

  get "/" do
    erb :index
  end

  post "/" do
    request["data"]
  end

  get "/view/:type" do |type|
    renderer = @renderers[type] || @renderers["default"]
    content = case renderer[:include]
              when :inline, :none
                `#{renderer[:script]} #{request[:url]}`
              else
                renderer[:include] % "/render/#{type}?url=#{request[:url]}"
              end

    renderer[:include] == :none ? content : "<html><body>#{content}</body></html>"
  end

  get "/render/:type" do |type|
    renderer = @renderers[type]

    `#{renderer[:script]} #{request[:url]}`
  end

  private

  def load_renderers
    YAML.load(File.open("renderers.yml", "r"))
  rescue ArgumentError => e
    puts "Could not parse renderers file."
    exit(1)
  end

end
