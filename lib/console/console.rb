# Require the platform specific functionality
if Gem.win_platform?
    require_relative 'platform/windows'
else
    require_relative 'platform/ansi'
end


# Implements cross-platform functionality for working with a console window to
# provide color and progress-bar functionality.
module Console

    attr_reader :status, :status_enabled


    # Mutex used to ensure we don't intermingle output from multiple threads
    @lock = Mutex.new


    # Returns the width of the console window
    #
    # @return the width in characters, or nil if no console is available.
    def width
        sz = _window_size
        sz && sz.first
    end
    module_function :width


    # Returns the height of the console window
    #
    # @return the height in characters, or nil if no console is available.
    def height
        sz = _window_size
        sz && sz.last
    end
    module_function :height


    # Writes a partital line of text to the console, with optional foreground
    # and background colors. No line-feed is output.
    #
    # @see #puts
    #
    # @param text [String] The text to be written to the console.
    # @param fg [Symbol, Integer] An optional foreground colour name or value.
    # @param bg [Symbol, Integer] An optional background color name or value.
    def write(text, fg = nil, bg = nil)
        @lock.synchronize do
            _write(text, fg, bg)
        end
    end
    module_function :write


    # Send a line of text to the screen, terminating with a new-line.
    #
    # @see #write
    def puts(text = nil, fg = nil, bg = nil)
        @lock.synchronize do
            _puts(text, fg, bg)
        end
    end
    module_function :puts



    # Utility method for wrapping lines of +text+ at +width+ characters.
    #
    # @param text [Object] a string of text that is to be wrapped to a
    #   maximum width. If +text+ is not a String, #to_s is called to convert it.
    # @param width [Integer] the maximum length of each line of text.
    # @return [Array] an Array of lines of text, each no longer than +width+
    #   characters.
    def wrap_text(text, width)
        text = text.to_s
        if width > 0 && (text.length > width || text.index("\n"))
            lines = []
            start, nl_pos, ws_pos, wb_pos, end_pos = 0, 0, 0, 0, text.rindex(/[^\s]/)
            while start < end_pos
                last_start = start
                nl_pos = text.index("\n", start)
                ws_pos = text.rindex(/ +/, start + width)
                wb_pos = text.rindex(/[\-,.;#)}\]\/\\]/, start + width - 1)
                ### Debug code ###
                #STDERR.puts self
                #ind = ' ' * end_pos
                #ind[start] = '('
                #ind[start+width < end_pos ? start+width : end_pos] = ']'
                #ind[nl_pos] = 'n' if nl_pos
                #ind[wb_pos] = 'b' if wb_pos
                #ind[ws_pos] = 's' if ws_pos
                #STDERR.puts ind
                ### End debug code ###
                if nl_pos && nl_pos <= start + width
                    lines << text[start...nl_pos].strip
                    start = nl_pos + 1
                elsif end_pos < start + width
                    lines << text[start..end_pos]
                    start = end_pos
                elsif ws_pos && ws_pos > start && ((wb_pos.nil? || ws_pos > wb_pos) ||
                      (wb_pos && wb_pos > 5 && wb_pos - 5 < ws_pos))
                    lines << text[start...ws_pos]
                    start = text.index(/[^\s]/, ws_pos + 1)
                elsif wb_pos && wb_pos > start
                    lines << text[start..wb_pos]
                    start = wb_pos + 1
                else
                    lines << text[start...(start+width)]
                    start += width
                end
                if start <= last_start
                    # Detect an infinite loop, and just return the original text
                    STDERR.puts "Inifinite loop detected at #{__FILE__}:#{__LINE__}"
                    STDERR.puts "  width: #{width}, start: #{start}, nl_pos: #{nl_pos}, " +
                                "ws_pos: #{ws_pos}, wb_pos: #{wb_pos}"
                    return [text]
                end
            end
            lines
        else
            [text]
        end
    end
    module_function :wrap_text

end

require_relative 'progress'
require_relative 'table'

