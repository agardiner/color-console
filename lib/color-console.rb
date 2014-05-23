# Implements cross-platform functionality for working with a console window to
# provide color and progress-bar functionality.
module Console

    if Gem.win_platform?
        require 'platform/windows'
    else
        require 'platform/ansi'
    end


    attr_reader :status, :status_enabled

    @lock = Mutex.new


    # Returns the width of the console window
    #
    # @return The width in characters, or nil if no console is available.
    def width
        sz = window_size
        sz && sz.first
    end
    module_function :width


    # Sets text to be displayed temporarily on the current line. Status text can
    # be updated or cleared.
    #
    # @param status [String] The text to be displayed as the current status.
    #   Pass +nil+ to clear the status display.
    # @params opts [Hash] Options to control the colour of the status display.
    # @option opts [Symbol] :text_color The text color to use when displaying
    #   the status message.
    # @option opts [Symbol] :background_color The background color to use when
    #   rendering the status message
    def status(msg, opts = {})
        if self.width
            if @status
                # Clear existing status
                self.clear_line (@status.length / self.width) + 1
            end
            @lock.synchronize do
                @completed = nil
                @status = msg
                if @status
                    @status_fg = opts.fetch(:text_color, opts.fetch(:color, :cyan))
                    @status_bg = opts[:background_color]
                    self.write @status, @status_fg, @status_bg
                end
            end
        end
    end
    module_function :status


    # Displays a progress bar as the current status line. The status line is a
    # partial line of text printed at the current scroll location, and which
    # can be updated or cleared.
    #
    # @param label [String] The label to be displayed after the progress bar.
    # @param complete [Fixnum] Number of completed steps.
    # @param opts [Fixnum, Hash] If a Fixnum is passed, this is the total number
    #   of steps. If a Hash is passed, it is an options hash with the following
    #   possible options.
    # @option opts [Fixnum] :total The total number of steps; default is 100.
    # @see #status for other supported options
    def show_progress(label, complete, opts = {})
        if self.width
            opts = {total: opts} if opts.is_a?(Fixnum)
            total = opts.fetch(:total, 100)
            complete = total if complete > total
            bar_length = opts.fetch(:bar_length, 40)
            completion = complete * bar_length / total
            pct = "#{complete * 100 / total}%"
            bar = "#{'=' * completion}#{' ' * (bar_length - completion)}"
            bar[(bar_length - pct.length) / 2, pct.length] = pct
            if @completed.nil? || pct != @completed
                self.status("[#{bar}]  #{label}", opts)
                @completed = pct
            end
        end
    end
    module_function :show_progress


    # Clears any currently displayed progress bar or status message.
    def clear_progress
        self.status nil
    end
    alias_method :clear_status, :clear_progress
    module_function :clear_progress, :clear_status


    # Displays an array of arrays as a table of data. The content of each row
    # is aligned and wrapped if necessary to fit the column widths.
    def display_table(rows, opts = {})
        col_count = rows.first.size
        col_widths = opts[:col_widths]

        rows.each do |row|
            display_row(row, col_widths, opts)
        end
    end
    module_function :display_table


    # Displays a single +row+ of data within columns of +widths+ width. If the
    # contents of a cell exceeds the available width, it is wrapped, and the row
    # is displayed over multiple lines.
    def display_row(row, widths, opts = {})
        line_count = 0
        fg = opts.fetch(:text_color, opts.fetch(:color, :cyan))
        bg = opts[:background_color]
        col_sep = opts.fetch(:col_sep, '  ')
        lines = row.each_with_index.map do |col, i|
            cell_lines = wrap_text(col, widths[i])
            line_count = cell_lines.size if cell_lines.size > line_count
            cell_lines
        end
        @lock.synchronize do
            (0...line_count).each do |i|
                write(' ' * opts.fetch(:indent, 2), fg, bg)
                write(opts.fetch(:col_sep, '  '), fg, bg)
                (0...widths.size).each do |col|
                    write("%-#{widths[col]}s" % lines[col][i], fg, bg)
                    write(opts.fetch(:col_sep, '  '), fg, bg)
                end
                write("\n")
            end
            if row_sep = opts[:row_sep]
                sep_row = widths.map{ |width| row_sep * (width + col_sep.length) }
                write(' ' * opts.fetch(:indent, 2), fg, bg)
                write(sep_row.join(''), fg, bg)
                write("\n")
            end
        end
    end
    module_function :display_row


    # Utility method for wrapping lines of +text+ at +width+ characters.
    #
    # @param text [String] a string of text that is to be wrapped to a
    #   maximum width.
    # @param width [Integer] the maximum length of each line of text.
    # @return [Array] an Array of lines of text, each no longer than +width+
    #   characters.
    def wrap_text(text, width)
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

