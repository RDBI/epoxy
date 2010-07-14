require 'helper'

class TestEpoxy < Test::Unit::TestCase
  def test_01_basic
    ep = Epoxy.new("select * from foo where bar=?")
    assert(ep)
    assert_kind_of(Epoxy, ep)

    assert_equal("select * from foo where bar='foo'", ep.quote { |x| "'foo'" })
  end

  def test_02_literal_question_mark
    ep = Epoxy.new("select ?? from foo where bar=?")
    assert_equal("select ? from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ??? from foo where bar=?")
    assert_equal("select ?'foo' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ???? from foo where bar=?")
    assert_equal("select ?? from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ????? from foo where bar=?")
    assert_equal("select ??'foo' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '?' from foo where bar=?")
    assert_equal("select '?' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '?'? from foo where bar=?")
    assert_equal("select '?''foo' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '?''?' from foo where bar=?")
    assert_equal("select '?''?' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ?'?' from foo where bar=?")
    assert_equal("select 'foo''?' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ?'?'? from foo where bar=?")
    assert_equal("select 'foo''?''foo' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '?'?'? from foo where bar=?")
    assert_equal("select '?''foo'''foo' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '?'?'?' from foo where bar=?")
    assert_equal("select '?''foo''?' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '?'?? from foo where bar=?")
    assert_equal("select '?'? from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '?'??? from foo where bar=?")
    assert_equal("select '?'?'foo' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ??'?'??? from foo where bar=?")
    assert_equal("select ?'?'?'foo' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ???'?'??? from foo where bar=?")
    assert_equal("select ?'foo''?'?'foo' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ''? from foo where bar=?")
    assert_equal("select '''foo' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '''? from foo where bar=?")
    assert_equal("select ''''foo' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ''?' from foo where bar=?")
    assert_equal("select '''foo'' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ''?'' from foo where bar=?")
    assert_equal("select '''foo''' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ''??' from foo where bar=?")
    assert_equal("select ''?' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '?''?' from foo where bar=?")
    assert_equal("select '?''?' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '?'''?' from foo where bar=?")
    assert_equal("select '?''''foo'' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '?''''?' from foo where bar=?")
    assert_equal("select '?''''?' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '??' from foo where bar=?")
    assert_equal("select '??' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select '???' from foo where bar=?")
    assert_equal("select '???' from foo where bar='foo'", ep.quote { |x| "'foo'" })

    ep = Epoxy.new("select ''???' from foo where bar=?")
    assert_equal("select ''?'foo'' from foo where bar='foo'", ep.quote { |x| "'foo'" })
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
                       -- a comment?!
                       select * from foo where bar=?
                       }.strip)

                       assert_equal(%Q{
                       -- a comment?!
                       select * from foo where bar='foo'
                     }.strip, ep.quote { |x| "'foo'" })

                     ep = Epoxy.new(%Q{
                       // a comment?!
                       select * from foo where bar=?
                       }.strip)

                       assert_equal(%Q{
                       // a comment?!
                       select * from foo where bar='foo'
                     }.strip, ep.quote { |x| "'foo'" })

                     ep = Epoxy.new(%Q{
                       # a comment!
                       select * from foo where bar=?
                       }.strip, %r{#})

                       assert_equal(%Q{
                       # a comment!
                       select * from foo where bar='foo'
                     }.strip, ep.quote { |x| "'foo'" })

  end

  def test_06_named_binds
    binds = { 0 => "test", :foo => 'bar', "bar" => 'baz', "void" => 'unused' }
    yarrr = proc { |x| "'#{binds[x] || binds[x.to_s]}'" }

    ep = Epoxy.new("select * from 'foo' where bar=?foo and baz=?bar")
    assert_equal(
      "select * from 'foo' where bar='bar' and baz='baz'", 
      ep.quote(binds, &yarrr)
    )
    
    ep = Epoxy.new("select * from 'foo' where bar='foo ?bar' and baz=?bar")
    assert_equal(
      "select * from 'foo' where bar='foo ?bar' and baz='baz'", 
      ep.quote(binds, &yarrr)
    )

    ep = Epoxy.new("select * from 'foo' where bar=?foo and baz=?")
    assert_equal(
      "select * from 'foo' where bar='bar' and baz='test'",
      ep.quote(binds, &yarrr)
    )

    ep = Epoxy.new("select * from 'foo' where bar='?foo' and baz='?baz'")
    assert_equal(
      "select * from 'foo' where bar='?foo' and baz='?baz'",
      ep.quote(binds, &yarrr)
    )

    ep = Epoxy.new("select * from 'foo' where bar=?foo and baz=?foo")
    assert_equal(
      "select * from 'foo' where bar='bar' and baz='bar'",
      ep.quote(binds, &yarrr)
    )

    ep = Epoxy.new("select * from 'foo' where bar=??")
    assert_equal(
      "select * from 'foo' where bar=?",
      ep.quote(binds, &yarrr)
    )
    
    ep = Epoxy.new("select * from 'foo' where bar=??bar")
    assert_equal(
      "select * from 'foo' where bar=?bar",
      ep.quote(binds, &yarrr)
    )

    ep = Epoxy.new("select * from 'foo' where bar=?notfound")
    assert_equal(
      "select * from 'foo' where bar=?notfound",
      ep.quote(binds, &yarrr)
    )
  end

  def test_07_indexed_binds
    ep = Epoxy.new("select * from foo where bar=?bar and quux=? and foomatic=?foo")
    assert_equal(
      [ :bar, nil, :foo ],
      ep.indexed_binds
    )
  end

  def test_08_meta_blackhole
    str = "select 'some time'::TIMESTAMP"

    ep = Epoxy.new "select 'some time'::TIMESTAMP"

    assert_equal(
      str,
      ep.quote
    )
  end
end

# vim: syntax=ruby ts=2 et sw=2 sts=2
