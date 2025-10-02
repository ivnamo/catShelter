import Foundation

public enum DataLoader {
    public static func loadJSON(named name: String) throws -> Data {
        #if SWIFT_PACKAGE
        if let url = Bundle.module.url(forResource: name, withExtension: "json") {
            return try Data(contentsOf: url)
        }
        #endif
        // Fallback: archivo junto al ejecutable
        let path = "./\(name).json"
        if FileManager.default.fileExists(atPath: path) {
            return try Data(contentsOf: URL(fileURLWithPath: path))
        }
        throw NSError(domain: "DataLoader", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "No se encontró \(name).json (ni como recurso de paquete ni en \(path))"])
    }
}
