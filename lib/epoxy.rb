# = Epoxy - bind data to queries for any query language.
# 
# Let me hit ya with some science!
# 
#     ep = Epoxy.new("select * from foo where bar=?")
#     binds = %W[foo]
#     bound_query = ep.quote { |x| "'" + binds[x] + "'" }
#     "select * from foo where bar='foo'"
# 
# Epoxy handles:
# 
# * ? for numbered binds (named binds coming soon!)
# * ?? for a *real* question mark
# * '?' for a *real* question mark
# * comments, weird quoting styles (look at the "holy shit" test for examples)
# * not telling you how to quote your data. This solution works for any query language and any database.
#
class Epoxy
  #
  # Token parser, isolates components of the query into parts to where they
  # can be managed indepdently.
  #
  # Probably not the easiest thing to deal with by itself. Use the standard
  # methods plox.
  def self.parse_tokens(query, comment_chars)
    a = query.scan(%r{
      (
        #{comment_chars}.*                  (?# matches "--" style comments to the end of line or string )
        |
        ' ( [^'\\]  |  ''  |  \\. )* '      (?# match strings surrounded by apostophes )
        |
        " ( [^"\\]  |  ""  |  \\. )* "      (?# match strings surrounded by " )
        |
        ['"]                                (?# match a loose quote ) 
        |         
        :[a-z]+                             (?# match a named bind )
        |
        \?\??                               (?# match one or two question marks )
        |
        [^-/'"?:]+                          (?# match all characters except ' " ? - : and / )
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
# * ? for numbered binds (named binds coming soon!)
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
# data should be quoted, and it will yield on each successive bound element
# with the index of that element passed.
#
# *You* are responsible for quoting your data properly. Epoxy just makes it
# easier to get the places you need to quote out of the query.
#
def quote(binds = {}, &block)
  result = ""
  bind_pos = 0

  unless binds.empty?
    tokens.each do |token|
      binds.each do |key, rep|
        if token == ":#{key}"
          token.replace block.call(rep)
        end
      end
    end

    return tokens.join
  end

  tokens.each do |part|
    case part
    when '?'
      result << block.call(bind_pos)
      bind_pos += 1
    when '??'
      result << "?"
    else
      result << part
    end
  end

  return result
end
end

# vim: syntax=ruby ts=2 et sw=2 sts=2
