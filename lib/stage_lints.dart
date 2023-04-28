// This is the entrypoint of our custom linter
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => StageLinter();

class StageLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        RepositoryAndServicesTopLintRule(),
        RepositoryAndServicesCleanLintRule(),
        RxFinalLintRule(),
      ];
}

bool isRepositoryOrService(String name) =>
    name.contains("Repository") || name.contains("Service");

bool isVariableRepositoryOrService(VariableDeclaration node) {
  final name = node.declaredElement?.type.element?.name;
  return name != null && isRepositoryOrService(name);
}

bool isFieldRepositoryOrService(FieldDeclaration node) => node.fields.variables
    .every((element) => isVariableRepositoryOrService(element));

class RepositoryAndServicesTopLintRule extends DartLintRule {
  static const _code = LintCode(
    name: 'repository_service_beginning',
    problemMessage: 'Place all of your repositories and services at the top',
    errorSeverity: ErrorSeverity.WARNING,
    correctionMessage: "Move the repository or service to the top",
  );

  RepositoryAndServicesTopLintRule() : super(code: _code);

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter,
      CustomLintContext context) {
    context.registry.addFieldDeclaration((node) {
      final children = node.parent?.childEntities.toList();

      if (children == null) return;

      final isRepository = isFieldRepositoryOrService(node);

      if (isRepository &&
          children
              .sublist(0, children.indexOf(node))
              .whereType<FieldDeclaration>()
              .any((element) => !isFieldRepositoryOrService(element))) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}

class RepositoryAndServicesCleanLintRule extends DartLintRule {
  static const _code = LintCode(
    name: 'repository_service_no_explicit',
    problemMessage: 'Declare repositories and services without explicit type',
    errorSeverity: ErrorSeverity.WARNING,
  );

  RepositoryAndServicesCleanLintRule() : super(code: _code);

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter,
      CustomLintContext context) {
    context.registry.addVariableDeclarationList((node) {
      for (final variableDeclaration
          in node.childEntities.whereType<NamedType>()) {
        final isRepository =
            isRepositoryOrService(variableDeclaration.name.name);

        if (isRepository) {
          reporter.reportErrorForNode(code, node);
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        RepositoryAndServicesCleanFix(),
      ];
}

class RepositoryAndServicesCleanFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addNamedType((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
          message: 'Remove explicit type declaration', priority: 0);

      changeBuilder.addDartFileEdit(
          (builder) => builder.addDeletion(node.sourceRange.getMoveEnd(1)));
    });
  }
}

class RxFinalLintRule extends DartLintRule {
  static const _code = LintCode(
    name: 'rx_final',
    problemMessage: 'Rx should be final',
    errorSeverity: ErrorSeverity.WARNING,
  );

  RxFinalLintRule() : super(code: _code);

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter,
      CustomLintContext context) {
    context.registry.addVariableDeclarationList((node) {
      if (node.isFinal) return;

      for (final variable in node.variables) {
        if (variable.declaredElement?.type.element?.name?.startsWith('Rx') ==
            true) {
          reporter.reportErrorForNode(code, node);
        }
      }
    });
  }
}
