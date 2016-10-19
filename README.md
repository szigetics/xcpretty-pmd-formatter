# XCPretty PMD Formatter
xcpretty custom formatter for parsing warnings and static analyzer issues easily from "xcodebuild ... clean build analyze" output

[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE.txt)

Custom formatter for [xcpretty](https://github.com/supermarin/xcpretty) that saves on a PMD file all the errors, and warnings, so you can process them easily later.

## Installation

This formatter is distributed via RubyGems, and depends on a version of `xcpretty` >= 0.0.7 (when custom formatters were introduced). Run:

gem install xcpretty-pmd-formatter

## Usage

Specify `xcpretty-pmd-formatter` as a custom formatter to `xcpretty`:

```bash
#!/bin/bash

xcodebuild | xcpretty -f `xcpretty-pmd-formatter`
```

By default, `xcpretty-pmd-formatter` writes the result in `build/reports/errors.pmd`, but you can change that with an environment variable:

```bash
#!/bin/bash

xcodebuild | XCPRETTY_PMD_FILE_OUTPUT=result.pmd xcpretty -f `xcpretty-pmd-formatter`
```

## Output format

You can check some example PMDs in the [fixtures folder](spec/fixtures).

## Thanks

* [Marin Usalj](http://github.com/supermarin) and [Delisa Mason](http://github.com/kattrali) for creating [xcpretty](https://github.com/supermarin/xcpretty).
* [Delisa Mason](http://github.com/kattrali) for creating [xcpretty-travis-formatter](https://github.com/kattrali/xcpretty-travis-formatter), which I used as a guide.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/szigetics/xcpretty-pmd-formatter.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
