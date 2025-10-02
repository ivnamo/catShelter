import Foundation

/// Carga un archivo JSON del bundle y devuelve Data
enum DataLoader {
    static func loadJSON(named name: String, in bundle: Bundle = .main) throws -> Data {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw NSError(domain: "DataLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se encontró \(name).json en el bundle"])
        }
        return try Data(contentsOf: url)
    }
}
