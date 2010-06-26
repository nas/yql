require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Yql::Response do
  
  before(:each) do
    @response = 'any response'
    @format = 'xml'
  end
  
  describe "#show" do
    
    before(:each) do
      @yql_response = Yql::Response.new(@response, @format)
    end
    
    context "when request failed" do
      
      before(:each) do
        @yql_response.stub!(:body).and_return("Some error in xml or json format")
        @yql_response.stub!(:success?).and_return(false)
      end
      
      it "should raise error" do
        lambda { @yql_response.show }.should raise_error(Yql::ResponseFailure, "Some error in xml or json format".inspect)
      end
      
    end
    
    context "when request and response are successfull" do
      
      before(:each) do
        @yql_response.stub!(:output).and_return("The output")
        @yql_response.stub!(:success?).and_return(true)
      end
      
      it "should not raise error" do
        lambda { @yql_response.show }.should_not raise_error
      end
      
      it "should return the output" do
        @yql_response.show.should eql('The output')
      end
      
    end
    
  end
  
  describe "#body" do
    
    before(:each) do
      @yql_response = Yql::Response.new(@response, @format)
      @response.stub!(:body).and_return('The body of response')
    end
    
    it "should return the body of the yql response" do
      @yql_response.body.should eql("The body of response")
    end
    
  end
  
  describe "#code" do
    
    before(:each) do
      @yql_response = Yql::Response.new(@response, @format)
      @response.stub!(:code).and_return('200')
    end
    
    it "should return the body of the yql response" do
      @yql_response.code.should eql('200')
    end
    
  end
  
  describe "#success?" do
    
    before(:each) do
      @yql_response = Yql::Response.new(@response, @format)
    end
    
    it "should be true if the response code is '200'" do
      @response.stub!(:code).and_return('200')
      @yql_response.should be_success
    end
    
    it "should be false if the response code is not '200'" do
      @response.stub!(:code).and_return('201')
      @yql_response.should_not be_success
    end
    
  end
  
  describe "#output" do
    
    context "when the format of request was not set to xml" do
      
      before(:each) do
        @yql_response = Yql::Response.new(@response, 'json')
      end

      it "should return the response body as output" do
        @yql_response.stub!(:body).and_return('Probably json output')
        @yql_response.output.should eql('Probably json output')
      end
      
    end
    
    context "when the format of request was set to xml" do
      
      before(:each) do
        @yql_response = Yql::Response.new(@response, 'xml')
        @yql_response.stub!(:body).and_return('XML output')
        @rexml_obj = stub
        REXML::Document.stub!(:new).and_return(@rexml_obj)
      end

      it "should return the response body as output" do
        @yql_response.output.should eql(@rexml_obj)
      end
      
      it "should create a rexml object of the returned xml response" do
        REXML::Document.should_receive(:new).with('XML output')
        @yql_response.output
      end
      
    end
    
    
  end
  
end