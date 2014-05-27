require 'color-console'

HEADER_ROW = ['Column 1', 'Column 2', 'Column 3', 'Column 4']
MIXED_ROW = [17,
             'A somewhat longer column',
             'A very very very long column that should wrap multple lines',
             'Another medium length column']

Console.puts "---"
Console.display_row(HEADER_ROW, [10, 10, 20, 20])
Console.puts "---"
Console.display_row(MIXED_ROW, [10, 10, 20, 20], indent: 8, col_sep: '|')

Console.puts "--- Plain table"
Console.display_table([HEADER_ROW, MIXED_ROW], col_widths: [10, 15, 20, 40])
Console.puts "--- Table with row/col separators"
Console.display_table([HEADER_ROW, MIXED_ROW], col_widths: [10, 15, 20, 40],
                      col_sep: '|', row_sep: '-')
Console.puts "--- Table with indent"
Console.display_table([HEADER_ROW, MIXED_ROW], col_widths: [10, 15, 20, 40],
                      col_sep: '|', row_sep: '-', indent: 2)
Console.puts "--- Table with indent and color"
Console.display_table([HEADER_ROW, MIXED_ROW], col_widths: [10, 15, 20, 40],
                      col_sep: '|', row_sep: '-', indent: 2, color: :black, background_color: :white)

Console.puts
Console.display_row(['INFO', 'This is an info line'], [12, 60], text_color: :white)
Console.display_row(['DETAIL', 'This is a detail line'], [12, 60], text_color: :light_gray)
Console.display_row(['WARN', 'This is a warn line'], [12, 60], text_color: :yellow)
Console.display_row(['ERROR', 'This is an error line'], [12, 60], text_color: :red)
