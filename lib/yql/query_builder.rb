module Yql

  class QueryBuilder

    attr_accessor :table, :conditions, :limit, :select, :sort_descending,
                  :current_pipe_command_types, :per_page, :current_page

    attr_reader   :sort_field, :sanitize_field

    def initialize(table, args = {})
      @select                     = args[:select]
      @table                      = table
      @use_statement              = args[:use]
      @conditions                 = args[:conditions]
      @limit                      = args[:limit]
      @tail                       = args[:tail]
      @reverse                    = args[:reverse]
      @unique                     = args[:unique]
      @sanitize                   = args[:sanitize]
      @sort_descending            = args[:sort_descending]
      @sanitize_field             = args[:sanitize_field]
      @sort_field                 = args[:sort_field]
      @current_pipe_command_types = []
      @per_page                   = args[:per_page]
    end

    def self.show_tables
      "show tables;"
    end

    def self.describe_table(table)
      "desc #{table};"
    end

    def describe_table
      Yql::QueryBuilder.describe_table(table)
    end

    def find
      self.limit = 1
      "#{construct_query}"
    end

    # Can be optionally passed a limit for limiting the number of records returned
    # object.find_all(:limit => 10)
    #     #=> will return only 10 records
    # object.find_all
    #     #=> will return all records
    def find_all(args = {})
      self.limit = args[:limit] || nil
      construct_query
    end

    def to_s
      construct_query
    end

    def limit
      return unless @limit
      "limit #{@limit}"
    end

    # Conditions can either be provided as hash or plane string
    def conditions
      if @conditions.kind_of?(String)
        cond = @conditions
      elsif @conditions.kind_of?(Hash)
        cond = @conditions.collect do |k,v|
                 val = v.kind_of?(String) ? "'#{v}'" : v
                 "#{k.to_s}=#{val}"
              end
        cond = cond.join(' and ')
      else
        return
      end
      return "where #{cond}"
    end

    %w{sort_field tail truncate reverse unique sanitize_field}.each do |method|
      self.send(:define_method, "#{method}=") do |param|
        instance_variable_set("@#{method}", param)
        pipe_command_type = method.sub('_field', '')
        current_pipe_command_types << pipe_command_type  unless current_pipe_command_types.include?(pipe_command_type)
      end
    end

    # Option can be piped
    # Gets the last count items
    def tail
      return unless @tail
      "tail(count=#{@tail})"
    end

    # Option can be piped
    # Gets the first count items (rows)
    def truncate
      return unless @truncate
      "truncate(count=#{@truncate})"
    end

    # Option can be piped
    # Reverses the order of the rows
    def reverse
      return unless @reverse
      "reverse()"
    end

    # Option can be piped
    # Removes items (rows) with duplicate values in the specified field (column)
    def unique
      return unless @unique
      "unique(field='#{@unique}')"
    end

    # set sanitize to true if you want to sanitize all fields
    def sanitize=(sanitize)
      @sanitize       = sanitize
      @sanitize_field = nil
      if @sanitize
        current_pipe_command_types << 'sanitize'  unless current_pipe_command_types.include?('sanitize')
      else
        remove_pipe_command('sanitize')
      end
    end

    # Option can be piped
    # Sanitizes the output for HTML-safe rendering. To sanitize all returned fields, omit the field parameter.
    def sanitize
      return unless @sanitize || @sanitize_field
      return "sanitize()" unless @sanitize_field
      "sanitize(field='#{@sanitize_field}')"
    end

    # Option can be piped
    # Sorts the result set according to the specified field (column) in the result set.
    def sort
      return unless @sort_field
      return "sort(field='#{@sort_field}')" unless @sort_descending
      return "sort(field='#{@sort_field}', descending='true')"
    end

    # Its always advisable to order the pipe when there are more than one
    # pipe commands available else unexpected results might get returned
    # reorder_pipe_command {:from => 1, :to => 0}
    # the values in the hash are the element numbers
    #
    def reorder_pipe_command(args)
      return if current_pipe_command_types.empty?
      if args[:from].nil? or args[:to].nil?
        raise Yql::Error, "Not able to move pipe commands. Wrong element numbers. Please try again"
      end
      args.values.each do |element|
        if element > current_pipe_command_types.size-1
          raise Yql::Error, "Not able to move pipe commands. Wrong element numbers. Please try again"
        end
      end
      element_to_be_inserted_at = args[:from] < args[:to] ? args[:to]+1 : args[:to]
      element_to_be_removed = args[:from] < args[:to] ? args[:from] : args[:from]+1
      current_pipe_command_types.insert(element_to_be_inserted_at, current_pipe_command_types.at(args[:from]))
      current_pipe_command_types.delete_at(element_to_be_removed)
    end


    # Remove a command that will be piped to the yql query
    def remove_pipe_command(command)
      current_pipe_command_types.delete(command)
    end

    private

    def pipe_commands
      return if current_pipe_command_types.empty?
      '| ' + current_pipe_command_types.map{|c| self.send(c)}.join(' | ')
    end

    def build_select_query
      [select_statement, conditions, limit, pipe_commands].compact.join(' ')
    end

    def construct_query
      return build_select_query unless @use
      return [@use, build_select_query].join('; ')
    end

    def select_statement
      select = "select #{column_select} from #{table}"
      return select unless per_page
      with_pagination(select)
    end

    def with_pagination(select)
      self.current_page ||= 1
      offset = (current_page - 1) * per_page
      last_record = current_page * per_page
      "#{select}(#{offset},#{last_record})"
    end

    def column_select
      @select ? @select : '*'
    end

  end

end
