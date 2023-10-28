module LogRedux
  COLORS = {
    TRACE: "\e[94m",
    DEBUG: "\e[36m",
    INFO: "\e[32m",
    WARN: "\e[33m",
    ERROR: "\e[31m",
    FATAL: "\e[35m",
    GREY: "\e[90m",
    WHITE: "\e[37m",
    RESET: "\e[0m"
  }

  class LoggerError < StandardError; end
end
