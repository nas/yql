require 'net/http'
module Yql

  class Client
    
    BASE_URL   = 'query.yahooapis.com'
    VERSION    = 'v1'
    URL_SUFFIX = 'public/yql'
    YQL_ENV    = 'http://datatables.org/alltables.env'
    
    attr_accessor :query, :diagnostics, :format
    
    def initialize(args={})
      @diagnostics = args[:diagnostics] #true or false
      @version = args[:version]
      @query = args[:query]
      @format = args[:format] || 'xml'
    end
    
    def query
      @query.kind_of?(Yql::QueryBuilder) ? @query.to_s : @query
    end
    
    def version
      @version ||= VERSION
    end
    
    def full_url
      "#{version}/#{URL_SUFFIX}"
    end
    
    def get
      if query.nil?
        raise Yql::IncompleteRequestParameter, "Query not specified"
      end
      http = Net::HTTP.new(BASE_URL, Net::HTTP.https_default_port)
      http.use_ssl = true
      path = "/#{version}/#{URL_SUFFIX}"
      result = http.post(path, parameters)
      #raise(Yql::ResponseFailure, result.response) unless result.code == '200'
      return result.body unless format == 'xml'
      REXML::Document.new(result.body)
    end
    
    def parameters
      url_parameters = "q=#{CGI.escape(query)}&env=#{YQL_ENV}"
      url_parameters = add_format(url_parameters)
      add_diagnostics(url_parameters)
    end
    
    def add_format(existing_parameters)
      return unless existing_parameters
      return existing_parameters unless format
      return existing_parameters + "&format=#{format}"
    end
    
    def add_diagnostics(existing_parameters)
      return unless existing_parameters
      return existing_parameters unless diagnostics
      return existing_parameters + "&diagnostics=true"
    end
    
  end
  
end
