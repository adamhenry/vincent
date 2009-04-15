require 'lib/vincent/server'

# we want to test the behavior of vincent - not its implementation of fibers and EM
# vincent base must be run inside of vincent server --make more expicit

def vincent_server
  q = nil
  Vincent::Server.start do |v|
    begin
      yield(v)
    rescue Object => e
      q = e
    ensure 
      EM.stop
    end
  end
  raise q if q
end

module Vincent
  describe Vincent do
    context "xxx" do ## FIXME
      context "yyy" do ## FIXME
        it "should call return a array form inside the block" do
          Vincent::Server.start do |v|
            v.listen4("foo3") do |msg|
               [ 1, 2, 3 ]
            end
            v.call("foo3").should eql([1, 2, 3])
            EM.stop
          end
        end
      end
    end
  end
end

