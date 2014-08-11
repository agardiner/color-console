GEMSPEC = Gem::Specification.new do |s|
    s.name = "color-console"
    s.version = "0.2"
    s.authors = ["Adam Gardiner"]
    s.date = "2014-08-11"
    s.summary = "ColorConsole is a cross-platform library for outputting colored text to the console"
    s.description = <<-EOQ
        ColorConsole supports cross-platform (ANSI and Windows) colored text output to the console.
        It also provides useful methods for building command-line interfaces that provide status
        messages and progress bars.
    EOQ
    s.email = "adam.b.gardiner@gmail.com"
    s.homepage = 'https://github.com/agardiner/color-console'
    s.require_paths = ['lib']
    s.files = ['README.md', 'LICENSE'] + Dir['lib/**/*.rb']
end
