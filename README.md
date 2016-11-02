# XCPretty PMD Formatter
xcpretty custom formatter for parsing warnings and static analyzer issues easily from "xcodebuild ... clean build analyze" output

[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE.txt)

Custom formatter for [xcpretty](https://github.com/supermarin/xcpretty) that saves on a PMD file all the errors, and warnings, so you can process them easily later.

## More detailed description

### What is the problem which we are solving?
With continuous releases code quality can degrade fast. To help avoiding it, we can manually run Static Analyzer in Xcode or use an another tool for this purpose.
Of course this would take a lot of additional effort so a usually developer would just skip doing it so the number of code inspection issues just gets higher and higher. To help avoiding it, with every Teamcity build we run an analyzer on the given Xcode project and report the results back to Teamcity. Optionally we can even configure Teamcity to fail the build if the number of Code Inspection results gets higher by a given amount.
By applying this solution the number of code inspection issues won't get higher. 


### xcodebuild analyze
This is the official tool which comes with Xcode and available on it's UI as well.
It can run from the command line as well using the "xcodebuild analyze ..." command .
Unfortunately it can generate only HTML and PLIST outputs and Teamcity does not have any plugins for processing these outputs.
Fortunately we have XCPretty to save us. Still : Xcpretty does not have any analyzer reporter built-in. Fortunately it is extensible using the "–formatter ``formatter name or path``" command line attribute and the Ruby language : 

Ref.: [xcpretty](https://github.com/supermarin/xcpretty)
> Extensions
> xcpretty supports custom formatters through the use of the --formatter flag, which takes a path to a file as an argument. The file must contain a Ruby subclass of XCPretty::Formatter, and return that class at the end of the file. The class can override the format_* methods to hook into output parsing events.

So I decided to write a formatter which generates PMD output (like OCLint does for example). (PMD is a really simple XML format for Code Inspection results.)

So the steps for generating a pmd file which contains the static analyzer issues and warnings for a given Xcode project are these : 

```
BUILD_CONFIG_NAME_CAPITAL="Debug" ##See more details about it here on this page later
SIMULATOR_TARGET_DESTINATION=$("$XCODEPATH/usr/bin/xcodebuild" -project "$TEAMCITY_BUILD_CHECKOUTDIR/$SCHEME.xcodeproj" -scheme $SCHEME -configuration "$BUILD_CONFIG_NAME_CAPITAL" -derivedDataPath "$JM_DERIVED_DATA_DIR_DEVICE" PUMPKIN_HOME="$PUMPKIN_HOME" build -destination 'platform=iOS Simulator' 2>&1 >/dev/null | grep id: | head -n 1 | awk '{print $4}' | tr ":" "=" | tr -d ",")

$XCODEPATH/usr/bin/xcodebuild clean analyze -destination "$SIMULATOR_TARGET_DESTINATION" -project "$TEAMCITY_BUILD_CHECKOUTDIR/$SCHEME.xcodeproj" -scheme $SCHEME -configuration "$BUILD_CONFIG_NAME_CAPITAL" -derivedDataPath "$JM_DERIVED_DATA_DIR_DEVICE" ONLY_ACTIVE_ARCH=YES 2>&1 | tee "$LOG_FILE_CODE_INSPECTION_XCODEBUILD_ANALYZE" | XCPRETTY_PMD_FILE_OUTPUT=xcodebuildAnalyzeReport/xcodebuild_analyze_result.pmd xcpretty --formatter `xcpretty-pmd-formatter`
```

Example XCODEPATH value : "/xcode_8/Xcode.app/Contents/Developer"

This generates a PMD file which contains all the Code Inspection results (static analyzer issues + compilations warnings + linker warnings) under "xcodebuildAnalyzeReport/xcodebuild_analyze_result.pmd".

Teamcity can process it : 
You can add a Build Feature for this purpose : here is a screenshot about our configuration : 
![screen shot 2016-10-20 at 18 18 07](https://cloud.githubusercontent.com/assets/7099208/19932729/57526268-a111-11e6-92a4-434595d7823f.png)

Optionally we can even configure Teamcity to fail the build if the number of Code Inspection results gets higher by a given amount : 
You can add a Failure Condition for this purpose : here are two screenshots about our configuration : 
![screen shot 2016-10-20 at 18 19 30](https://cloud.githubusercontent.com/assets/7099208/19932727/5738892e-a111-11e6-9a83-fe7206eb6dc8.png)
![screen shot 2016-10-20 at 18 19 42](https://cloud.githubusercontent.com/assets/7099208/19932728/573953c2-a111-11e6-96cc-d9db35c92698.png)
This makes the build failed in case if it has at least one more Inspection warning or error compared to the latest successful build. (Sidenote : configuring "default units for this metric" and giving "1" as value marked the build as failed only in case if it had at least 2 additional Code Inspection issues. That's the only reason why we use percent based value instead.)

### Reason of using Debug build configuration for generating the Code Inspection results : 
Ref.: [Ref](http://clang-analyzer.llvm.org/scan-build.html#recommendedguidelines)
> ALWAYS analyze a project in its "debug" configuration
> Most projects can be built in a "debug" mode that enables assertions. Assertions are picked up by the static analyzer to prune infeasible paths, which in some cases can greatly reduce the number of false positives (bogus error reports) emitted by the tool."
> Analyze your project in the Debug configuration, either by setting this as your configuration with Xcode or by passing -configuration Debug to xcodebuild."
> Analyze your project using the Simulator as your base SDK. It is possible to analyze your code when targeting the device, but this is much easier to do when using Xcode's Build and Analyze feature."
> Check that your code signing SDK is set to the simulator SDK as well, and make sure this option is set to Don't Code Sign."

### Reason of using "clean" builds for generating the Code Inspection results : 
"xcodebuild analyze" generates reports only for recent code changes for iterative builds in case if you don't run it together with clean.

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
