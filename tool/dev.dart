import 'dart:async';

import 'package:dart_dev/dart_dev.dart';

Future main(List<String> args) async {
  // Define the entry points for static analysis.
  config.analyze
    ..entryPoints = ['lib/', 'test/']
    ..fatalHints = true
    ..fatalLints = true
    ..fatalWarnings = true
    ..strong = true;

  // Define the directories where the LICENSE should be applied.
  config.copyLicense.directories = ['lib/'];

  // Configure whether or not the HTML coverage report should be generated.
  config.coverage.html = false;

  // Define the directories to include when running the
  // Dart formatter.
  config.format
    ..directories = ['lib/', 'test/', 'tool/']
    ..exclude = ['test/unit/generated_runner_test.dart']
    ..lineLength = 100;

  config.genTestRunner..configs = [new TestRunnerConfig(env: Environment.vm)];

  // Define the location of your test suites.
  config.test
    ..platforms = ['vm']
    ..unitTests = ['test/generated_runner.dart'];

  // Execute the dart_dev tooling.
  await dev(args);
}
