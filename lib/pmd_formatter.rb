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
    
    fileNode1 = XML::Node.new('file')
    fileNode1['name'] = 'AppDelegate.m'
    violation1 = XML::Node.new('violation')
    violation1['begincolumn'] = '5'
    violation1['endcolumn'] = '0'
    violation1['beginline'] = '28'
    violation1['endline'] = '0'
    violation1['priority'] = '1'
    violation1['rule'] = 'clang static analyzer'
    violation1['ruleset'] = 'clang static analyzer'
    violation1.content = 'code will never be executed [-Wunreachable-code]'
    fileNode1 << violation1
    doc.root << fileNode1
    
    fileNode2 = XML::Node.new('file')
    fileNode2['name'] = 'BGE/AppDelegate.m'
    violation2 = XML::Node.new('violation')
    violation2['begincolumn'] = '23'
    violation2['endcolumn'] = '0'
    violation2['beginline'] = '20'
    violation2['endline'] = '0'
    violation2['priority'] = '1'
    violation2['rule'] = 'clang static analyzer'
    violation2['ruleset'] = 'clang static analyzer'
    violation2.content = "Potential leak of an object stored into 'key'"
    fileNode2 << violation2
    doc.root << fileNode2
    
    docAsStr = doc.to_s
    # result = docAsStr.gsub(/xml/, 'pmd')
    # doc.save(file_name, :indent => true, :encoding => XML::Encoding::UTF_8)
    File.write(file_name, docAsStr)
  end
end

PMDFormatter
