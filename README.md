# ColorConsole

ColorConsole is a small cross-platform library for outputting color text to the console, as well as providing utilities for drawing progress bars and outputting tabular data.

On Windows, Fiddler (under MRI) or FFI (other engines) is used to dynamically link to the Windows Console API functions, while on other platforms, ANSI escape sequences are used. As such, there are no dependencies and no libraries to install other than this gem.


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

## Features

In addition to `Console.puts` and `Console.write` for outputting text in color, ColorConsole also supports:
* __Setting the console title__: The title bar of the console window can be set using `Console.title = 'My title'`.
* __Status messages__: Status messages (i.e. a line of text at the current scroll position) can be output and
  updated at any time. The status message will remain at the current scroll point even as new text is output
  using `Console.puts`.
* __Progress bars__: A progress bar can be rendered like a status message, but with a pseudo-graphical representation
  of the current completion percentage:

    ```ruby
    (0..100).do |i|
        Console.show_progress('Processing data', i)
    end
    Console.clear_progress
    ```
    Output:
    ```
    [==============    35%                   ]  Processing data
    ```
* __Tables__: Data can be output in a tabular representation:

    ```ruby
    HEADER_ROW = ['Column 1', 'Column 2', 'Column 3', 'Column 4']
    MIXED_ROW = [17,
                 'A somewhat longer column',
                 'A very very very long column that should wrap multple lines',
                 'Another medium length column']
    SECOND_ROW = [24,
                  'Lorem ipsum',
                  'Some more text',
                  'Lorem ipsum dolor sit amet']

    Console.display_table([HEADER_ROW, MIXED_ROW, SECOND_ROW], width: 100,
                          col_sep: '|', row_sep: '-')
    ```
    Output:
    ```
    +----------+--------------------------+-----------------------------+-----------------------------+
    | Column 1 | Column 2                 | Column 3                    | Column 4                    |
    +----------+--------------------------+-----------------------------+-----------------------------+
    |       17 | A somewhat longer column | A very very very long       | Another medium length       |
    |          |                          | column that should wrap     | column                      |
    |          |                          | multple lines               |                             |
    +----------+--------------------------+-----------------------------+-----------------------------+
    |       24 | Lorem ipsum              | Some more text              | Lorem ipsum dolor sit amet  |
    +----------+--------------------------+-----------------------------+-----------------------------+
    ```
* __Color Logging__: If you are using java.util.logging under JRuby, or the Ruby logging library Log4r, you can obtain colour log messages by replacing the console handler with one provided by this gem:
    ```ruby
    # If using Log4r for logging...
    require 'color_console/log4r_logger'
    Console.replace_console_logger(level: :info)

    # Or under JRuby with java.util.logging...
    require 'color_console/java_util_logger'
    Console.replace_console_logger(level: :fine, format: '%4$-6s %5$s%n')
    ```

