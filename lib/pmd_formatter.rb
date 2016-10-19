require 'fileutils'
require 'xml'

class PMDFormatter < XCPretty::Simple
  FILE_PATH = 'build/reports/errors.pmd'.freeze

  def initialize(use_unicode, colorize)
    super
    @warnings = []
    @ld_warnings = []
    @compile_warnings = []
    @errors = []
    @compile_errors = []
    @file_missing_errors = []
    @undefined_symbols_errors = []
    @duplicate_symbols_errors = []
    @failures = {}
  end

  def format_ld_warning(message)
    @ld_warnings << message
    write_to_file_if_needed
    super
  end

  def format_warning(message)
    @warnings << message
    write_to_file_if_needed
    super
  end

  def format_compile_warning(file_name, file_path, reason, line, cursor)
    @compile_warnings << {
      file_name: file_name,
      file_path: file_path,
      reason: reason,
      line: line,
      cursor: cursor
    }
    write_to_file_if_needed
    super
  end

  def format_error(message)
    @errors << message
    write_to_file_if_needed
    super
  end

  def format_compile_error(file, file_path, reason, line, cursor)
    @compile_errors << {
      file_name: file,
      file_path: file_path,
      reason: reason,
      line: line,
      cursor: cursor
    }
    write_to_file_if_needed
    super
  end

  def format_file_missing_error(reason, file_path)
    @file_missing_errors << {
      file_path: file_path,
      reason: reason
    }
    write_to_file_if_needed
    super
  end

  def format_undefined_symbols(message, symbol, reference)
    @undefined_symbols_errors = {
      message: message,
      symbol: symbol,
      reference: reference
    }
    write_to_file_if_needed
    super
  end

  def format_duplicate_symbols(message, file_paths)
    @duplicate_symbols_errors = {
      message: message,
      file_paths: file_paths
    }
    write_to_file_if_needed
    super
  end

  def format_test_summary(message, failures_per_suite)
    super
  end

  def finish
    write_to_file
    super
  end

  def pmd_output
    {
      warnings: @warnings,
      ld_warnings: @ld_warnings,
      compile_warnings: @compile_warnings,
      errors: @errors,
      compile_errors: @compile_errors,
      file_missing_errors: @file_missing_errors,
      undefined_symbols_errors: @undefined_symbols_errors,
      duplicate_symbols_errors: @duplicate_symbols_errors
    }
  end

  def write_to_file_if_needed
    write_to_file unless XCPretty::Formatter.method_defined? :finish
  end

  def write_to_file
    file_name = ENV['XCPRETTY_PMD_FILE_OUTPUT'] || FILE_PATH
    dirname = File.dirname(file_name)
    FileUtils.mkdir_p dirname

    doc = XML::Document.new
    rootnode = XML::Node.new('pmd')
    rootnode['version'] = 'xcpretty-pmd-formatter'
    doc.root = rootnode

    pmd_output.each do |key1, array|
      unless array.count
        next
      end
      file_node = XML::Node.new('file')
      violation = XML::Node.new('violation')
      array.each do |x|
        x.each do |key, value|
          if key.to_s == 'file_path'
            file_node = XML::Node.new('file')
            file_node['name'] = value.split(':')[0]
            violation = XML::Node.new('violation')
            violation['begincolumn'] = value.split(':')[2]
            violation['endcolumn'] = '0'
            violation['beginline'] = value.split(':')[1]
            violation['endline'] = '0'
          end
          violation['priority'] = '1'
          violation['rule'] = 'clang static analyzer'
          violation['ruleset'] = 'clang static analyzer'
          if key.to_s == 'reason'
            violation.content = value
          end
          has_everything = !violation.parent && violation['begincolumn']
          has_everything &&= violation['endcolumn']
          has_everything &&= violation['beginline'] && violation['endline'] && violation.content
          if has_everything
            file_node << violation
          end
          if file_node['name']
            doc.root << file_node
          end
        end
      end
    end
    doc_as_str = doc.to_s
    # puts doc_as_str
    File.write(file_name, doc_as_str)
  end
end

PMDFormatter
