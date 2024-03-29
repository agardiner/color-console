require 'color-console'

HEADER_ROW = ['Column 1', 'Column 2', 'Column 3', 'Column 4']
MIXED_ROW = [17,
             'A somewhat longer column',
             'A very very very long column that should wrap multple lines',
             'Another medium length column']
SECOND_ROW = [24,
              'Lorem ipsum',
              'Some more text',
              'Lorem ipsum dolor sit amet']
PARTIAL_ROW = [32, nil, 'Partial row']

Console.send(:_calculate_widths, [HEADER_ROW, MIXED_ROW], 4, 80)
Console.send(:_calculate_widths, [HEADER_ROW, MIXED_ROW], 4, 30)
Console.send(:_calculate_widths, [HEADER_ROW, MIXED_ROW], 4, 20)


Console.puts "---"
Console.display_row(HEADER_ROW, [10, 10, 20, 20])
Console.puts "---"
Console.display_row(MIXED_ROW, [10, 10, 20, 20], indent: 4, col_sep: '|')

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
Console.puts "--- Table with calculated col widths"
Console.display_table([HEADER_ROW, MIXED_ROW])
Console.display_table([HEADER_ROW, MIXED_ROW], col_sep: '|', row_sep: '-')
Console.puts "--- Table with three rows"
Console.display_table([HEADER_ROW, MIXED_ROW, SECOND_ROW], width: 100,
                      col_sep: '|', row_sep: '-', indent: 2)
Console.puts "--- Table with partial data"
Console.display_table([HEADER_ROW, PARTIAL_ROW], col_sep: '|', row_sep: '-')

Console.puts
Console.display_row(['INFO', 'This is an info line'], [12, 60], text_color: :white)
Console.display_row(['DETAIL', 'This is a detail line'], [12, 60], text_color: :light_gray)
Console.display_row(['WARN', 'This is a warn line'], [12, 60], text_color: :yellow)
Console.display_row(['ERROR', 'This is an error line'], [12, 60], text_color: :red)
