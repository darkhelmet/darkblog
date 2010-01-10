module BlogHelper
  module Test
    def good_get(*args)
      get(*args)
      last_response.should be_ok
    end

    def bad_get(*args)
      get(*args)
      last_response.should_not be_ok
    end
  end
end