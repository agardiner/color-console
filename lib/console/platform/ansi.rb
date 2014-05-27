module Console

    FOREGROUND_COLORS = {
        black: '30',
        blue: '34',
        dark_blue: '2;34',
        light_blue: '1;34',
        cyan: '36',
        green: '32',
        dark_green: '2;32',
        light_green: '1;32',
        red: '31',
        dark_red: '2;31',
        light_red: '1;31',
        magenta: '35',
        dark_magenta: '2;35',
        light_magenta: '1;35',
        yellow: '33',
        gray: '37',
        dark_gray: '2;37',
        light_gray: '37',
        white: '1;37'
    }

    BACKGROUND_COLORS = {
        black: '40',
        blue: '44',
        dark_blue: '2;44',
        light_blue: '1;44',
        cyan: '46',
        green: '42',
        dark_green: '2;42',
        light_green: '1;42',
        red: '41',
        dark_red: '2;41',
        light_red: '1;41',
        magenta: '45',
        dark_magenta: '2;45',
        light_magenta: '1;45',
        yellow: '43',
        gray: '47',
        dark_gray: '2;47',
        light_gray: '47',
        white: '1;47'
    }


    # Sets the title bar text of the console window.
    def title=(text)
        STDOUT.write "\e]0;#{text}\007"
    end
    module_function :title=


    private


    # Get the current console window size.
    #
    # @return [Array, nil] Returns a two-dimensional array of [cols, rows], or
    #   nil if the console has been redirected.
    def _window_size
        unless @window_size
            rows = `tput lines`
            cols = `tput cols`
            @window_size = [cols.chomp.to_i, rows.chomp.to_i]
        end
        @window_size
    end
    module_function :_window_size


    # Write a line of text to the console, with optional foreground and
    # background colors.
    #
    # @param text [String] The text to be written to the console.
    # @param fg [Symbol, String] An optional foreground colour name or ANSI code.
    # @param bg [Symbol, String] An optional background color name or ANSI code.
    def _write(text, fg = nil, bg = nil)
        if fg || bg
            reset = true
            if fg
                fg_code = FOREGROUND_COLORS[fg] || fg
                STDOUT.write "\e[#{fg_code}m"
            end

            if bg
                bg_code = BACKGROUND_COLORS[bg] || bg
                STDOUT.write "\e[#{bg_code}m"
            end
        end

        STDOUT.write text

        if reset
            STDOUT.write "\e[0m"
        end
    end
    module_function :_write


    # Send a line of text to the screen, terminating with a new-line.
    #
    # @param text [String] The optional text to be written to the console.
    # @param fg [Symbol, String] An optional foreground colour name or ANSI code.
    # @param bg [Symbol, String] An optional background color name or ANSI code.
    def _puts(text = nil, fg = nil, bg = nil)
        if @status
            _clear_line (@status.length / self.width) + 1
        end
        _write("#{text}", fg, bg)
        STDOUT.write "\n"
        if @status
            _write @status, @status_fg, @status_bg
        end
    end
    module_function :_puts


    # Clears the current +lines+ line(s)
    #
    # @param lines [Fixnum] Number of lines to clear
    def _clear_line(lines = 1)
        raise ArgumentError, "Number of lines to clear (#{lines}) must be > 0" if lines < 1
        while lines > 0
            STDOUT.write "\r\e[2K"
            lines -= 1
            STDOUT.write "\e[A" if lines > 0
        end
    end
    module_function :_clear_line

end

