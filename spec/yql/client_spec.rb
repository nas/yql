require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Yql::Client do

  describe ".new" do

    context "when no arguments provided" do

      before(:each) do
        @yql_client = Yql::Client.new
      end

      it "should set the format to xml by default" do
        @yql_client.format.should eql('xml')
      end

      it "should have the api version set to 'v1' by default" do
        @yql_client.version.should eql('v1')
      end

      it "should have the diagnostics turned off" do
        @yql_client.diagnostics.should be_false
      end

    end

    context "when arguments provided" do

      before(:each) do
        @yql_client = Yql::Client.new(:format => 'json', :version => 'v2', :diagnostics => true)
      end

      it "should set the format" do
        @yql_client.format.should eql('json')
      end

      it "should set the api version" do
        @yql_client.version.should eql('v2')
      end

      it "should have the diagnostics turned on" do
        @yql_client.diagnostics.should be_true
      end

    end

    describe "#query" do

      before(:each) do
        @yql_client = Yql::Client.new
      end

      context "when query is set to a string query" do

        before(:each) do
          @yql_client.query = "select * from yelp.review.search where term = 'something' and location like '%london%'"
        end

        it "should return the query string provided" do
          @yql_client.query.should eql("select * from yelp.review.search where term = 'something' and location like '%london%'")
        end

      end

      context "when query is set to the query builder object" do

        before(:each) do
          @query = Yql::QueryBuilder.new('yql.table.name')
          @yql_client.query = @query
        end

        it "should build and return the query from the query builder object" do
          @yql_client.query.should eql("select * from yql.table.name")
        end

      end

    end

    describe "#version" do

      context "when version not provided on class initialization" do

        before(:each) do
          @yql_client = Yql::Client.new
        end


        it "should return the default version" do
          @yql_client.version.should eql('v1')
        end

      end

      context "when version provided on class initialization" do

        before(:each) do
          @yql_client = Yql::Client.new(:version => 'v4')
        end


        it "should return the default version" do
          @yql_client.version.should eql('v4')
        end

      end
    end

  end

  describe "#path_without_domain" do

    before(:each) do
      @yql_client = Yql::Client.new
    end

    context "when version not provided on class initialization" do

      before(:each) do
        @yql_client = Yql::Client.new
      end


      it "should return the path without the domain part" do
        @yql_client.path_without_domain.should eql('/v1/public/yql')
      end

    end

    context "when version provided on class initialization" do

      before(:each) do
        @yql_client = Yql::Client.new(:version => 'v4')
      end


      it "should return the path without the domain part" do
        @yql_client.path_without_domain.should eql('/v4/public/yql')
      end

    end

  end

  describe "#get" do

    before(:each) do
      @yql_client = Yql::Client.new
    end

    context "when query attribute is not set" do

      it "should raise error" do
        lambda { @yql_client.get }.should raise_error(Yql::IncompleteRequestParameter, "You must set the query attribute for the Yql::Client object before sending the request")
      end

    end

    context "when query attribute is set" do

      before(:each) do
        @yql_client.query = "addquery"
        @net_http = stub(:use_ssl= => true, :post => 'response')
        Net::HTTP.stub!(:new).and_return(@net_http)
        @response_object = stub
        Yql::Response.stub!(:new).and_return(@response_object)
      end

      it "should create a new http object for connecting to yahoo YQL" do
        Net::HTTP.should_receive(:new).with('query.yahooapis.com', Net::HTTP.https_default_port).and_return(@net_http)
        @yql_client.get
      end

      it "should set the ssl for http object" do
        @net_http.should_receive(:use_ssl=).with(true)
        @yql_client.get
      end

      it "should return the response object" do
        @yql_client.get.should eql(@response_object)
      end

      context "and format is set to default ie, xml" do

        it "should send the request to get data" do
          @net_http.should_receive(:post).with('/v1/public/yql', 'q=addquery&env=http://datatables.org/alltables.env&format=xml')
          @yql_client.get
        end

        it "should create the response object" do
          Yql::Response.should_receive(:new).with('response', 'xml')
          @yql_client.get
        end

      end

      context "and format is set to json" do

        before(:each) do
          @yql_client.format = 'json'
        end

        it "should send the request to get data" do
          @net_http.should_receive(:post).with('/v1/public/yql', 'q=addquery&env=http://datatables.org/alltables.env&format=json')
          @yql_client.get
        end

        it "should create the response object" do
          Yql::Response.should_receive(:new).with('response', 'json')
          @yql_client.get
        end

      end

    end

  end

end