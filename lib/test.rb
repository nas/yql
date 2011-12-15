require './yql.rb'


yql = Yql::Client.new
query = Yql::QueryBuilder.new 'yahoo.finance.quotes'
query.select = 'Symbol, Ask'
query.conditions = "symbol IN ('AAPL', 'GOOG')"
yql.query = query
yql.format = 'json'
yql.consumer_key = 'dj0yJmk9Q25kZTN5YXB1dk40JmQ9WVdrOWFIRkRNRE5RTjJzbWNHbzlPREV5TWpZMk1UWXkmcz1jb25zdW1lcnNlY3JldCZ4PTA0'
yql.consumer_secret = '18ec8d573039ae55d1741d74ff054c6887402cc6'

response = yql.get

puts response.show