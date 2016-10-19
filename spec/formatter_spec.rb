require 'spec_helper'
require 'fileutils'
require 'xml'
require 'tmpdir'

describe 'PMDFormatter' do
  it 'formats xcodebuild' do
    verify_file('xcodebuild')
  end

  def verify_file(file)
    output = nil
    Dir.mktmpdir do |dir|
      FileUtils.cp("spec/fixtures/#{file}.log", dir)
      Dir.chdir(dir) do
        %x(cat #{file}.log | XCPRETTY_PMD_FILE_OUTPUT=result.pmd bundle exec xcpretty -f `xcpretty-pmd-formatter`)
        output = XML::Document.file('result.pmd').to_s
      end
    end

    expect(output).to eq pmd_fixture(file)
  end
end
