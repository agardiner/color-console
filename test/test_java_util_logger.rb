require 'java'
require 'color_console/java_util_logger'

Console.replace_console_logger(level: :fine, format: '%4$-6s %5$s%n', level: :finer)


log = Java::JavaUtilLogging::Logger.getLogger('console')
log.info "This is an info message"
log.fine "This is a fine message"
log.finer "This is a finer message"
log.warning "This is a warning message"
log.severe "This is an error message"
log.config "This is a config message"
