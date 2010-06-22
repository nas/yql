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
end