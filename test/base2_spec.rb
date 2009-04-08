require 'lib/vincent/server'

# we want to test the behavior of vincent - not its implementation of fibers and EM

# vincent base must be run inside of vincent server --make more expicit


module Vincent
  describe Vincent do
    context "Base" do
      context "listen4" do
        it "should rase and error from inside the block" do
          Vincent::Server.start do |v|
            begin
              v.listen4("foo2") do |msg|
                raise "hello"
              end
              lambda { v.call("foo2") }.should raise_error RuntimeError
            ensure
              Vincent::Server.stop
            end
          end
        end
      end
    end
  end
end
