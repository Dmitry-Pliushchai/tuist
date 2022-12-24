import TSCBasic
import TuistSupport

/// The type of modulemap file
public enum ModuleMap: Equatable {
    /// No headers and hence no modulemap file
    case none
    /// Custom modulemap file provided in SPM package
    case custom(AbsolutePath)
    /// Umbrella header provided in SPM package
    case header
    /// Nested umbrella header provided in SPM package
    case nestedHeader
    /// No umbrella header provided in SPM package, define umbrella directory
    case directory(AbsolutePath)

    var path: AbsolutePath? {
        switch self {
        case let .custom(path), let .directory(path):
            return path
        case .none, .header, .nestedHeader:
            return nil
        }
    }

    /// Name of the module map file recognized by the Clang and Swift compilers.
    public static let filename = "module.modulemap"
}

/// Protocol that allows to generate a modulemap for an SPM target.
/// It implements the Swift Package Manager logic
/// [documented here](https://github.com/apple/swift-package-manager/blob/main/Documentation/Usage.md#creating-c-language-targets)
/// and
/// [implemented here](https://github.com/apple/swift-package-manager/blob/main/Sources/PackageLoading/ModuleMapGenerator.swift).
public protocol SwiftPackageManagerModuleMapGenerating {
    func generate(moduleName: String, publicHeadersPath: AbsolutePath) throws -> ModuleMap
}

public final class SwiftPackageManagerModuleMapGenerator: SwiftPackageManagerModuleMapGenerating {
    public init() {}

    public func generate(
        moduleName: String,
        publicHeadersPath: AbsolutePath
    ) throws -> ModuleMap {
        let umbrellaHeaderPath = publicHeadersPath.appending(component: moduleName + ".h")
        let nestedUmbrellaHeaderPath = publicHeadersPath.appending(component: moduleName).appending(component: moduleName + ".h")

        if let customModuleMapPath = try Self.customModuleMapPath(publicHeadersPath: publicHeadersPath) {
            // User defined modulemap exists, use it
            return .custom(customModuleMapPath)
        } else if FileHandler.shared.exists(umbrellaHeaderPath) {
            // If 'PublicHeadersDir/ModuleName.h' exists, then use it as the umbrella header.
            // When umbrella header is present, no need to define a modulemap as it is generated by Xcode
            return .header
        } else if FileHandler.shared.exists(nestedUmbrellaHeaderPath) {
            // If 'PublicHeadersDir/ModuleName/ModuleName.h' exists, then use it as the umbrella header.
            return .nestedHeader
        } else if FileHandler.shared.exists(publicHeadersPath) {
            // Otherwise, consider the public headers folder as umbrella directory
            let sanitizedModuleName = moduleName.replacingOccurrences(of: "-", with: "_")
            let generatedModuleMapContent =
                """
                module \(sanitizedModuleName) {
                    umbrella "\(publicHeadersPath.pathString)"
                    export *
                }

                """
            let generatedModuleMapPath = publicHeadersPath.appending(component: "\(moduleName).modulemap")
            try FileHandler.shared.write(generatedModuleMapContent, path: generatedModuleMapPath, atomically: true)
            return .directory(generatedModuleMapPath)
        } else {
            return .none
        }
    }

    static func customModuleMapPath(publicHeadersPath: AbsolutePath) throws -> AbsolutePath? {
        guard FileHandler.shared.exists(publicHeadersPath) else { return nil }

        let moduleMapPath = RelativePath(ModuleMap.filename)
        let publicHeadersFolderContent = try FileHandler.shared.contentsOfDirectory(publicHeadersPath)

        if publicHeadersFolderContent.contains(publicHeadersPath.appending(moduleMapPath)) {
            return publicHeadersPath.appending(moduleMapPath)
        } else if publicHeadersFolderContent.count == 1,
                  let nestedHeadersPath = publicHeadersFolderContent.first,
                  FileHandler.shared.isFolder(nestedHeadersPath),
                  FileHandler.shared.exists(nestedHeadersPath.appending(moduleMapPath))
        {
            return nestedHeadersPath.appending(moduleMapPath)
        } else {
            return nil
        }
    }
}
