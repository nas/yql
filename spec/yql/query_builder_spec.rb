require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Yql::QueryBuilder do

  describe ".show_tables" do

    it "should return show tables string" do
      Yql::QueryBuilder.show_tables.should eql('show tables;')
    end

  end

  describe ".describe_table" do

    it "should return the describe tables query" do
      Yql::QueryBuilder.describe_table('yql.table.name').should eql('desc yql.table.name;')
    end

  end

end