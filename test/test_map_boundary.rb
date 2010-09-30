$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'map_boundary'
require 'yaml'

class TestMapBoundary < Test::Unit::TestCase

  def test_yaml_roundtrip
    ary = Array.new

    a = MapBoundary.new
    a.name = 'A'
    a.encoded_poly = 'wflbHl}biUX_lGzyAk@a@hlGyyAX'
    a.encoded_levels = 'BBBBB'

    b = MapBoundary.new
    b.name = 'B'
    b.encoded_poly = 'wflbHl}biUX_lGzyAk@a@hlGyyAX'
    b.encoded_levels = 'BBBBB'

    ary << a
    ary << b

    data = YAML.dump(ary)
    obj = YAML.load(data)
    assert(obj.class.to_s == 'Array')
    assert(obj.size == 2)
    assert(obj[0].class.to_s == "MapBoundary")
  end

  def test_get_url
    a = MapBoundary.new
    a.name = 'A'
    a.encoded_poly = 'wflbHl}biUX_lGzyAk@a@hlGyyAX'
    a.encoded_levels = 'BBBBB'

    expected = 'http://maps.google.com/maps/api/staticmap?sensor=false&size=640x640&path=fillcolor:0xAA000055|color:0xFFFFFF00|enc:wflbHl}biUX_lGzyAk@a@hlGyyAX'
    assert(expected == a.get_url)
  end

  def test_hash_yaml
    hsh = Hash.new
    hsh['A'] = 'Troop 220'
    hsh['B'] = 'Troop 880'
    data = YAML.dump(hsh)
    obj = YAML.load(data)
    assert(obj.class.to_s == 'Hash')
    assert(obj.size == 2)
  end

end
