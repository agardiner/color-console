require 'ffi'


module Console

    # Implements Windows-specific platform functionality
    module Windows

        extend FFI::Library

        # Constants representing STDIN, STDOUT, and STDERR
        STD_OUTPUT_HANDLE = 0xFFFFFFF5
        STD_INPUT_HANDLE = 0xFFFFFFF6
        STD_ERROR_HANDLE = 0xFFFFFFF7


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


        # Retrieve a BufferInfo object
        def buffer_info
            @buffer_info ||= BufferInfo.new
        end
        module_function :buffer_info
        private :buffer_info


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

end

