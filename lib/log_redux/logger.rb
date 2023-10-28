require_relative 'logger_helpers'

module LogRedux
  class Logger
    attr_reader :output_filename, :log_file, :history
    attr_accessor :color, :timestamp, :filename, :line_number, :track

    def initialize(output_filename = $stderr, color: true, timestamp: true, filename: true, track: false)
      if output_filename.nil? || (!output_filename.is_a?(String) && !check_valid_stdio(output_filename))
        raise LoggerError, 'invalid log file'
      end

      @output_filename = output_filename
      @color = color
      @timestamp = timestamp
      @filename = filename
      @track = track
      @history = []

      @log_file = check_valid_stdio(output_filename) ? output_filename : File.open(output_filename, 'a+')
    end

    def log(level, msg: nil)
      assert_log_level(level)

      level_str = level.to_s
      time = Time.now.strftime('%H:%M:%S')
      file_line = caller(1).last.split(':')[0..1]
      filename = file_line[0]
      line_number = file_line[1]

      output = if @color
                 [
                   @timestamp ? "#{COLORS[:GREY]}#{time}" : nil,
                   "#{COLORS[level.to_sym]}#{level_str}#{@filename ? '' : ':'}",
                   @filename ? "#{COLORS[:GREY]}#{file_line.join(':')}:" : nil,
                   "#{COLORS[:WHITE]}#{msg}#{COLORS[:RESET]}"
                 ].compact.join(' ')
               else
                 [
                   @timestamp ? "#{time}" : nil,
                   "#{level_str}#{@filename ? '' : ':'}",
                   @filename ? "#{file_line.join(':')}:" : nil,
                   "#{msg}"
                 ].compact.join(' ')
               end

      @log_file.puts output

      save_entry(level, msg, time, filename, line_number, output) if @track

      output
    end

    def trace(msg)
      log(:TRACE, msg: msg)
    end

    def debug(msg)
      log(:DEBUG, msg: msg)
    end

    def info(msg)
      log(:INFO, msg: msg)
    end

    def warn(msg)
      log(:WARN, msg: msg)
    end

    def error(msg)
      log(:ERROR, msg: msg)
    end

    def fatal(msg)
      log(:FATAL, msg: msg)
    end

    def [](index)
      raise LoggerError, 'tracking logs is disabled' unless @track

      @history[index][:formatted]
    end

    def first
      raise LoggerError, 'tracking logs is disabled' unless @track

      @history.first[:formatted]
    end

    def last
      raise LoggerError, 'tracking logs is disabled' unless @track

      @history.last[:formatted]
    end

    def close
      raise LoggerError, 'cannot close a Standard IO file' if check_valid_stdio(@log_file)

      @log_file.close
    end

    private

    def check_valid_stdio(file)
      return true if [$stdout, $stderr].include?(file)

      false
    end

    def assert_log_level(level)
      raise LoggerError, "invalid log level `#{level}`" unless COLORS.keys.include?(level.to_sym)
    end

    def save_entry(level, msg, time, filename, line_number, output)
      @history << {
        level: level,
        time: time,
        filename: filename,
        line: line_number,
        msg: msg,
        formatted: output
      }
    end
  end
end
