require 'lib/vincent/server'

# we want to test the behavior of vincent - not its implementation of fibers and EM

# vincent base must be run inside of vincent server --make more expicit


module Vincent
  describe Vincent do
    context "Base" do
      context "listen4" do
        it "should call return a array form inside the block" do
          v.listen4("foo3") do |msg|
             [ 1, 2, 3 ]
          end
          v.call("foo3").should eql([1, 2, 3])
        end
      end
    end
  end
end
