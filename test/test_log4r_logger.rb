require 'log4r'
require 'color_console/log4r_logger'


log = Log4r::Logger.new('main')
Console.replace_console_logger(logger: 'main', level: :debug, format: '%4$-6s %5$s%n')

log.info "This is an info message"
log.debug "This is a debug message"
log.warn "This is a warn message"
log.error "This is an error message"
