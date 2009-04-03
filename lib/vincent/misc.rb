# this is taken from merb core
class HASH
  # File merb/core_ext/hash.rb, line 166
  def symbolize_keys!
    each do |k, v| 
      sym = k.respond_to?(:to_sym) ? k.to_sym : k 
      self[sym] = Hash === v ? v.symbolize_keys! : v 
      delete(k) unless k == sym
    end
    self
  end
end
