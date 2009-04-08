require 'lib/vincent/server'

# we want to test the behavior of vincent - not its implementation of fibers and EM

# vincent base must be run inside of vincent server --make more expicit


module Vincent
  describe Vincent do
    context "Base" do
      context "listen4" do
        Vincent::Server.start do |v|
          begin
            it "should return a hash from the block" do
              v.listen4("foo1") do |msg|
                { :hello => "dolly" }
              end
              v.call("foo1").should eql( "hello" => "dolly" )
            end
            it "should rase and error from inside the block" do
              v.listen4("foo2") do |msg|
                raise "hello"
              end
              lambda { v.call("foo2") }.should raise_error RuntimeError
            end
            it "should call return a array form inside the block" do
              v.listen4("foo3") do |msg|
                 [ 1, 2, 3 ]
              end
              v.call("foo3").should eql([1, 2, 3])
            end
          ensure
            Vincent::Server.stop
          end
        end
      end
    end
  end
end
