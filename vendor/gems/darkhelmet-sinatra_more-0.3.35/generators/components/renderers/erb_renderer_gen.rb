module Sinatra
  module ErbRendererGen    
    def setup_renderer
      require_dependencies 'erubis'
    end
  end
end