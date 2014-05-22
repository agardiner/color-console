# ColorConsole

ColorConsole is a small cross-platform library for outputting text to the console.


## Usage

ColorConsole is supplied as a gem, and has no dependencies. To use it, simply:
```
gem install color-console
```

ColorConsole provides methods for outputting lines of text in different colors, using the `Console.write` and `Console.puts` functions.

```ruby
require 'color-console'

Console.puts "Some text"                    # Outputs text using the current console colours
Console.puts "Some other text", :red        # Outputs red text with the current background
Console.puts "Yet more text", nil, :blue    # Outputs text using the current foreground and a blue background

# The following lines output BlueRedGreen on a single line, each word in the appropriate color
Console.write "Blue ", :blue
Console.write "Red ", :red
Console.write "Green", :green

```

ColorConsole also supports:
* Status messages: Status messages (i.e. a line of text at the current scroll position) can be output and
  updated at any time. The status message will remain at the current scroll point even as new text is output
  using `Console.puts`.
* Progress bars: A progress bar can be rendered like a status message, but with a pseudo-graphical representation
  of the current completion percentage.

