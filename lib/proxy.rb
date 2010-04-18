class Proxy
  instance_methods.each { |m| undef_method(m) unless m =~ /(^__|^send$|^object_id$)/ }

  def initialize(target)
    @target = target
  end

protected

  def method_missing(name, *args, &block)
    @target.send(name, *args, &block)
  end
end
