require 'lib/vincent/server'

# we want to test the behavior of vincent - not its implementation of fibers and EM
# vincent base must be run inside of vincent server --make more expicit

module Vincent
  describe Vincent do
    context "Base" do
      context "listen4" do
        it "should return a hash from the block" do
          Vincent::Server.start do |v|
            v.listen4("foo1") do |msg|
              { :hello => "dolly" }
            end
            v.call("foo1").should eql( "hello" => "dolly" )
            Vincent::Server.stop
          end
        end
      end
    end
  end
end
