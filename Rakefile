require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "epoxy"
    gem.summary = %Q{A binding API for query languages that does not depend on any specific database.}
    gem.description = %Q{Parse binds in SQL or any other data query language, quote, even configure for client-side binding. It all works!}
    gem.email = "erik@hollensbe.org"
    gem.homepage = "http://github.com/erikh/epoxy"
    gem.authors = ["Erik Hollensbe"]
    gem.add_development_dependency 'rdoc'
    gem.add_development_dependency 'test-unit'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

task :to_blog => [:clobber_rdoc, :rdoc] do
    sh "rm -fr $git/blog/content/docs/epoxy && mv rdoc $git/blog/content/docs/epoxy"
end

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "epoxy #{version}"
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
