// This is the entrypoint of our custom linter
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => StageLinter();

class StageLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        RepositoryAndServicesLintRule(),
      ];
}

class RepositoryAndServicesLintRule extends DartLintRule {
  static const _code = LintCode(
    name: 'repository_service_beginning',
    problemMessage: 'Place all of your repositories and services at the top',
    errorSeverity: ErrorSeverity.WARNING,
    correctionMessage: "Move the repository or service to the top",
  );

  RepositoryAndServicesLintRule() : super(code: _code);

  bool isRepositoryOrService(SyntacticEntity node) {
    if (node is! VariableDeclaration) return false;
    final name = node.declaredElement?.type.element?.name;
    return name != null &&
        (name.contains("Repository") || name.contains("Service"));
  }

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter,
      CustomLintContext context) {
    context.registry.addVariableDeclaration((node) {
      final children = node.parent?.childEntities.toList();

      if (children == null) return;

      final isRepository = isRepositoryOrService(node);

      if (isRepository &&
          children
              .sublist(0, children.indexOf(node))
              .any((element) => !isRepositoryOrService(element))) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
