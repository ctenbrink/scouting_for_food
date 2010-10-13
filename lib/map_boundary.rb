
class MapBoundary
  attr_accessor :name
  attr_accessor :encoded_levels
  attr_accessor :encoded_poly

  @@domain = 'maps.google.com'
  @@path = '/maps/api/staticmap?'
  
  def initialize()
  end

  def get_domain()
    @@domain
  end

  def get_path()
    @@path
  end

  def get_query()
    gen_params = []
    gen_params << 'sensor=false'
    gen_params << 'size=640x640'

    path_params = []
    path_params << 'fillcolor:0xAA000055'
    path_params << 'color:0xFFFFFF00'
    path_params << "enc:#{encoded_poly}"

    query = gen_params.join('&')

    unless path_params.empty?
      query << "&path="
      query << path_params.join('|')
    end
    query
  end

  def get_url()
    url = "http://#{get_domain}#{get_path}#{get_query}"
    url
  end
end
