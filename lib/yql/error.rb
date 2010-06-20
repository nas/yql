module Yql
  class Error < StandardError
    
    def initialize(data)
      @data = data
      super
    end
  end
  
  class ResponseFailure < Error
  end
  
  class NoResult < Error
  end
  
  class IncompleteRequestParameter < Error
  end
  
end