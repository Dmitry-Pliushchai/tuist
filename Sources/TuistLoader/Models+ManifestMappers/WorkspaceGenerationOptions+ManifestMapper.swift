import Foundation
import ProjectDescription
import TuistGraph

extension TuistGraph.Workspace.GenerationOptions {
    /// Maps ProjectDescription.Workspace.GenerationOptions instance into a TuistGraph.Workspace.GenerationOptions model.
    /// - Parameters:
    ///   - manifest: Manifest representation of a generation option.
    ///   - generatorPaths: Generator paths.
    static func from(
        manifest: ProjectDescription.Workspace.GenerationOptions,
        generatorPaths: GeneratorPaths
    ) throws -> Self {
        .init(
            enableAutomaticXcodeSchemes: manifest.enableAutomaticXcodeSchemes,
            autogeneratedWorkspaceSchemes: try .from(
                manifest: manifest.autogeneratedWorkspaceSchemes,
                generatorPaths: generatorPaths
            ),
            lastXcodeUpgradeCheck: manifest.lastXcodeUpgradeCheck.map { .init($0.major, $0.minor, $0.patch) },
            renderMarkdownReadme: manifest.renderMarkdownReadme
        )
    }
}

extension TuistGraph.Workspace.GenerationOptions.AutogeneratedWorkspaceSchemes {
    static func from(
        manifest: ProjectDescription.Workspace.GenerationOptions.AutogeneratedWorkspaceSchemes,
        generatorPaths: GeneratorPaths
    ) throws -> Self {
        switch manifest {
        case .disabled:
            return .disabled
        case let .enabled(codeCoverageMode, testingOptions, testLanguage, testRegion):
            return .enabled(
                codeCoverageMode: try .from(manifest: codeCoverageMode, generatorPaths: generatorPaths),
                testingOptions: .from(manifest: testingOptions),
                testLanguage: testLanguage?.identifier,
                testRegion: testRegion
            )
        }
    }
}

extension TuistGraph.Workspace.GenerationOptions.AutogeneratedWorkspaceSchemes.CodeCoverageMode {
    static func from(
        manifest: ProjectDescription.Workspace.GenerationOptions.AutogeneratedWorkspaceSchemes.CodeCoverageMode,
        generatorPaths: GeneratorPaths
    ) throws -> Self {
        switch manifest {
        case .all: return .all
        case .relevant: return .relevant
        case let .targets(targets):
            let targets: [TuistGraph.TargetReference] = try targets.map {
                .init(
                    projectPath: try generatorPaths.resolveSchemeActionProjectPath($0.projectPath),
                    name: $0.targetName
                )
            }
            return .targets(targets)
        case .disabled:
            return .disabled
        }
    }
}
