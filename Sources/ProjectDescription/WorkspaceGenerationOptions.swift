extension Workspace {
    /// Generation options allow customizing the generation of the Xcode workspace.
    public struct GenerationOptions: Codable, Equatable {
        /// Contains options for autogenerated workspace schemes
        public enum AutogeneratedWorkspaceSchemes: Codable, Equatable {
            /// Contains options for code coverage
            public enum CodeCoverageMode: Codable, Equatable {
                /// Gather code coverage data for all targets in workspace.
                case all
                /// Enable code coverage for targets that have enabled code coverage in any of schemes in workspace.
                case relevant
                /// Gather code coverage for specified target references.
                case targets([TargetReference])
                /// Do not gather code coverage data.
                case disabled
            }

            /// Tuist will not automatically generate any schemes
            case disabled
            /// Tuist will generate schemes with the associated testing options
            case enabled(
                codeCoverageMode: CodeCoverageMode = .disabled,
                testingOptions: TestingOptions = [],
                testLanguage: SchemeLanguage? = nil,
                testRegion: String? = nil
            )
        }

        /// Enable or disable automatic generation of schemes by Xcode.
        public let enableAutomaticXcodeSchemes: Bool?

        /// Enable or disable automatic generation of `Workspace` schemes. If enabled, options to configure code coverage and test
        /// targets can be passed in via associated values.
        public let autogeneratedWorkspaceSchemes: AutogeneratedWorkspaceSchemes

        /// Allows to suppress warnings in Xcode about updates to recommended settings added in or below the specified Xcode
        /// version. The warnings appear when Xcode version has been upgraded.
        /// It is recommended to set the version option to Xcode's version that is used for development of a project, for example
        /// `.lastXcodeUpgradeCheck(Version(13, 0, 0))` for Xcode 13.0.0.
        public let lastXcodeUpgradeCheck: Version?

        /// Allows to render markdown files inside the workspace including an .xcodesamples.plist inside it.
        public let renderMarkdownReadme: Bool

        public static func options(
            enableAutomaticXcodeSchemes: Bool? = false,
            autogeneratedWorkspaceSchemes: AutogeneratedWorkspaceSchemes = .enabled(),
            lastXcodeUpgradeCheck: Version? = nil,
            renderMarkdownReadme: Bool = false
        ) -> Self {
            GenerationOptions(
                enableAutomaticXcodeSchemes: enableAutomaticXcodeSchemes,
                autogeneratedWorkspaceSchemes: autogeneratedWorkspaceSchemes,
                lastXcodeUpgradeCheck: lastXcodeUpgradeCheck,
                renderMarkdownReadme: renderMarkdownReadme
            )
        }
    }
}
