require 'color-console'

HEADER_ROW = ['Column 1', 'Column 2', 'Column 3', 'Column 4']
MIXED_ROW = ['Short col',
             'A somewhat longer column',
             'A very very very long column that should wrap multple lines',
             'Another medium length column']

Console.puts "---"
Console.display_row(HEADER_ROW, [10, 10, 20, 20])
Console.puts "---"
Console.display_row(MIXED_ROW, [10, 10, 20, 20], indent: 8, col_sep: ' | ')
Console.puts "---"
Console.display_table([HEADER_ROW, MIXED_ROW], col_widths: [10, 15, 20, 40],
                      col_sep: '| ', row_sep: '-')

Console.display_row(['INFO', 'This is a log line'], [12, 60], text_color: :white, indent: 0, col_sep: '')
