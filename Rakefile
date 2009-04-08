require 'rush'

def build_test test 
  rush = Rush::Box.new[Dir.pwd + '/']
  long = test.match(/(.*)_spec\.rb/)[1]

  desc "runs spec on #{test}"
  task long do
    puts rush.bash("spec test/#{test}")
  end

  desc "short spec for #{test}"
  task test do
    test_results = rush.bash("spec test/#{test}")
    puts "#{test_results.split("\n")[-1]} from #{long}"
  end
end

desc "same ass rake test:all"
task :default=> 'test:all'

namespace :test do
  files = %w( vincent_spec.rb base1_spec.rb base2_spec.rb base3_spec.rb )

  desc "runs all tests"
  task :all => files

  files.each do |file|
    build_test file
  end

end
