import Foundation
import CoreLocation

// MARK: - Enums categorizadores

/// Estado de adopción del gato
enum AdoptionStatus: String, Codable, CaseIterable {
    case available = "available"
    case reserved = "reserved"
    case adopted  = "adopted"
}

/// Sexo del gato
enum Sex: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case unknown = "unknown"
}

/// Color "categoría" para etiquetas/UX
enum ColorCategory: String, Codable, CaseIterable {
    case primary, secondary, success, warning, danger, info, neutral
}

// MARK: - Propiedad: Shelter (Refugio)

/// Refugio (Propiedad del Ítem) con geolocalización y redes
final class Shelter: Codable, Identifiable, CustomStringConvertible {
    let id: UUID
    var name: String
    var address: String
    var city: String
    var country: String
    var latitude: Double
    var longitude: Double
    var website: URL?
    var youtube: URL?
    var instagram: URL?
    
    /// Conveniencia para CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    
    var description: String {
        "Shelter(\(name), \(city), \(country))"
    }
    
    // Inicializador designado
    init(id: UUID = UUID(),
         name: String,
         address: String,
         city: String,
         country: String,
         latitude: Double,
         longitude: Double,
         website: URL? = nil,
         youtube: URL? = nil,
         instagram: URL? = nil) {
        self.id = id
        self.name = name
        self.address = address
        self.city = city
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.website = website
        self.youtube = youtube
        self.instagram = instagram
    }
}

// MARK: - Ítem: Cat (Gato)

/// Gato (Ítem) con propiedades heterogéneas
final class Cat: Codable, Identifiable, CustomStringConvertible {
    let id: UUID
    var name: String
    var breed: String
    var sex: Sex
    var status: AdoptionStatus
    var colorCategory: ColorCategory
    var birthdate: Date?
    var intakeDate: Date // fecha de ingreso al refugio
    var weightKg: Double
    var descriptionText: String
    var photoURLs: [URL] // Array de URLs
    var tags: [String] // Array de Strings
    var shelter: Shelter // Propiedad (objeto)
    
    /// Ejemplo de propiedad computada
    var ageYears: Double? {
        guard let b = birthdate else { return nil }
        let years = Calendar.current.dateComponents([.day], from: b, to: Date()).day ?? 0
        return Double(years) / 365.0
    }
    
    var description: String {
        "Cat(\(name), \(breed), \(sex.rawValue), \(status.rawValue), shelter: \(shelter.name))"
    }
    
    // Inicializador designado
    init(id: UUID = UUID(),
         name: String,
         breed: String,
         sex: Sex,
         status: AdoptionStatus,
         colorCategory: ColorCategory,
         birthdate: Date?,
         intakeDate: Date,
         weightKg: Double,
         descriptionText: String,
         photoURLs: [URL],
         tags: [String],
         shelter: Shelter) {
        self.id = id
        self.name = name
        self.breed = breed
        self.sex = sex
        self.status = status
        self.colorCategory = colorCategory
        self.birthdate = birthdate
        self.intakeDate = intakeDate
        self.weightKg = weightKg
        self.descriptionText = descriptionText
        self.photoURLs = photoURLs
        self.tags = tags
        self.shelter = shelter
    }
    
    // MARK: - Decoding fechas con formato ISO8601
    private enum CodingKeys: String, CodingKey {
        case id, name, breed, sex, status, colorCategory, birthdate, intakeDate, weightKg, descriptionText, photoURLs, tags, shelter
    }
    
    // Para controlar el parseo de fechas ISO8601 opcionales
    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let name = try c.decode(String.self, forKey: .name)
        let breed = try c.decode(String.self, forKey: .breed)
        let sex = try c.decode(Sex.self, forKey: .sex)
        let status = try c.decode(AdoptionStatus.self, forKey: .status)
        let colorCategory = try c.decode(ColorCategory.self, forKey: .colorCategory)
        let weightKg = try c.decode(Double.self, forKey: .weightKg)
        let descriptionText = try c.decode(String.self, forKey: .descriptionText)
        let photoURLs = try c.decode([URL].self, forKey: .photoURLs)
        let tags = try c.decode([String].self, forKey: .tags)
        let shelter = try c.decode(Shelter.self, forKey: .shelter)
        
        let iso = ISO8601DateFormatter()
        var birthdate: Date? = nil
        if let s = try c.decodeIfPresent(String.self, forKey: .birthdate) {
            birthdate = iso.date(from: s)
        }
        let intakeDateString = try c.decode(String.self, forKey: .intakeDate)
        guard let intakeDate = iso.date(from: intakeDateString) else {
            throw DecodingError.dataCorruptedError(forKey: .intakeDate, in: c, debugDescription: "Fecha intakeDate inválida")
        }
        
        self.init(id: id, name: name, breed: breed, sex: sex, status: status, colorCategory: colorCategory, birthdate: birthdate, intakeDate: intakeDate, weightKg: weightKg, descriptionText: descriptionText, photoURLs: photoURLs, tags: tags, shelter: shelter)
    }
}

// MARK: - Colección: CatCollection

/// Colección de gatos con operaciones CRUD y utilidades
final class CatCollection: Codable, CustomStringConvertible {
    private(set) var items: [Cat]
    
    // Inicializador designado
    init(items: [Cat] = []) {
        self.items = items
    }
    
    // Inicializador de conveniencia desde JSON en Data
    convenience init(jsonData: Data) throws {
        let decoder = JSONDecoder()
        let cats = try decoder.decode([Cat].self, from: jsonData)
        self.init(items: cats)
    }
    
    /// Número de ítems
    var count: Int { items.count }
    
    /// Obtener por índice (seguro)
    func item(at index: Int) -> Cat? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }
    
    /// Obtener por id
    func item(with id: UUID) -> Cat? {
        items.first { $0.id == id }
    }
    
    /// Añadir un gato
    func add(_ cat: Cat) {
        items.append(cat)
    }
    
    /// Eliminar por id
    @discardableResult
    func remove(id: UUID) -> Bool {
        if let i = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: i)
            return true
        }
        return false
    }
    
    /// Filtrar por estado de adopción
    func filter(by status: AdoptionStatus) -> [Cat] {
        items.filter { $0.status == status }
    }
    
    /// Filtrar por refugio
    func cats(in shelterId: UUID) -> [Cat] {
        items.filter { $0.shelter.id == shelterId }
    }
    
    /// Ordenar por antigüedad en refugio (más antiguos primero)
    func sortedByIntakeDateAscending() -> [Cat] {
        items.sorted { $0.intakeDate < $1.intakeDate }
    }
    
    var description: String {
        "CatCollection(count: \(count))"
    }
}
