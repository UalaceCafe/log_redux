require_relative '../lib/log_redux'

logger = LogRedux::Logger.new('test.log', color: false, timestamp: true, filename: true, track: true)

logger.log(:INFO, msg: 'This is a test message')

logger.trace('trace message')
logger.debug('debug message')
logger.info('info message')
logger.warn('warn message')
logger.error('error message')
logger.fatal('fatal message')

6.times do |i|
  puts logger[i]
end

puts logger.history

logger.close
