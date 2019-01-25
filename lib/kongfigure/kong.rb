module Kongfigure
  class Kong

    def initialize(parser, http_client)
      @parser      = parser
      @http_client = http_client
      display_information
    end

    def apply!
      @configuration = @parser.parse!
      puts @configuration.to_s
      puts "Applying configuration...".colorize(:color => :white, :background => :red)
      apply_all(@configuration.plugins, Kongfigure::Services::Plugin)
      apply_all(@configuration.upstreams, Kongfigure::Services::Upstream)
      apply_all(@configuration.services, Kongfigure::Services::Service)
      apply_all(@configuration.consumers, Kongfigure::Services::Consumer)
      puts "Done.".colorize(:color => :white, :background => :red)
    end

    def apply_all(resources, service_module)
      service          = service_module.new(@http_client)
      puts "<- Fetching remote #{service.resource_name}..."
      remote_resources = service.all

      resources.map do |resource|
        service.create_or_update(@http_client, resource, remote_resources)
      end
      service.cleanup_useless_resources(@http_client, resources, remote_resources)
    end

    def display_information
      data = @http_client.get("/")
      puts "Kong information:".colorize(:color => :white, :background => :red)
      puts "* hostname: \t#{data['version']}"
      puts "* version: \t#{data['hostname']}"
      puts "* lua_version: \t#{data['lua_version']}"
    end
  end
end
