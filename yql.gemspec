Gem::Specification.new do |s|
  s.name = %q{yql}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nasir Jamal"]
  s.date = %q{2010-06-20}
  s.description = %q{Yql is a ruby wrapper for Yahoo Query Language.}
  s.email = %q{nas35_in@yahoo.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["History.txt",
             "Manifest.txt",
             "README.rdoc",
             "lib/yql.rb",
             "lib/yql/error.rb",
             "lib/yql/response.rb",
             "lib/yql/client.rb",
             "lib/yql/query_builder.rb",
             ]
  #s.has_rdoc = true
  s.homepage = %q{http://github.com/nas/yql}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Yql is a ruby wrapper for Yahoo Query Language.}
  
  s.platform = Gem::Platform::RUBY 
  s.required_ruby_version = '>=1.8'
  
end
