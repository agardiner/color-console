module Console

    FOREGROUND_COLORS = {
        black: '30',
        dark_blue: '2;34',
        blue: '34',
        cyan: '36',
        green: '32',
        light_green: '1;32',
        red: '31',
        light_red: '1;31',
        yellow: '33',
        dark_gray: '2;37',
        light_gray: '37',
        white: '1;37'
    }

    BACKGROUND_COLORS = {
        black: '40',
        dark_blue: '2;44',
        blue: '44',
        cyan: '46',
        green: '42',
        light_green: '1;42',
        red: '41',
        red: '1;41',
        yellow: '43',
        dark_gray: '2;47',
        light_gray: '47',
        white: '1;47'
    }


    # Sets the title bar text of the console window.
    def title=(text)
        STDOUT.write "\e]0;#{text}\007"
    end
    module_function :title=


    # Write a line of text to the console, with optional foreground and
    # background colors.
    #
    # @param text [String] The text to be written to the console.
    # @param fg [Symbol, Integer] An optional foreground colour name or value.
    # @param bg [Symbol, Integer] An optional background color name or value.
    def write(text, fg = nil, bg = nil)
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
    module_function :write


    # Send a line of text to the screen, terminating with a new-line.
    #
    # @see #write
    def puts(text = nil, fg = nil, bg = nil)
        write("#{text}", fg, bg)
        STDOUT.write "\n"
    end
    module_function :puts

end

