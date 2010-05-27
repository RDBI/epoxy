require 'helper'

class TestEpoxy < Test::Unit::TestCase
    def test_01_basic
        ep = Epoxy.new("select * from foo where bar=?")
        assert(ep)
        assert_kind_of(Epoxy, ep)

        assert_equal("select * from foo where bar='foo'", ep.quote { |x| "'foo'" })
    end

    def test_02_double_question
        ep = Epoxy.new("select ?? from foo where bar=?")
        assert_equal("select ? from foo where bar='foo'", ep.quote { |x| "'foo'" })
    end

    def test_03_quotes_already
        ep = Epoxy.new("select * from \"foo\" where bar=?")
        assert_equal("select * from \"foo\" where bar='foo'", ep.quote { |x| "'foo'" })
        
        ep = Epoxy.new("select * from 'foo' where bar=?")
        assert_equal("select * from 'foo' where bar='foo'", ep.quote { |x| "'foo'" })
    end
    
    def test_04_holy_shit
        ep = Epoxy.new("select * from \"'foo'\" where bar=?")
        assert_equal("select * from \"'foo'\" where bar='foo'", ep.quote { |x| "'foo'" })
        
        ep = Epoxy.new("select * from E\"'foo'\" where bar=?")
        assert_equal("select * from E\"'foo'\" where bar='foo'", ep.quote { |x| "'foo'" })
        
        ep = Epoxy.new("select * from E\"''foo''\" where bar=?")
        assert_equal("select * from E\"''foo''\" where bar='foo'", ep.quote { |x| "'foo'" })
        
        ep = Epoxy.new("select * from E\"\\''foo''\" where bar=?")
        assert_equal("select * from E\"\\''foo''\" where bar='foo'", ep.quote { |x| "'foo'" })
        
        ep = Epoxy.new("select * from E\"\\''foo\\''\" where bar=?")
        assert_equal("select * from E\"\\''foo\\''\" where bar='foo'", ep.quote { |x| "'foo'" })
       
        ep = Epoxy.new("select * from foo where bar='?'")
        assert_equal("select * from foo where bar='?'", ep.quote { |x| "'foo'" })
    end

    def test_05_comments
        ep = Epoxy.new(%Q{
                       -- a comment!
                       select * from foo where bar=?
                       }.strip)
        
        assert_equal(%Q{
                       -- a comment!
                       select * from foo where bar='foo'
                     }.strip, ep.quote { |x| "'foo'" })
    end
end
