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
            EM.stop_event_loop
          end
        end
        it "should rase and error from inside the block" do
          Vincent::Server.start do |v|
            puts "x1"
            begin
            puts "x2"
              v.listen4("foo2") do |msg|
            puts "x3"
                raise "hello"
            puts "x4"
              end
            puts "x5"
              lambda { v.call("foo2") }.should raise_error RuntimeError
            puts "x6"
            ensure
            puts "x7"
              EM.stop_event_loop
            puts "x8"
            end
            puts "x9"
          end
        end
        xit "should call return a array form inside the block" do
          Vincent::Server.start do |v|
            v.listen4("foo3") do |msg|
               [ 1, 2, 3 ]
            end
            v.call("foo3").should eql([1, 2, 3])
            EM.stop_event_loop
          end
        end
        end
    end
  end
end
