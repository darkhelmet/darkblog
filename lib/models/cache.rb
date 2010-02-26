class Cache < ActiveRecord::Base
  serialize :value

  class << self
    def get(key, max_age = 1.hour)
      item = Cache.first(:conditions => { :key => key })
      if block_given?
        if item.nil? || item.updated_at < max_age.ago
          begin
            value = yield
            Cache.put(key,value)
            value
          rescue Exception => e
            $stderr.puts(e.message)
            # TODO: refactor to use try
            item.nil? ? nil : item.value
          end
        else
          item.value
        end
      else
        # TODO: refactor to use try
        item.nil? ? nil : item.value
      end
    end

    def put(key, value)
      c = Cache.find_or_create_by_key(key)
      c.value = value
      c.save
      c.touch
    end

    def purge(key)
      items = key.nil? ? Cache.all : Cache.all(:conditions => { :key => key })
      items.each(&:destroy)
    end
  end
end