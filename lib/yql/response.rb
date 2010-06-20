module Yql

  class Response
    
    def initialize(response, format)
      @response = response
      @format = format
    end
    
    def show
      raise Yql::ResponseFailure, body.inspect unless success?
      output
    end
    
    def body
      @response.body
    end
    
    def code
      @response.code
    end
    
    def success?
      code == '200'
    end
    
    private
    
    def output
      return body unless @format == 'xml'
      REXML::Document.new(body)
    end
    
  end
  
end