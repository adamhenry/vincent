require 'lib/vincent/server'

## This is an integration test that does NOT mock out the AMQP server,
## rather it requires its presence 

## Problems with event machine and fibers has caused me to break this 
## into 3 files.  If anyone knows of a good way to make these be a single
## test file, I would welcome the patch.

module Vincent
  describe Vincent do
    context "Base" do
      context "call" do
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
