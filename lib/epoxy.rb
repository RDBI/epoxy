# = Epoxy - bind data to queries for any query language.
# 
# Let me hit ya with some science!
#
#    # numbered binds
#    ep = Epoxy.new("select * from foo where bar=?")
#    binds = %W[foo]
#    bound_query = ep.quote { |x| "'" + binds[x] + "'" }
#    "select * from foo where bar='foo'"
#
#    # named binds
#    binds = { :name => 'Lee', :age => 132 }
#    ep = Epoxy.new("select * from people where name=?name and age=?age")
#    bound_query = ep.quote(binds) { |x| "'#{binds[x]}'" }
#    "select * from people where name='Lee' and age='132'"
#
#    # mix them!
#    binds = { 0 => "Age", :name => 'Lee' }
#    ep = Epoxy.new("select * from people where name=?name and age=?")
#    bound_query = ep.quote(binds) { |x| "'#{binds[x]}'" }
#    "select * from people where name='Lee' and age='Age'"
# 
# Epoxy handles:
# 
# * ?<name> for named binds
# * ? for numbered binds
# * ?? for a *real* question mark
# * '?' for a *real* question mark
# * comments, weird quoting styles (look at the "holy shit" test for examples)
# * not telling you how to quote your data. This solution works for any query language and any database.
#
class Epoxy

  LEGAL_NAMED_BIND = /[a-zA-Z]+/

  #
  # Token parser, isolates components of the query into parts to where they
  # can be managed indepdently.
  #
  # Probably not the easiest thing to deal with by itself. Use the standard
  # methods plox.
  def self.parse_tokens(query, comment_chars)
    query.scan(%r{
      (
        #{comment_chars}.*                  (?# matches "--" style comments to the end of line or string )
        |
        ' ( [^'\\]  |  ''  |  \\. )* '      (?# match strings surrounded by apostophes )
        |
        " ( [^"\\]  |  ""  |  \\. )* "      (?# match strings surrounded by " )
        |
        ['"]                                (?# match a loose quote ) 
        |         
        \?#{LEGAL_NAMED_BIND}               (?# match a named bind )
        |
        \?\??                               (?# match one or two question marks )
        |
        [^'"?]+                          (?# match all characters except ' " ? - : and / )
    )
    }x).collect(&:first)
  end

  # tokens generated by Epoxy.parse_tokens. Just use Epoxy#quote for now.
  attr_reader :tokens
  # the original query, before quoting.
  attr_reader :query
  # leader comment characters - defaults to SQL "--"
  attr_reader :comment_chars

  #
  # Takes a query as a string and an optional regexp defining
  # beginning-of-line comments. The binding rules are as follows:
  #
  # * ?<name> for named binds
  # * ? for numbered binds
  # * ?? for a *real* question mark
  # * '?' for a *real* question mark
  # * comments, weird quoting styles are unaffected.
  #
  def initialize(query, comment_chars=%r{--|//})
    @comment_chars = comment_chars
    @query  = query
    @tokens = self.class.parse_tokens(query, @comment_chars)
  end

  #
  # Processes your query for quoting. Provide a block that emulates how your
  # data should be quoted. This method accepts a Hash to process named bindings,
  # which when provided will yield each successive Hash key which has a match
  # in the named binds. <b>Keys are coerced to symbols before being yielded.</b>
  #
  # Without a Hash it will yield on each successive bound element
  # with the index of that element passed.
  # 
  # *You* are responsible for quoting your data properly. Epoxy just makes it
  # easier to get the places you need to quote out of the query.
  #
  def quote(binds = {}, &block)
    result = ""
    bind_pos = 0

    binds = binds.keys.inject({}) { |x,y| x.merge({ y.kind_of?(String) ? y.to_sym : y => binds[y] }) }

    tokens.each do |part|
      case part
      when '?'
        result << block.call(bind_pos)
        bind_pos += 1
      when '??'
        result << "?"
      when /^\?(#{LEGAL_NAMED_BIND})$/
        key = $1.to_sym
        if binds.has_key?(key)
          result << block.call(key)
          bind_pos += 1
        else
          result << part
        end
      else
        result << part
      end
    end

    return result
  end

  #
  # Returns a hash of position => name (as Symbol), if any, which correspond to
  # binds located in the query. nil is provided as a name if it is an indexed
  # bind already. This is useful for sanitizing features Epoxy has before
  # sending them to the SQL engine.
  #
  # Ex: 
  #   ep = Epoxy.new("select * from foo where bar=?bar and quux=? and foomatic=?foo")
  #   ep.indexed_binds
  #
  #   # yields...
  #   [ :bar, nil, :foo]
  #
  # *NOTE:* all syntax lookalikes are considered in this method; in
  # the actual quote() routine, only named binds with a corresponding map are
  # considered.
  #
  def indexed_binds
    ary = []

    tokens.each do |toke|
      case toke 
      when '?'
        ary.push(toke)
      when /\?(#{LEGAL_NAMED_BIND})/
        ary.push($1.to_sym)
      end
    end

    ary.map! { |x| x == '?' ? nil : x }

    return ary
  end
end

# vim: syntax=ruby ts=2 et sw=2 sts=2
