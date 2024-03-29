module Console

    # Displays an array of arrays as a table of data. The content of each row
    # is aligned and wrapped if necessary to fit the column widths.
    #
    # @param rows [Array] An array of arrays containing the data to be output.
    #   The number of elements in the first array determines the number of
    #   columns that will be output, unless the :column_widths options is passed;
    #   in that case, the number of column width specifications determines the
    #   number of columns output.
    # @param opts [Hash] An options hash containing settings that determine how
    #   the table is rendered.
    # @options opts [Array<Fixnum>] :col_widths The width to use for each column.
    # @option opts [Fixnum] :width The width of the table. If omitted, the width
    #   is determined instead by the :col_widths option.
    # @options opts [Char] :col_sep The character to use between each column.
    #   If omitted, no column line is drawn. Note though that each column is
    #   rendered with 1 space of padding on the left and right.
    # @options opts [Char] :row_sep The character to use to render a row
    #   separator. If omitted, no row separators are rendered.
    # @options opts [Fixnum] :indent The number of characters to indent the
    #   table from the left margin of the console. If omitted, no indent is
    #   used.
    # @options opts [Symbol] :color The color in which to render the text of the
    #   table.
    # @options opts [Symbol] :text_color The color in which to render the text
    #   of the table.
    # @options opts [Symbol] :background_color The color in which to render the
    #   background of the table.
    def display_table(rows, opts = {})
        return unless rows && rows.size > 0 && rows.first.size > 0
        col_widths = opts[:col_widths]
        unless col_widths
            col_count = rows.first.size
            avail_width = (opts[:width] || ((width || 10000) - opts.fetch(:indent, 0))) -
                (" #{opts[:col_sep]} ".length * col_count) - 1
            avail_width += 3 if opts[:col_sep].to_s.size == 0
            col_widths = _calculate_widths(rows, col_count, avail_width)
        end

        @lock.synchronize do
            _output_row_sep(col_widths, opts) if opts[:row_sep]
            rows.each do |row|
                _display_row(row, col_widths, opts)
            end
        end
    end
    module_function :display_table


    # Displays a single +row+ of data within columns of +widths+ width. If the
    # contents of a cell exceeds the available width, it is wrapped, and the row
    # is displayed over multiple lines.
    #
    # @param row [Array] An array of data to display as a single row.
    # @param widths [Array<Fixnum>] An array of column widths to use for each
    #   column.
    # @param opts [Hash] An options hash containing settings that determine how
    #   the table is rendered.
    # @see #display_table for details of the supported options.
    def display_row(row, widths, opts = {})
        return unless row && row.size > 0
        @lock.synchronize do
            _display_row(row, widths, opts)
        end
    end
    module_function :display_row


    private


    # Calculates the widths to use to display a table of data.
    def _calculate_widths(rows, col_count, avail_width)
        max_widths = Array.new(col_count)
        rows.each do |row|
            row.each_with_index do |col, i|
                max_widths[i] = col.to_s.length if !max_widths[i] || col.to_s.length > max_widths[i]
            end
        end
        max_width = max_widths.reduce(0, &:+)
        while avail_width < max_width
            # Reduce longest width(s) to next longest
            longest = max_widths.max
            num_longest = max_widths.count{ |w| w == longest }
            next_longest = max_widths.select{ |w| w < longest }.max
            if !next_longest || (num_longest * (longest - next_longest) > max_width - avail_width)
                reduction = (max_width - avail_width) / num_longest
                reduction = 1 if reduction <= 0
                if !next_longest
                    max_widths.map!{ |w| w - reduction }
                else
                    max_widths.map!{ |w| w > next_longest ? w - reduction : w }
                end
            else
                max_widths.map!{ |w| w > next_longest ? next_longest : w }
            end
            max_width = max_widths.reduce(0, &:+)
        end
        max_widths
    end
    module_function :_calculate_widths


    # Displays a single +row+ of data within columns of +widths+ width. If the
    # contents of a cell exceeds the available width, it is wrapped, and the row
    # is displayed over multiple lines.
    def _display_row(row, widths, opts = {})
        fg = opts.fetch(:text_color, opts.fetch(:color, :cyan))
        bg = opts[:background_color]
        indent = opts.fetch(:indent, 0)
        col_sep = opts[:col_sep]
        row_sep = opts[:row_sep]

        line_count = 0
        lines = row.each_with_index.map do |col, i|
            cell_lines = wrap_text(col, widths[i])
            line_count = cell_lines.size if cell_lines.size > line_count
            cell_lines
        end
        (0...line_count).each do |i|
            _write(' ' * indent)
            used = indent
            _write("#{col_sep} ", fg, bg) if col_sep
            used += "#{col_sep} ".size if col_sep
            line = (0...widths.size).map do |col|
                "%#{row[col].is_a?(Numeric) ? '' : '-'}#{widths[col]}s" %
                (lines[col] && lines[col][i])
            end.join(" #{col_sep} ")
            _write(line, fg, bg)
            used += line.size
            _write(" #{col_sep}", fg, bg) if col_sep
            used += " #{col_sep}".size if col_sep
            _puts if used != width
        end
        _output_row_sep(widths, opts) if row_sep
    end
    module_function :_display_row


    # Outputs a row separator line
    def _output_row_sep(widths, opts)
        fg = opts.fetch(:text_color, opts.fetch(:color, :cyan))
        bg = opts[:background_color]
        indent = opts.fetch(:indent, 0)
        col_sep = opts[:col_sep]
        row_sep = opts[:row_sep]
        corner = opts.fetch(:corner, col_sep ? '+' * col_sep.length : '')

        sep_row = widths.map{ |width| row_sep * (width + 2) }
        _write(' ' * indent)
        used = indent
        _write(corner, fg, bg)
        used += corner.size
        sep_str = sep_row.join(corner)
        _write(sep_str, fg, bg)
        used += sep_str.size
        _write(corner, fg, bg)
        used += corner.size
        _puts if used != width
    end
    module_function :_output_row_sep

end

