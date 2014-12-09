require 'log4r'
require_relative '../color_console'


# A module for using our color console for log output with the java.util.logging
# log framework.
module Console

    module Log4rLogger


        # Extends the Log4r StdoutOutputter, adding colorised logging output to
        # the console.
        class ColorConsoleOutputter < Log4r::StdoutOutputter

            def initialize(name, options = {})
                super(name, options)
                @console_width = Console.width || -1
            end


            def format(event)
                @fg = case event.level
                when Log4r::INFO then :white
                when Log4r::WARN then :yellow
                when Log4r::ERROR then :red
                when Log4r::DEBUG then :dark_gray
                else :light_gray
                end

                if event.data
                    begin
                        thread = Log4r::NDC.peek.to_s.upcase[0, 2]
                        level = Log4r::LNAMES[event.level]
                        case
                        when event.data.is_a?(Exception) || event.data.java_kind_of?(java.lang.Throwable)
                            msg = Exception.format(event.data)
                        when event.data.is_a?(Array)
                            msg = event.data
                            case msg.first
                            when String then msg[0] = "%-8s %-2s  %s" % [level, thread, msg[0]]
                            when Array then msg[0][0] = "%-8s %-2s  %s" % [level, thread, msg[0][0]]
                            end
                        else
                            msg = Console.wrap_text(event.data, @console_width - 16)
                            msg = msg.each_with_index.map do |line, i|
                              "%-8s %-2s  %s" % [[level][i], [thread][i], line]
                            end.join("\n")
                        end
                        msg
                    rescue Object => ex
                        "(Unable to format event.data)" # due to #{ex})\n"
                    end
                else
                    ""
                end
            end


            def write(data)
                if data.is_a?(Array)
                    if data[0].is_a?(String) && (data.length == 0 || data[1].is_a?(Symbol))
                        Console.puts *data
                    else
                        data.each do |chunk|
                            Console.write *chunk
                        end
                        Console.puts
                    end
                else
                    Console.puts(data, @fg)
                end
            end

        end

    end


    # Removes any existing console handler, and adds a ColorConsoleHandler.
    #
    # @param options [Hash] An options hash.
    # @option options [String] logger The name of the logger to replace the
    #   handler on. Defaults to nil, which returns the root logger.
    # @option options [Level, Symbol] level The level to set the logger to.
    # @option options [String] format A format string for the layout of the log
    #   record.
    def replace_console_logger(options = {})
        logger = options[:logger]
        name = options.fetch(:outputter, 'color-console')
        level = case options.delete(:level)
        when String, Symbol then Log4r::LNAMES.index(options[:level].to_s.upcase)
        end
        STDOUT.puts level

        # Remove any existing console handler
        log = logger ? Log4r::Logger[logger] : Log4r::Logger.root
        log = Log4r::Logger.new(logger) unless log

        log.outputters.each do |o|
            log.remove(o.name) if h.is_a?(Log4r::StdoutOutputter)
        end

        # Add a ColorConsoleHandler
        out = Log4rLogger::ColorConsoleOutputter.new(name, options)
        log.add out

        # Set the log level
        log.level = level if level
    end
    module_function :replace_console_logger

end
