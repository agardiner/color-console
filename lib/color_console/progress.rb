module Console

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
    def status(msg, opts = {})
        if self.width
            @lock.synchronize do
                if @status_displayed
                    # Clear existing status
                    _clear_line((@status.length / self.width) + 1)
                    @status_displayed = false
                end
                @completed = nil
                @status = msg
                if @status
                    @status_fg = opts.fetch(:text_color, opts.fetch(:color, :cyan))
                    @status_bg = opts[:background_color]
                    _write @status, @status_fg, @status_bg
                    @status_displayed = true
                end
            end
        end
    end
    module_function :status


    # Displays a progress bar as the current status line. The status line is a
    # partial line of text printed at the current scroll location, and which
    # can be updated or cleared.
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
            opts = {total: opts} if opts.is_a?(Numeric)
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


    # Clears any currently displayed progress bar or status message.
    def clear_progress
        self.status nil
    end
    alias_method :clear_status, :clear_progress
    module_function :clear_progress, :clear_status

end
