Lints used in Stage Coding, mostly for GetX architecture.

# Stage lints

## Implementation steps
1. Download (Git (Submodule) Assistant)[https://marketplace.visualstudio.com/items?itemName=ivanhofer.git-assistant] VSCode extension
2. Run `git submodule add https://github.com/StageCoding/stage_lints.git`
3. Add these `pubspec.yaml` *dev* dependencies
```
  custom_lint: ^0.3.4
  stage_lints:
    path: ../stage_lints
```
4. Add this to the bottom of `analysis_options.yaml` file in the project
```
analyzer:
  plugins:
    - custom_lint
```

5. Run `dart run custom_lint`, or restart the VSCode to see the lints in VSCode

More info can be found in (custom_lint)[https://pub.dev/packages/custom_lint] package page
