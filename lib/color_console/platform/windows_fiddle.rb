require 'fiddle'
require 'fiddle/import'


module Console

    # Implements Windows-specific platform functionality when running
    # under MRI. Uses Fiddle, since MRI does not provide FFI functionality
    # as standard, and furthermore requires a Ruby DevKit installation to
    # install the ffi gem. This is a royal pain, so we instead use Fiddle
    # to invoke the Windows console API.
    module Windows

        extend Fiddle::Importer

        dlload 'kernel32.dll'


        # Constant representing STDOUT (0xFFFFFFF5)
        # We can't use this however, as it overflows to a Bignum!
        STD_OUTPUT_HANDLE = -11


        # Wrap the need to call #call on a Fiddle::Function
        def self.attach_function(name, sig)
            func = extern(sig, :stdcall)
            define_singleton_method(name){ |*args| func.call(*args) }
        end


        # FFI structure used to get/set information about the current console
        # window buffer
        BufferInfo = struct([
            'short width',
            'short height',
            'short cursor_x',
            'short cursor_y',
            'short text_attributes',
            'short window_left',
            'short window_top',
            'short window_right',
            'short window_bottom',
            'short max_width',
            'short max_height'
        ])

        class BufferInfo
            def [](name)
                self.send(name)
            end
        end

        attach_function :get_std_handle, 'void* GetStdHandle(int)'
        attach_function :get_console_screen_buffer_info, 'int GetConsoleScreenBufferInfo(*void, *void)'
        attach_function :set_console_cursor_position, 'int SetConsoleCursorPosition(*void, int)'
        attach_function :set_console_text_attribute, 'int SetConsoleTextAttribute(*void, short)'
        attach_function :set_console_title, 'int SetConsoleTitleA(*void)'


        # Retrieve a BufferInfo object
        def buffer_info
            @buffer_info ||= BufferInfo.malloc
        end
        module_function :buffer_info
        private :buffer_info


        # Sets the cursor position to the specified +x+ and +y+ locations in the
        # console output buffer. If +y+ is nil, the cursor is positioned at +x+ on
        # the current line.
        def set_cursor_position(x, y)
            if stdout && x && y
                coord = y << 16 | x
                self.set_console_cursor_position(stdout, coord) == 0
            end
        end
        module_function :set_cursor_position

    end

end

