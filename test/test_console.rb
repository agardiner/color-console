require 'color_console'

Console::FOREGROUND_COLORS.each do |lbl, color|
    Console.puts "This is a #{lbl} line", color
end
Console::BACKGROUND_COLORS.each do |lbl, color|
    Console.puts "This is a white line", :white, color
end

Console.puts "This is some normal text"
Console.puts
Console.puts "This is some red text", :red
Console.puts "This is red text on a blue background", :red, :blue
Console.show_progress "In progress", 35, :color => :green
sleep 3
Console.puts "Here is a new line"
sleep 2
Console.show_progress "In progress", 75, :color => :red
sleep 2
Console.status "Switching to long progress bar"
sleep 2
Console.show_progress "Long progress", 80, :bar_length => 100
sleep 2
Console.status nil

