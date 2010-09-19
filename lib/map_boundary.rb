
class MapBoundary
  attr_accessor :name
  attr_accessor :encoded_levels
  attr_accessor :encoded_poly
  
  def initialize()
  end

  def get_url()
    base = 'http://maps.google.com/maps/api/staticmap?'
    gen_params = []
    gen_params << 'sensor=false'
    gen_params << 'size=640x640'

    path_params = []
    path_params << 'fillcolor:0xAA000055'
    path_params << 'color:0xFFFFFF00'
    path_params << "enc:#{encoded_poly}"

    url = "#{base}"
    url << gen_params.join('&')

    unless path_params.empty?
      url << "&path="
      url << path_params.join('|')
    end
    url
  end
end
