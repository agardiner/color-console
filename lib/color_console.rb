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
    def status(status, opts = {})
        if self.width
            if @status
                # Clear existing status
                self.clear_line (@status.length / self.width)
            end
            @lock.synchronize do
                @status_fg = opts.fetch(:text_color, opts.fetch(:color, :cyan))
                @status_bg = opts[:background_color]
                @status = status
                @completed = nil
                if @status
                    self.write @status, @status_fg, @status_bg
                end
            end
        end
    end
    module_function :status


    # Displays a progress bar as the current status line.
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

end

puts "Loaded"
