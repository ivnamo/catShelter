import Foundation
import CatsCore

do {
    let data = try DataLoader.loadJSON(named: "cats")
    let collection = try CatCollection(jsonData: data)

    print("✅ Colección cargada: \(collection.count) gatos\n")

    // Resumen por estado
    let counts = Dictionary(grouping: collection.items, by: { $0.status })
        .mapValues { $0.count }
    print("📊 Resumen por estado:")
    AdoptionStatus.allCases.forEach { st in
        print("  - \(st.rawValue): \(counts[st, default: 0])")
    }

    // Listar disponibles ordenados por antigüedad (más antiguos primero)
    print("\n🐾 Disponibles (antigüedad):")
    collection.sortedByIntakeDateAscending()
        .filter { $0.status == .available }
        .forEach { cat in
            let df = ISO8601DateFormatter()
            print("  • \(cat.name) — \(cat.breed) — \(cat.shelter.city) — ingreso: \(df.string(from: cat.intakeDate))")
        }

    // Búsqueda simple por tag vía argumento: --tag=kids-friendly
    if let arg = CommandLine.arguments.first(where: { $0.hasPrefix("--tag=") }) {
        let tag = String(arg.dropFirst("--tag=".count))
        let matches = collection.items.filter { $0.tags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) }
        print("\n🔎 Resultado por tag '\(tag)': \(matches.count)")
        matches.forEach { print("  • \($0.name) — tags: \($0.tags.joined(separator: ", "))") }
    }

} catch {
    fputs("❌ Error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
