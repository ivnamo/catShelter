import SwiftUI

@main
struct CatsAdoptionApp: App {
    @StateObject private var store = AppStore()
    
    init() {
        // Demostración por consola de carga + operaciones de la colección
        do {
            let data = try DataLoader.loadJSON(named: "cats")
            let collection = try CatCollection(jsonData: data)
            print("✅ Colección cargada: \(collection)")
            print("Total gatos:", collection.count)
            if let first = collection.item(at: 0) {
                print("Primer gato:", first)
            }
            let disponibles = collection.filter(by: .available)
            print("Disponibles:", disponibles.map(\.name))
        } catch {
            print("❌ Error cargando JSON:", error.localizedDescription)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

/// ViewModel simple para exponer la colección a la UI
final class AppStore: ObservableObject {
    @Published var cats: [Cat] = []
    @Published var errorMessage: String?
    
    init() {
        load()
    }
    
    func load() {
        do {
            let data = try DataLoader.loadJSON(named: "cats")
            let collection = try CatCollection(jsonData: data)
            self.cats = collection.sortedByIntakeDateAscending()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
