module Yql

  class Client

    BASE_URL   = 'query.yahooapis.com'
    VERSION    = 'v1'
    URL_SUFFIX = 'public/yql'
    OAUTH_SUFFIX = 'yql'
    YQL_ENV    = 'http://datatables.org/alltables.env'

    attr_accessor :query, :diagnostics
    attr_reader   :version, :format

    def initialize(args={})
      @diagnostics = args[:diagnostics] || false
      @version     = args[:version]     || VERSION
      @format      = args[:format]      || 'xml'
      @query       = args[:query]
      @verify_ssl  = args[:verify_ssl]  || true
      @consumer_key = args[:consumer_key] || false
      @consumer_secret = args[:consumer_secret] || false
      raise_when_invalid_format(format)
    end

    def format=(format)
      raise_when_invalid_format(format)
      @format = format
    end

    def query
      @query.kind_of?(Yql::QueryBuilder) ? @query.to_s : @query
    end

    def consumer_key=(consumer_key)
      @consumer_key = consumer_key
    end

    def consumer_secret=(consumer_secret)
      @consumer_secret = consumer_secret
    end

    def path_without_domain
      "/#{version}/#{URL_SUFFIX}"
    end

    def oauth_path_without_domain
      "/#{version}/#{OAUTH_SUFFIX}"
    end


    def get
      if query.nil?
        raise Yql::IncompleteRequestParameter, "You must set the query attribute for the Yql::Client object before sending the request"
      end
      if (@consumer_key and @consumer_secret)
        # With OAuth
        consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, :site => "http://#{BASE_URL}")
        access_token = OAuth::AccessToken.new(consumer)
        response = access_token.request(:get, "#{oauth_path_without_domain}?#{parameters}")
        Yql::Response.new(response, format)
      else
        # No OAuth
        http = Net::HTTP.new(BASE_URL, Net::HTTP.https_default_port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless @verify_ssl
        Yql::Response.new(http.post(path_without_domain, parameters), format)
      end
    end

    def valid_format?(format)
      return true if format == 'xml' || format == 'json'
      false
    end

    private

    def raise_when_invalid_format(format)
      return if valid_format?(format)
      raise InvalidRequestFormat, "Only json or xml formats are allowed"
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
