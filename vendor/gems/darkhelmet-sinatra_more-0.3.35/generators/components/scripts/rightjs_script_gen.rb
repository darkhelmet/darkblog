module Sinatra
  module RightjsScriptGen

    def setup_script
      get("http://rightjs.org/builds/current/right-min.js", "public/javascripts/right-min.js")
      get("http://rightjs.org/builds/current/right-olds-min.js", "public/javascripts/right-olds-min.js")
    end
    
  end
end