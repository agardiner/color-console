require 'java'
require_relative '../color_console'


# A module for using our color console for log output with the java.util.logging
# log framework.
module Console

    module JavaUtilLogger

        include_package 'java.util.logging'


        # Extends the java.util.ConsoleHandler, adding colorised logging output to
        # the console.
        class ColorConsoleHandler < ConsoleHandler

            def initialize(format = RubyFormatter::DEFAULT_FORMAT)
                super()
                self.formatter = RubyFormatter.new(format)
            end


            # Publishes a log record by outputting it to the console, using an
            # appropriate color for the severity of the log message.
            def publish(log_record)
                msg = formatter.format(log_record)
                case log_record.level
                when JavaUtilLogger::Level::INFO
                    Console.write msg, :white
                when JavaUtilLogger::Level::CONFIG
                    Console.write msg, :cyan
                when JavaUtilLogger::Level::FINE
                    Console.write msg, :light_gray
                when JavaUtilLogger::Level::SEVERE
                    Console.write msg, :red
                when JavaUtilLogger::Level::WARNING
                    Console.write msg, :yellow
                else
                    Console.write msg, :dark_gray
                end
            end

        end


        # Extends java.util.logging.Formatter, adding the ability to customise the
        # log format at runtime, and defaulting to a simpler single-line format more
        # suitable for output to the console.
        class RubyFormatter < Formatter

            # Default format pattern
            DEFAULT_FORMAT  = '%4$-6s  %7$s%5$s'
            # System line-ending
            LINE_END = java.lang.String.format('%n')

            # A format string to use when formatting a log record.
            # @see Java function String.format for the format string syntax. The
            #   values passed by this formatter to String.format are:
            #   - millis  The time the log event occurred
            #   - source  The name of the logger that logged the record
            #   - logger_name The name of the logger that logged the record
            #   - level   The level of the message
            #   - message The log message
            #   - thrown  Any exception that forms part of the log record
            #   - spacer  A spacer that will consist of 2 spaces if the log level
            #       is config or greater.
            attr_accessor :format_string
            # Width at which to split lines
            attr_accessor :width
            # Amount by which to indent lines
            attr_accessor :indent
            # Level labels
            attr_reader :level_labels


            # Constructs a new formatter for formatting log records according to
            # a format string.
            #
            # @param format The format string to use when building a String for
            #   logging.
            def initialize(format = DEFAULT_FORMAT, width = nil)
                super()
                @format_string = format
                @width = width || Console.width
                mark = java.lang.String.format(@format_string, Time.now,
                                               '', '', '', '!$!', nil, nil)
                @indent = mark.lines.first.index('!$!')
                @level_labels = Hash.new{ |h, k| h[k] = k }
                @level_labels[JavaUtilLogger::Level::WARNING] = 'WARN'
                @level_labels[JavaUtilLogger::Level::SEVERE] = 'ERROR'
                @level_labels[JavaUtilLogger::Level::FINEST] = 'DEBUG'
            end


            # Format a log record and return a string for publishing by a log handler.
            def format(log_record)
                lvl = @level_labels[log_record.level]
                indent = @indent || 0
                spacer = ''
                wrap_width = @width - indent
                if log_record.level.intValue < JavaUtilLogger::Level::INFO.intValue
                    spacer = '  '
                    wrap_width -= 2
                end

                msg = wrap_width > 0 ? Console.wrap_text(log_record.message, wrap_width) :
                    [log_record.message]
                sb = java.lang.StringBuilder.new()
                msg.each_with_index do |line, i|
                    if i == 0
                        fmt = java.lang.String.format(@format_string,
                                                      log_record.millis,
                                                      log_record.logger_name,
                                                      log_record.logger_name,
                                                      lvl,
                                                      msg[i],
                                                      log_record.thrown,
                                                      spacer)
                    else
                        fmt = java.lang.String.format(@format_string,
                                                      log_record.millis, '', '', '', msg[i], nil, spacer)
                    end
                    sb.append(fmt)
                    sb.append(LINE_END) if @width < 0 || fmt.length < @width
                end
                sb.toString()
            end

        end

    end


    # Removes any existing console handler, and adds a ColorConsoleHandler.
    #
    # @param options [Hash] An options hash.
    # @option options [String] logger The name of the logger to replace the
    #   handler on. Defaults to an empty string, which returns the root logger.
    # @option options [Level, Symbol] level The level to set the logger to.
    # @option options [String] format A format string for the layout of the log
    #   record.
    def replace_console_logger(options = {})
        logger = options.fetch(:logger, '')
        level = options[:level]
        format = options.fetch(:format, JavaUtilLogger::RubyFormatter::DEFAULT_FORMAT)

        # Remove any existing console handler
        l = Java::JavaUtilLogging::Logger.getLogger(logger)
        l.getHandlers.each do |h|
            l.removeHandler(h) if h.is_a?(Java::JavaUtilLogging::ConsoleHandler)
        end

        # Add a ColorConsoleHandler
        h = JavaUtilLogger::ColorConsoleHandler.new(format)
        if lbls = options[:level_labels]
            h.formatter.level_labels.merge!(lbls)
        end
        l.addHandler(h)

        # Set the log level
        case level
        when Symbol, String
            l.level = Java::JavaUtilLogging::Level.const_get(level.upcase.intern)
        when Java::JavaUtilLogging::Level
            l.level = level
        end
    end
    module_function :replace_console_logger

end

