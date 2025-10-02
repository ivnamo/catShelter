import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        NavigationView {
            Group {
                if let err = store.errorMessage {
                    Text("Error: \(err)")
                        .foregroundColor(.red)
                } else {
                    List(store.cats) { cat in
                        CatRow(cat: cat)
                    }
                }
            }
            .navigationTitle("Adopción de Gatos")
        }
    }
}

struct CatRow: View {
    let cat: Cat
    
    var statusColor: Color {
        switch cat.status {
        case .available: return .green
        case .reserved:  return .orange
        case .adopted:   return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder simple; en app real cargarías la primera foto con AsyncImage
            Circle()
                .fill(statusColor.opacity(0.25))
                .frame(width: 44, height: 44)
                .overlay(Text(String(cat.name.prefix(1))).bold())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(cat.name).font(.headline)
                Text("\(cat.breed) • \(cat.shelter.city)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(cat.status.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

#Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Mocks mínimos para preview
        let shelter = Shelter(name: "Refugio Demo", address: "C/ Demo 1", city: "Madrid", country: "España", latitude: 40.4, longitude: -3.7)
        let cat = Cat(name: "Luna", breed: "European Shorthair", sex: .female, status: .available, colorCategory: .primary, birthdate: nil, intakeDate: Date(), weightKg: 3.5, descriptionText: "Demo", photoURLs: [], tags: ["demo"], shelter: shelter)
        let store = AppStore()
        store.cats = [cat]
        return ContentView().environmentObject(store)
    }
}
