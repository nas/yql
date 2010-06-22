module Yql

  class Client
    
    BASE_URL   = 'query.yahooapis.com'
    VERSION    = 'v1'
    URL_SUFFIX = 'public/yql'
    YQL_ENV    = 'http://datatables.org/alltables.env'
    
    attr_accessor :query, :diagnostics, :format
    attr_reader   :version
    
    def initialize(args={})
      @diagnostics = args[:diagnostics] || false
      @version     = args[:version]     || VERSION
      @format      = args[:format]      || 'xml'
      @query       = args[:query]
    end
    
    def query
      @query.kind_of?(Yql::QueryBuilder) ? @query.to_s : @query
    end
    
    def path_without_domain
      "/#{version}/#{URL_SUFFIX}"
    end
    
    def get
      if query.nil?
        raise Yql::IncompleteRequestParameter, "Query not specified"
      end
      http = Net::HTTP.new(BASE_URL, Net::HTTP.https_default_port)
      http.use_ssl = true
      Yql::Response.new(http.post(path_without_domain, parameters), format)
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
