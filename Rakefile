require 'rush'
rush = Rush::Box.new[Dir.pwd + '/']

task :test => [:vincent_test, :integration_test] do
  puts("All tests ran")
end

task :integration_test do
  test = rush.bash("spec test/base_spec.rb").split("\n")[-1]
  puts "intergration_test #{test}"
end

task :vincent_test do
  test = rush.bash("spec test/vincent_spec.rb").split("\n")[-1]
  puts "vincent_test #{test}"
end
