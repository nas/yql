$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'CGI'
require 'net/http'
require 'net/https'
require 'rexml/document'
require 'yql/error.rb'
require 'yql/client.rb'
require 'yql/query_builder.rb'
require 'yql/response.rb'