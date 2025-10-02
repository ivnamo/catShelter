# CatsAdoption (Swift Package)

Proyecto portátil para probar el **modelo de datos** de una app de adopción de gatos **sin Mac** (Replit / Linux / Windows).

## Estructura
- `CatsCore` (librería): modelos (`Cat`, `Shelter`, `CatCollection`) + carga de JSON.
- `cats-cli` (ejecutable): utilidades de consola para validar la carga y filtros.

## Requisitos
- Toolchain de Swift (>= 5.7) o Replit con lenguaje Swift.

## Uso rápido
```bash
swift build
swift run cats-cli
swift run cats-cli --tag=kids-friendly
```

El JSON `cats.json` se empaqueta como recurso de `CatsCore` (Bundle.module).
