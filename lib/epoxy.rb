class Epoxy
    def self.parse_tokens(query)
        query.scan(%r{
            (
                -- .*                               (?# matches "--" style comments to the end of line or string )
                |   -                                   (?# matches single "-" )
                |
                /[*] .*? [*]/                       (?# matches C-style comments )
                |   /                                   (?# matches single slash )    
                |
                ' ( [^'\\]  |  ''  |  \\. )* '      (?# match strings surrounded by apostophes )
                |
                " ( [^"\\]  |  ""  |  \\. )* "      (?# match strings surrounded by " )
                |
                \?\??                               (?# match one or two question marks )
                |
                [^-/'"?]+                           (?# match all characters except ' " ? - and / )

            )
        }x).collect(&:first)
    end

    attr_reader :tokens
    attr_reader :query

    def initialize(query)
        @query  = query
        @tokens = self.class.parse_tokens(query) 
    end

    def quote(&block)
        result = ""
        bind_pos = 0

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
