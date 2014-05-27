require 'ffi'


module Console

    # Implements Windows-specific platform functionality
    module Windows

        extend FFI::Library

        ffi_lib 'kernel32.dll'
        ffi_convention :stdcall


        # FFI structure used to get/set information about the current console
        # window buffer
        class BufferInfo < FFI::Struct
            layout  :width, :short,
                    :height, :short,
                    :cursor_x, :short,
                    :cursor_y, :short,
                    :text_attributes, :ushort,
                    :window_left, :short,
                    :window_top, :short,
                    :window_right, :short,
                    :window_bottom, :short,
                    :max_width, :short,
                    :max_height, :short
        end


        # FFI structure used to get/set buffer co-ordinates
        class Coord < FFI::Struct
            layout  :x, :short,
                    :y, :short

            def initialize(x, y)
                self[:x] = x
                self[:y] = y
            end
        end

        # Define Windows console functions we need
        attach_function :get_std_handle, :GetStdHandle, [:uint], :pointer
        attach_function :get_console_screen_buffer_info, :GetConsoleScreenBufferInfo, [:pointer, :pointer], :bool
        attach_function :set_console_cursor_position, :SetConsoleCursorPosition, [:pointer, Coord.by_value], :bool
        attach_function :set_console_text_attribute, :SetConsoleTextAttribute, [:pointer, :ushort], :bool
        attach_function :set_console_title, :SetConsoleTitleA, [:pointer], :bool


        # Constants representing STDIN, STDOUT, and STDERR
        STD_OUTPUT_HANDLE = 0xFFFFFFF5
        STD_INPUT_HANDLE = 0xFFFFFFF6
        STD_ERROR_HANDLE = 0xFFFFFFF7


        # Retrieve a handle to STDOUT
        def stdout
            @stdout ||= self.get_std_handle(STD_OUTPUT_HANDLE)
        end
        module_function :stdout
        private :stdout


        # Retrieve a BufferInfo object
        def buffer_info
            @buffer_info ||= BufferInfo.new
        end
        module_function :buffer_info
        private :buffer_info


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


        # Sets the cursor position to the specified +x+ and +y+ locations in the
        # console output buffer. If +y+ is nil, the cursor is positioned at +x+ on
        # the current line.
        def set_cursor_position(x, y)
            if stdout && x && y
                coord = Coord.new(x, y)
                self.set_console_cursor_position(stdout, coord)
            end
        end
        module_function :set_cursor_position

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
        if @status
            _clear_line (@status.length / self.width) + 1
        end
        _write("#{text}\r\n", fg, bg)
        if @status
            _write(@status, @status_fg, @status_bg)
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
                STDOUT.write ' ' * (buffer[:window_right] - buffer[:window_left] + 1)
                Windows.set_cursor_position(0, y)
                lines -= 1
                y -= 1
            end
        end
    end
    module_function :_clear_line

end

