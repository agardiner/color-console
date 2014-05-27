require 'color-console'

Console.puts "Starting...", :green
(0..100).each do |i|
    Console.show_progress 'Test progress', i
    sleep 0.1
    if i % 10 == 0
        Console.puts "#{i}% complete"
    end
end
Console.clear_progress
Console.puts "Done"

@mut = Mutex.new
@prog = {}

def do_work(tag, tot)
    (0..tot).each do |i|
        sleep rand
        @mut.synchronize do
            @prog[tag] = [i, tot]
            iter, total = @prog.values.reduce([0, 0]){ |s, v| [s[0] + v[0], s[1] + v[1]] }
            Console.puts "Iter: #{iter}, Total: #{total}"
            Console.show_progress "Extracting data...", iter, total
        end
    end
end

Console.puts "Starting multi-threaded...", :green
a = Thread.new{ do_work('A', 15) }
b = Thread.new{ do_work('B', 10) }
a.join
b.join
Console.clear_progress
Console.puts "Done"
