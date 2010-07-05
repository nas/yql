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

  describe "#describe_table" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
    end

    it "should describe the current table using class method" do
      Yql::QueryBuilder.should_receive(:describe_table).with('yql.table.name')
      @query_builder.describe_table
    end

    it "should return the result from the class method" do
      Yql::QueryBuilder.stub!(:describe_table).and_return('table description')
      @query_builder.describe_table.should eql('table description')
    end

  end

  describe "#find" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
      @query_builder.stub!(:construct_query).and_return('The yql query')
    end

    it "should set the limit of records to 1 by default" do
      @query_builder.should_receive(:limit=).with(1)
      @query_builder.find
    end

    it "should construct the query" do
      @query_builder.should_receive(:construct_query)
      @query_builder.find
    end

    it "should return the constructed query" do
      @query_builder.find.should eql('The yql query')
    end

  end

  describe "#find_all" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
      @query_builder.stub!(:construct_query).and_return('The yql query')
    end

    context "when parameter hash has limit key" do

      it "should set the limit with provided value" do
        @query_builder.should_receive(:limit=).with(10)
        @query_builder.find_all({:limit => 10})
      end

      it "should set attr reader limit with value 10" do
        @query_builder.find_all({:limit => 10})
        @query_builder.limit.should eql('limit 10')
      end

    end

    context "when parameter hash does not have limit key" do

      it "should set the limit of records to nil" do
        @query_builder.should_receive(:limit=).with(nil)
        @query_builder.find_all
      end

      it "should set attr reader limit to nil" do
        @query_builder.find_all
        @query_builder.limit.should be_nil
      end

      it "should set attr reader limit to nil even if it was set previously" do
        @query_builder.limit = 20
        @query_builder.limit.should eql('limit 20')
        @query_builder.find_all
        @query_builder.limit.should be_nil
      end

    end

    it "should construct the query" do
      @query_builder.should_receive(:construct_query)
      @query_builder.find_all
    end

    it "should return the constructed query" do
      @query_builder.find_all.should eql('The yql query')
    end

  end

  describe "#to_s" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
      @query_builder.stub!(:construct_query).and_return('The yql query')
    end

    it "should construct the query" do
      @query_builder.should_receive(:construct_query)
      @query_builder.to_s
    end

    it "should return the constructed query" do
      @query_builder.to_s.should eql('The yql query')
    end

  end

  describe "#limit" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
    end

    it "should return nil if @limit instance is not set" do
      @query_builder.limit.should be_nil
    end

    it "should return the limit text with limit number" do
      @query_builder.limit = 3
      @query_builder.limit.should eql('limit 3')
    end

  end

  describe "#conditions" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
    end

    context "when condition is set as string" do

      it "should return the condition string with where clause" do
        @query_builder.conditions = "some sql like yql conditions"
        @query_builder.conditions.should eql('where some sql like yql conditions')
      end

    end

    context "when condition is passed as a hash" do

      before(:each) do
        @query_builder.conditions = {:attr1 => 'val1', :attr2 => 'val2', :attr3 => 4, :attr4 => '5'}
      end

      it "should 'where' text in the beginning of the return value" do
        @query_builder.conditions.should match(/^where attr/)
        # @query_builder.conditions.should match("where key1='val1' and key2='val2' and key3=4 and key4='5'")
      end

      it "should have the attr1 key value pair" do
        @query_builder.conditions.should match(/attr1='val1'/)
      end

      it "should have the attr2 key value pair" do
        @query_builder.conditions.should match(/attr2='val2'/)
      end

      it "should have the attr3 key value pair as integer" do
        @query_builder.conditions.should match(/attr3=4/)
      end

      it "should have the attr3 key value pair integer as string" do
        @query_builder.conditions.should match(/attr4='5'/)
      end

      it "should have 'and' only thrice in the returned value as there are 4 key values passed to condition" do
        @query_builder.conditions.scan('and').size.should eql(3)
      end

    end

  end

  describe "#tail" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
    end

    context "when tail pipe command is not set" do

      it "should return nothing" do
        @query_builder.tail.should be_nil
      end

      it "should not be present in the current pipe commands" do
        @query_builder.current_pipe_command_types.should_not be_include('tail')
      end

    end

    context "when tail pipe command is set" do

      before(:each) do
        @query_builder.tail = 4
      end

      it "should set the tail pipe command" do
        @query_builder.tail.should eql("tail(count=4)")
      end

      it "should get added to the current pipe commands" do
        @query_builder.current_pipe_command_types.should be_include('tail')
      end

    end

  end

  describe "#truncate" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
    end

    context "when truncate pipe command is not set" do

      it "should return nothing" do
        @query_builder.truncate.should be_nil
      end

      it "should not be present in the current pipe commands" do
        @query_builder.current_pipe_command_types.should_not be_include('truncate')
      end

    end

    context "when truncate pipe command is set" do

      before(:each) do
        @query_builder.truncate = 4
      end

      it "should set the truncate pipe command" do
        @query_builder.truncate.should eql("truncate(count=4)")
      end

      it "should get added to the current pipe commands" do
        @query_builder.current_pipe_command_types.should be_include('truncate')
      end

    end

  end

  describe "#reverse" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
    end

    context "when reverse pipe command is not set" do

      it "should return nothing" do
        @query_builder.reverse.should be_nil
      end

      it "should not be present in the current pipe commands" do
        @query_builder.current_pipe_command_types.should_not be_include('reverse')
      end

    end

    context "when reverse pipe command is set" do

      before(:each) do
        @query_builder.reverse = true
      end

      it "should set the reverse pipe command" do
        @query_builder.reverse.should eql('reverse()')
      end

      it "should get added to the current pipe commands" do
        @query_builder.current_pipe_command_types.should be_include('reverse')
      end

    end

  end

  describe "#unique" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
    end

    context "when unique pipe command is not set" do

      it "should return nothing" do
        @query_builder.unique.should be_nil
      end

      it "should not be present in the current pipe commands" do
        @query_builder.current_pipe_command_types.should_not be_include('unique')
      end

    end

    context "when unique pipe command is set" do

      before(:each) do
        @query_builder.unique = 'field_name'
      end

      it "should set the unique pipe command" do
        @query_builder.unique.should eql("unique(field='field_name')")
      end

      it "should get added to the current pipe commands" do
        @query_builder.current_pipe_command_types.should be_include('unique')
      end

    end

  end

  describe "#sort" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
    end

    context "when sort field is not set" do

      it "should return nothing" do
        @query_builder.sort.should be_nil
      end

      it "should not be present in the current pipe commands" do
        @query_builder.current_pipe_command_types.should_not be_include('sort')
      end

    end

    context "when sort field pipe command is set" do

      before(:each) do
        @query_builder.sort_field = 'field_name'
      end

      context "when sort descending is not set" do
        it "should set the unique pipe command" do
          @query_builder.sort.should eql("sort(field='field_name')")
        end
      end

      context "when sort descending is set" do
        it "should set the unique pipe command" do
          @query_builder.sort_descending = true
          @query_builder.sort.should eql("sort(field='field_name', descending='true')")
        end
      end

      it "should get added to the current pipe commands" do
        @query_builder.current_pipe_command_types.should be_include('sort')
      end

    end

  end

  describe "#sanitize" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
    end

    context "when sanitize field is not set" do

      it "should return nothing" do
        @query_builder.sanitize.should be_nil
      end

      it "should not be present in the current pipe commands" do
        @query_builder.current_pipe_command_types.should_not be_include('sanitize')
      end

    end

    context "when sanitize pipe command is set" do

      context "and it is set to true" do

        before(:each) do
          @query_builder.sanitize = true
        end

        it "should set the sanitizie pipe command" do
          @query_builder.sanitize.should eql("sanitize()")
        end

        it "should get added to the current pipe commands" do
          @query_builder.current_pipe_command_types.should be_include('sanitize')
        end

      end

      context "when sanitize_field is set" do

         before(:each) do
            @query_builder.sanitize_field = 'field_name'
          end

        it "should set the sanitize pipe command" do
          @query_builder.sanitize.should eql("sanitize(field='field_name')")
        end

        it "should get added to the current pipe commands" do
          @query_builder.current_pipe_command_types.should be_include('sanitize')
        end

      end

    end

  end

  describe "#remove_pipe_command" do

    before(:each) do
      @query_builder = Yql::QueryBuilder.new('yql.table.name')
      @query_builder.stub!(:current_pipe_command_types).and_return(['sort', 'sanitize', 'truncate'])
    end

    it "should remove the pipe command that is not present" do
      @query_builder.remove_pipe_command('not_present')
      @query_builder.current_pipe_command_types.should eql(['sort', 'sanitize', 'truncate'])
    end

    it "should remove the pipe command that is present" do
      @query_builder.remove_pipe_command('sort')
      @query_builder.current_pipe_command_types.should eql(['sanitize', 'truncate'])
    end

  end

end