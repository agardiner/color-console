if RUBY_ENGINE == 'ruby'
    require_relative 'windows_fiddle'
else
    require_relative 'windows_ffi'
end



module Console

    # Implements functions for interacting with the console under Windows.
    module Windows

        # Retrieve a handle to STDOUT
        def stdout
            @stdout ||= self.get_std_handle(STD_OUTPUT_HANDLE)
        end
        module_function :stdout
        private :stdout


        # Populate a BufferInfo structure with details about the current
        # buffer state.
        #
        # @return [BufferInfo] A BufferInfo structure containing fields for
        #   various bits of console state.
        def get_buffer_info
            if stdout
                self.get_console_screen_buffer_info(stdout, buffer_info)
                @buffer_info
            end
        end
        module_function :get_buffer_info


        # Sets the console foreground and background colors.
        def set_color(color)
            if stdout && color
                self.set_console_text_attribute(stdout, color)
            end
        end
        module_function :set_color


    end


    # Constants for colour components
    BLUE = 0x1
    GREEN = 0x2
    RED = 0x4
    INTENSITY = 0x8

    # Constants for foreground and background colors
    FOREGROUND_COLORS = {
        black: 0,
        blue: BLUE | INTENSITY,
        dark_blue: BLUE,
        light_blue: BLUE | INTENSITY,
        cyan: BLUE | GREEN | INTENSITY,
        green: GREEN,
        dark_green: GREEN,
        light_green: GREEN | INTENSITY,
        red: RED | INTENSITY,
        dark_red: RED,
        light_red: RED | INTENSITY,
        magenta: RED | BLUE,
        dark_magenta: RED | BLUE,
        light_magenta: RED | BLUE | INTENSITY,
        yellow: GREEN | RED | INTENSITY,
        gray: BLUE | GREEN | RED,
        dark_gray: INTENSITY,
        light_gray: BLUE | GREEN | RED,
        white: BLUE | GREEN | RED | INTENSITY
    }
    BACKGROUND_COLORS = {}
    FOREGROUND_COLORS.each{ |k, c| BACKGROUND_COLORS[k] = c << 4 }


    # Sets the title bar text of the console window.
    def title=(text)
        Windows.set_console_title(text)
    end
    module_function :title=


    private


    # Save the reset text and background colors
    buffer = Windows.get_buffer_info
    @reset_colors = buffer && buffer[:text_attributes]


    # Get the current console window size.
    #
    # @return [Array, nil] Returns a two-dimensional array of [cols, rows], or
    #   nil if the console has been redirected.
    def _window_size
        unless @window_size
            buffer = Windows.get_buffer_info
            if buffer
                if buffer[:window_right] > 0 && buffer[:window_bottom] > 0
                    @window_size = [buffer[:window_right] - buffer[:window_left] + 1,
                                    buffer[:window_bottom] - buffer[:window_top] + 1]
                else
                    @window_size = -1
                end
            else
                @window_size = -1
            end
        end
        @window_size == -1 ? nil : @window_size
    end
    module_function :_window_size


    # Write a line of text to the console, with optional foreground and
    # background colors.
    #
    # @param text [String] The text to be written to the console.
    # @param fg [Symbol, Integer] An optional foreground colour name or value.
    # @param bg [Symbol, Integer] An optional background color name or value.
    def _write(text, fg = nil, bg = nil)
        if @status_displayed
            _clear_line (@status.length / self.width) + 1
            @status_displayed = false
        end
        if fg || bg
            reset = @reset_colors
            if fg
                fg_code = FOREGROUND_COLORS[fg] || fg
                unless fg_code >= 0 && fg_code <= 0x0F
                    raise ArgumentError, "Text color must be a recognised symbol or int"
                end
            else
                fg_code = reset & 0x0F
            end

            if bg
                bg_code = BACKGROUND_COLORS[bg] || bg
                unless bg_code >= 0 && bg_code <= 0xF0
                    raise ArgumentError, "Background color must be a recognised symbol or int"
                end
            else
                bg_code = reset & 0xF0
            end
            Windows.set_color(fg_code | bg_code)
        end

        STDOUT.write text

        if reset
            Windows.set_color(reset)
        end
    end
    module_function :_write


    # Send a line of text to the screen, terminating with a new-line.
    #
    # @param text [String] The optional text to be written to the console.
    # @param fg [Symbol, Integer] An optional foreground colour name or value.
    # @param bg [Symbol, Integer] An optional background color name or value.
    def _puts(text = nil, fg = nil, bg = nil)
        if @status_displayed
            _clear_line (@status.length / self.width) + 1
            @status_displayed = false
        end
        buffer = Windows.get_buffer_info
        if buffer && text && text.length > 0 &&
            text.length == (buffer[:window_right] + 1 - buffer[:cursor_x])
            # Text length is same as width of window
            _write("#{text}", fg, bg)
        else
            _write("#{text}\r\n", fg, bg)
        end
        if @status
            _write(@status, @status_fg, @status_bg)
            @status_displayed = true
        end
    end
    module_function :_puts


    # Clears the current line
    def _clear_line(lines = 1)
        raise ArgumentError, "Number of lines to clear (#{lines}) must be > 0" if lines < 1
        buffer = Windows.get_buffer_info
        if buffer
            y = buffer[:cursor_y]
            while lines > 0
                Windows.set_cursor_position(0, y)
                STDOUT.write ' ' * (buffer[:window_right] - buffer[:window_left])
                Windows.set_cursor_position(0, y)
                lines -= 1
                y -= 1
            end
        end
    end
    module_function :_clear_line

end

