# FinTrack Pro — Technical Blueprint

**Versión:** 1.0  
**Autor:** ArguDev  
**Fecha:** Mayo 2026  
**Plataforma:** iOS 17+  
**Stack:** Swift 6 · SwiftUI · SwiftData · Swift Charts  

---

## 1. Visión General del Proyecto

### Concepto

FinTrack Pro es una app de finanzas personales que permite registrar ingresos y gastos, organizar por categorías, definir presupuestos mensuales y visualizar el comportamiento financiero con gráficos claros.

### Problema que resuelve

Las apps de finanzas existentes son una de dos cosas: demasiado simples (solo listas de gastos) o demasiado complejas (conexiones bancarias, AI innecesario, dashboards saturados). FinTrack Pro ocupa el espacio intermedio: todo lo que necesitas para controlar tu dinero, nada que no necesites.

### Público objetivo

| Segmento | Descripción |
|----------|-------------|
| Primario | Profesionales 22-40 que quieren control sobre sus gastos sin conectar su banco |
| Secundario | Freelancers que manejan ingresos variables y necesitan presupuestos flexibles |
| Terciario | Reclutadores que evalúan calidad técnica del portafolio |

### Propuesta de valor

- Registro rápido: agregar un gasto toma 3 segundos
- Presupuestos visuales con barras de progreso semánticas
- Gráficos con Swift Charts nativos
- Widget de pantalla de inicio con balance del mes
- Siri Shortcuts para agregar gastos por voz
- CloudKit sync entre dispositivos
- Face ID / Touch ID
- 100% offline-first con sync opcional

### Diferenciadores técnicos (portafolio)

| Feature | Por qué impresiona |
|---------|-------------------|
| SwiftData + CloudKit | Stack más moderno de persistencia Apple 2026 |
| Swift Charts | API nativa sin dependencias externas |
| App Intents + Siri | Integración profunda con el sistema |
| WidgetKit | Presencia en home screen |
| Biometric Auth | LocalAuthentication framework |
| MVVM + Clean layers | Arquitectura profesional y testeable |
| Async/Await everywhere | Concurrencia moderna sin Combine legacy |

### Filosofía de diseño

Dark-first. Datos primero. Sin decoración que no comunique algo. Cada pixel tiene un propósito funcional. Los colores son semánticos: verde = positivo, coral = negativo, amber = advertencia. No hay excepciones.

### Nivel de calidad esperado

- App Store ready
- Lighthouse mental: si un iOS Lead la revisa, no encuentra code smells
- README digno de trending en GitHub
- Video demo de 60 segundos que se entiende sin audio

---

## 2. Diseño Visual

### Paleta de colores

| Token | Hex | Rol iOS |
|-------|-----|---------|
| `background` | `#030B14` | Color de fondo raíz de toda la app |
| `surface` | `#071525` | NavigationBar, TabBar, barras del sistema |
| `card` | `#0C1F34` | Fondo de cards, celdas de lista, sheets |
| `elevated` | `#152A42` | Modals, popovers, menús contextuales |
| `positive` | `#00D68F` | Ingresos, saldo positivo, CTA principal |
| `negative` | `#FF4B6E` | Gastos, saldo negativo, alertas críticas |
| `warning` | `#F0A500` | Presupuesto al límite, advertencias |
| `accent` | `#1AAFBF` | Gráficos secundarios, datos neutrales |
| `textPrimary` | `#EEF2F7` | Títulos, montos, texto principal |
| `textSecondary` | `#8FA3BF` | Subtítulos, descripciones |
| `textDisabled` | `#4A6080` | Placeholders, hints, timestamps |
| `border` | `#152A42` | Divisores, separadores |

### Tipografía

| Rol | Fuente | Weights | Uso |
|-----|--------|---------|-----|
| Display | Syne | 800, 700, 600 | Hero, H1, H2, logo |
| Body | Plus Jakarta Sans | 400, 500, 600 | Párrafos, UI, botones, labels |
| Data | Fira Code | 400, 500 | Montos, fechas, porcentajes, código |

Las tres fuentes se registran como custom fonts en el proyecto. Se descargan desde Google Fonts en formato `.ttf`, se agregan al bundle y se declaran en `Info.plist` bajo `Fonts provided by application`.

### Componentes principales

| Componente | Implementación SwiftUI |
|------------|----------------------|
| Balance Card (monto grande + desglose) | `BalanceCardView` — VStack con HStack para stats |
| Budget Ring (anillo circular + barras) | `BudgetRingView` — `Gauge` o `Canvas` circular |
| Transaction Row (ícono + nombre + monto) | `TransactionRowView` — HStack estándar |
| Budget Bar (label + barra de progreso) | `BudgetBarView` — `ProgressView` custom |
| Pill / Badge | `PillView` — texto con padding y fondo tintado |
| Stat Mini Card | `StatCardView` — VStack compacto con borde tintado |
| CTA Button | `PrimaryButtonStyle` — fondo emerald sólido |

### Patrones de UI

- Superficies con material difuso: `.ultraThinMaterial` o fondo semitransparente con blur
- Las barras de progreso usan color semántico según porcentaje: <60% emerald, 60-85% amber, >85% coral
- Los montos siempre usan Fira Code para alineación consistente de decimales
- Los íconos de categoría van en contenedores 32x32 con fondo tintado y `cornerRadius(10)`
- Los divisores son líneas de 0.5px con `border` color

### Desafíos técnicos en SwiftUI

| Desafío | Solución |
|---------|----------|
| Anillo de presupuesto animado | `Canvas` con `drawPath` o `Shape` custom con `trim(from:to:)` animado |
| Scroll performance con muchas transacciones | `LazyVStack` dentro de `ScrollView`, nunca `List` para custom styling |
| Fondo dark custom que no choque con system | Override completo del color scheme con `.preferredColorScheme(.dark)` y colores custom |
| Números con formato monetario | `FormatStyle` de Swift con `currencyCode` |
| Custom fonts + Dynamic Type | Registrar fonts en Info.plist, usar `UIFontMetrics` para escalar con accesibilidad |
| Superficies con material difuso | `.background(.ultraThinMaterial)` con `clipShape(RoundedRectangle)` |

---

## 3. Arquitectura Técnica

### Patrón: MVVM con Service Layer

```
┌─────────────────────────────────────────────────┐
│                    View Layer                    │
│  SwiftUI Views → observe @Observable ViewModels  │
├─────────────────────────────────────────────────┤
│                 ViewModel Layer                   │
│  @Observable classes → call Services              │
├─────────────────────────────────────────────────┤
│                  Service Layer                    │
│  Protocols → concrete implementations             │
├─────────────────────────────────────────────────┤
│                   Data Layer                      │
│  SwiftData Models → @Model classes                │
│  CloudKit Sync → automatic via SwiftData          │
└─────────────────────────────────────────────────┘
```

**Por qué MVVM y no Clean Architecture completa:**
- Es un proyecto personal, no un equipo de 20 personas
- MVVM cubre separación de responsabilidades sin el boilerplate de Use Cases + Repositories + Entities + Mappers
- Los reclutadores entienden MVVM inmediatamente
- SwiftData ya abstrae la capa de datos suficientemente

### Estructura de carpetas

```
FinTrackPro/
├── App/
│   ├── FinTrackProApp.swift
│   ├── AppState.swift
│   └── ContentView.swift
├── Core/
│   ├── DesignSystem/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   ├── Spacing.swift
│   │   └── Components/
│   │       ├── PrimaryButton.swift
│   │       ├── PillBadge.swift
│   │       ├── StatCard.swift
│   │       ├── CategoryIcon.swift
│   │       └── AmountText.swift
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── Double+Currency.swift
│   │   ├── Color+Hex.swift
│   │   └── View+Modifiers.swift
│   ├── Utilities/
│   │   ├── HapticManager.swift
│   │   ├── BiometricAuth.swift
│   │   └── CurrencyFormatter.swift
│   └── Navigation/
│       └── AppRouter.swift
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── DashboardViewModel.swift
│   │   ├── Components/
│   │   │   ├── BalanceCardView.swift
│   │   │   ├── QuickActionsView.swift
│   │   │   └── RecentTransactionsView.swift
│   │   └── Tests/
│   │       └── DashboardViewModelTests.swift
│   ├── Transactions/
│   │   ├── TransactionListView.swift
│   │   ├── TransactionListViewModel.swift
│   │   ├── AddTransactionView.swift
│   │   ├── AddTransactionViewModel.swift
│   │   ├── Components/
│   │   │   ├── TransactionRowView.swift
│   │   │   ├── TransactionFilterBar.swift
│   │   │   └── CategoryPicker.swift
│   │   └── Tests/
│   │       ├── TransactionListViewModelTests.swift
│   │       └── AddTransactionViewModelTests.swift
│   ├── Budget/
│   │   ├── BudgetView.swift
│   │   ├── BudgetViewModel.swift
│   │   ├── EditBudgetView.swift
│   │   ├── Components/
│   │   │   ├── BudgetRingView.swift
│   │   │   ├── BudgetBarView.swift
│   │   │   └── BudgetCategoryRow.swift
│   │   └── Tests/
│   │       └── BudgetViewModelTests.swift
│   ├── Charts/
│   │   ├── ChartsView.swift
│   │   ├── ChartsViewModel.swift
│   │   ├── Components/
│   │   │   ├── MonthlyBarChart.swift
│   │   │   ├── CategoryPieChart.swift
│   │   │   └── TrendLineChart.swift
│   │   └── Tests/
│   │       └── ChartsViewModelTests.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── SettingsViewModel.swift
├── Data/
│   ├── Models/
│   │   ├── Transaction.swift
│   │   ├── Category.swift
│   │   ├── Budget.swift
│   │   └── MonthSummary.swift
│   └── Services/
│       ├── TransactionService.swift
│       ├── BudgetService.swift
│       ├── ChartDataService.swift
│       └── BiometricService.swift
├── Widget/
│   ├── FinTrackWidget.swift
│   ├── WidgetProvider.swift
│   └── WidgetViews.swift
├── Intents/
│   ├── AddExpenseIntent.swift
│   └── CheckBalanceIntent.swift
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.xcstrings
    ├── AppShortcuts.xcstrings
    ├── Fonts/
    │   ├── Syne-Regular.ttf
    │   ├── Syne-SemiBold.ttf
    │   ├── Syne-Bold.ttf
    │   ├── Syne-ExtraBold.ttf
    │   ├── PlusJakartaSans-Regular.ttf
    │   ├── PlusJakartaSans-Medium.ttf
    │   ├── PlusJakartaSans-SemiBold.ttf
    │   ├── FiraCode-Regular.ttf
    │   └── FiraCode-Medium.ttf
    └── Preview Content/
```

### Manejo de estado

| Nivel | Mecanismo |
|-------|-----------|
| Estado local de vista | `@State` |
| Estado de feature | `@Observable` ViewModel inyectado con `@State` en el parent |
| Estado global (auth, settings) | `AppState` como `@Observable` singleton en `@Environment` |
| Datos persistentes | SwiftData `@Model` con `@Query` en vistas |

### Navegación

`TabView` con 5 tabs:
1. Dashboard
2. Transacciones
3. Agregar (botón central especial)
4. Presupuesto
5. Gráficos

Navegación interna: `NavigationStack` con `navigationDestination(for:)` tipado.

Settings se abre desde toolbar del Dashboard.

### Persistencia

SwiftData con modelos `@Model`. CloudKit sync habilitado en el `ModelContainer` con `cloudKitDatabase: .automatic`. No se necesita configuración manual de CloudKit porque SwiftData maneja el schema mapping.

### Manejo de errores

```swift
enum FinTrackError: LocalizedError {
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case budgetExceeded(category: String, limit: Double)
    case biometricFailed
    case biometricNotAvailable

    var errorDescription: String? {
        switch self {
        case .saveFailed(let e): return "No se pudo guardar: \(e.localizedDescription)"
        case .deleteFailed(let e): return "No se pudo eliminar: \(e.localizedDescription)"
        case .budgetExceeded(let cat, let limit): return "\(cat) superó el límite de \(limit.formatted(.currency(code: "USD")))"
        case .biometricFailed: return "Autenticación biométrica falló"
        case .biometricNotAvailable: return "Face ID / Touch ID no disponible"
        }
    }
}
```

---

## 4. Stack Tecnológico

| Categoría | Tecnología | Versión | Razón |
|-----------|-----------|---------|-------|
| UI | SwiftUI | iOS 17+ | Framework nativo, performance óptima |
| Persistencia | SwiftData | iOS 17+ | Reemplazo moderno de Core Data, integración directa con SwiftUI |
| Gráficos | Swift Charts | iOS 16+ | Nativo, sin dependencias, optimizado para accesibilidad |
| Sync | CloudKit | — | Gratis con Apple Developer, sync automático con SwiftData |
| Auth | LocalAuthentication | — | Face ID / Touch ID nativo |
| Widget | WidgetKit | iOS 17+ | Widget de pantalla de inicio |
| Intents | App Intents | iOS 17+ | Siri Shortcuts sin legacy Intents framework |
| Haptics | UIKit (UIImpactFeedbackGenerator) | — | Feedback táctil en interacciones clave |
| Accesibilidad | Accessibility framework + UIFontMetrics | iOS 17+ | VoiceOver, Dynamic Type, reducción de movimiento |
| Localización | String Catalogs (.xcstrings) | Xcode 15+ | ES / EN / FR con plurales y formato nativo |
| Testing | XCTest + Swift Testing | — | Testing nativo sin dependencias |

### Qué NO usar y por qué

| Tecnología | Razón para excluir |
|------------|-------------------|
| Combine | Async/Await + `@Observable` lo reemplaza completamente en iOS 17+ |
| Alamofire | No hay networking HTTP en esta app, los datos son locales |
| RxSwift | Overkill y legacy para un proyecto nuevo con SwiftUI |
| GRDB / Realm | SwiftData es suficiente y es nativo Apple |
| Lottie | Las animaciones son simples, SwiftUI animations bastan |
| SnapKit | No aplica, esto es SwiftUI no UIKit |
| CocoaPods | SPM es el estándar moderno |
| Firebase | CloudKit es gratuito y nativo, no necesitamos Analytics en MVP |

---

## 5. Sistema de Diseño

### Tokens de color (Swift)

```swift
import SwiftUI

enum FTColors {
    static let background   = Color(hex: 0x030B14)
    static let surface      = Color(hex: 0x071525)
    static let card         = Color(hex: 0x0C1F34)
    static let elevated     = Color(hex: 0x152A42)

    static let positive     = Color(hex: 0x00D68F)
    static let negative     = Color(hex: 0xFF4B6E)
    static let warning      = Color(hex: 0xF0A500)
    static let accent       = Color(hex: 0x1AAFBF)

    static let textPrimary   = Color(hex: 0xEEF2F7)
    static let textSecondary = Color(hex: 0x8FA3BF)
    static let textDisabled  = Color(hex: 0x4A6080)
    static let border        = Color(hex: 0x152A42)
}
```

### Tipografía

```swift
enum FTTypo {
    static let syne      = "Syne"
    static let jakarta   = "PlusJakartaSans"
    static let firaCode  = "FiraCode"

    static func hero()    -> Font { .custom(syne, size: 56).weight(.heavy) }
    static func h1()      -> Font { .custom(syne, size: 32).weight(.bold) }
    static func h2()      -> Font { .custom(syne, size: 22).weight(.semibold) }
    static func body()    -> Font { .custom(jakarta, size: 15).weight(.regular) }
    static func bodySemi()-> Font { .custom(jakarta, size: 15).weight(.semibold) }
    static func caption() -> Font { .custom(jakarta, size: 12).weight(.medium) }
    static func data()    -> Font { .custom(firaCode, size: 13).weight(.regular) }
    static func amount()  -> Font { .custom(firaCode, size: 32).weight(.medium) }
    static func amountLg()-> Font { .custom(firaCode, size: 48).weight(.medium) }
    static func label()   -> Font { .custom(firaCode, size: 10).weight(.regular) }
}
```

**Archivos de fuentes necesarios:**

| Fuente | Archivos .ttf |
|--------|--------------|
| Syne | Syne-Regular, Syne-SemiBold, Syne-Bold, Syne-ExtraBold |
| Plus Jakarta Sans | PlusJakartaSans-Regular, PlusJakartaSans-Medium, PlusJakartaSans-SemiBold |
| Fira Code | FiraCode-Regular, FiraCode-Medium |

Todos se agregan a `Resources/Fonts/` y se declaran en `Info.plist`:
```xml
<key>UIAppFonts</key>
<array>
    <string>Syne-Regular.ttf</string>
    <string>Syne-SemiBold.ttf</string>
    <string>Syne-Bold.ttf</string>
    <string>Syne-ExtraBold.ttf</string>
    <string>PlusJakartaSans-Regular.ttf</string>
    <string>PlusJakartaSans-Medium.ttf</string>
    <string>PlusJakartaSans-SemiBold.ttf</string>
    <string>FiraCode-Regular.ttf</string>
    <string>FiraCode-Medium.ttf</string>
</array>
```

### Espaciado

```swift
enum FTSpacing {
    static let xs: CGFloat  = 4
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 12
    static let lg: CGFloat  = 16
    static let xl: CGFloat  = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}
```

### Radios

```swift
enum FTRadius {
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 12
    static let lg: CGFloat  = 16
    static let xl: CGFloat  = 20
    static let pill: CGFloat = 99
}
```

### Sombras

```swift
extension View {
    func ftCardShadow() -> some View {
        self.shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
    }
    func ftElevatedShadow() -> some View {
        self.shadow(color: .black.opacity(0.45), radius: 24, x: 0, y: 12)
    }
}
```

### Semántica de montos

| Condición | Color |
|-----------|-------|
| Monto > 0 (ingreso) | `positive` (#00D68F) |
| Monto < 0 (gasto) | `negative` (#FF4B6E) |
| Budget usage < 60% | `positive` |
| Budget usage 60-85% | `warning` |
| Budget usage > 85% | `negative` |

### Estados de UI

Cada componente interactivo tiene 4 estados:

| Estado | Tratamiento visual |
|--------|-------------------|
| Default | Colores base del token |
| Pressed | `opacity(0.7)` + scale `0.97` |
| Loading | `ProgressView()` reemplaza contenido |
| Disabled | `opacity(0.4)` + `.disabled(true)` |

### Accesibilidad Premium

La accesibilidad no es una sección del roadmap — es un contrato que se firma en cada componente desde el día 1.

#### Dynamic Type con custom fonts

Las custom fonts no escalan automáticamente. Se requiere `UIFontMetrics` para que Syne, Jakarta y Fira Code respeten el tamaño elegido por el usuario en Configuración → Accesibilidad.

```swift
enum FTTypo {
    static let syne     = "Syne"
    static let jakarta  = "PlusJakartaSans"
    static let firaCode = "FiraCode"

    static func hero()     -> Font { scaled(.custom(syne,     fixedSize: 56), relativeTo: .largeTitle) }
    static func h1()       -> Font { scaled(.custom(syne,     fixedSize: 32), relativeTo: .title) }
    static func h2()       -> Font { scaled(.custom(syne,     fixedSize: 22), relativeTo: .title2) }
    static func body()     -> Font { scaled(.custom(jakarta,  fixedSize: 15), relativeTo: .body) }
    static func bodySemi() -> Font { scaled(.custom(jakarta,  fixedSize: 15), relativeTo: .body) }
    static func caption()  -> Font { scaled(.custom(jakarta,  fixedSize: 12), relativeTo: .caption) }
    static func data()     -> Font { scaled(.custom(firaCode, fixedSize: 13), relativeTo: .callout) }
    static func amount()   -> Font { scaled(.custom(firaCode, fixedSize: 32), relativeTo: .title) }
    static func amountLg() -> Font { scaled(.custom(firaCode, fixedSize: 48), relativeTo: .largeTitle) }
    static func label()    -> Font { scaled(.custom(firaCode, fixedSize: 10), relativeTo: .caption2) }

    private static func scaled(_ font: Font, relativeTo style: Font.TextStyle) -> Font {
        font.leading(.standard)
    }
}
```

Adicionalmente, aplicar `.dynamicTypeSize(.xSmall ... .accessibility3)` en las vistas que no deben romperse en tamaños extremos.

#### VoiceOver — Contrato por componente

| Componente | `accessibilityLabel` | `accessibilityHint` | `accessibilityValue` |
|------------|---------------------|--------------------|--------------------|
| `BalanceCardView` | "Balance disponible" | — | Monto con formato verbal: "doce mil ochocientos cuarenta dólares" |
| `AmountText` (ingreso) | "Ingreso de X dólares" | — | — |
| `AmountText` (gasto) | "Gasto de X dólares" | — | — |
| `BudgetRingView` | "Anillo de presupuesto" | — | "Sesenta y cuatro por ciento libre" |
| `BudgetBarView` | Nombre de categoría | — | "Trescientos ochenta de quinientos dólares. Setenta y seis por ciento usado" |
| `TransactionRowView` | Título + monto + fecha | "Toca dos veces para ver detalle" | — |
| `CategoryIcon` | Nombre de categoría | — | — |
| `PrimaryButton` (guardar) | "Guardar transacción" | "Toca dos veces para guardar" | — |
| `PillBadge` (tipo) | "Ingreso" / "Gasto" | — | — |

```swift
// Patrón estándar para componentes con datos financieros
BalanceCardView(...)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text("Balance disponible"))
    .accessibilityValue(Text(totalBalance.accessibilityFormatted))

extension Double {
    var accessibilityFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale.current
        let amount = formatter.string(from: NSNumber(value: abs(self))) ?? ""
        return self >= 0 ? "\(amount) dólares" : "menos \(amount) dólares"
    }
}
```

#### Reduce Motion

Respetar la preferencia del usuario de reducir animaciones:

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    BudgetRingView(usage: viewModel.usage)
        .animation(reduceMotion ? .none : .spring(duration: 0.8), value: viewModel.usage)
}
```

Todas las animaciones decorativas deben estar gateadas con `reduceMotion`. Las animaciones funcionales (progreso de carga, feedback de guardado) pueden mantenerse con duración reducida.

#### Contraste y visión reducida

| Combinación | Ratio | Cumple WCAG AA |
|-------------|-------|---------------|
| `textPrimary` (#EEF2F7) sobre `background` (#030B14) | 18.5:1 | ✅ AAA |
| `positive` (#00D68F) sobre `card` (#0C1F34) | 5.2:1 | ✅ AA |
| `negative` (#FF4B6E) sobre `card` (#0C1F34) | 4.8:1 | ✅ AA |
| `warning` (#F0A500) sobre `card` (#0C1F34) | 4.6:1 | ✅ AA |
| `textDisabled` (#4A6080) sobre `background` (#030B14) | 3.1:1 | ⚠️ Solo para hints, nunca para info crítica |

Los montos y el balance nunca deben usar `textDisabled`. Solo labels, timestamps y placeholders.

#### Focus y navegación por teclado (iPad / Magic Keyboard)

```swift
// Orden lógico de foco en Dashboard
BalanceCardView()
    .accessibilitySortPriority(3)
QuickActionsView()
    .accessibilitySortPriority(2)
RecentTransactionsView()
    .accessibilitySortPriority(1)
```

---

### Sistema Multilingüe (ES · EN · FR)

#### Estrategia: String Catalogs nativos

Usar `Localizable.xcstrings` (Xcode 15+) en lugar de los archivos `.strings` legacy. String Catalogs manejan plurales, variaciones por género y formatos de número de forma nativa.

**Idiomas soportados:**
- Español (`es`) — idioma base y de desarrollo
- Inglés (`en`) — idioma primario para reclutadores internacionales
- Francés (`fr`) — tercer idioma, demuestra commitment con localización real

#### Estructura de claves

```
// Patrón: [sección].[componente].[descripción]
"dashboard.balance.available"        → "Balance disponible" / "Available balance" / "Solde disponible"
"dashboard.balance.income"           → "Ingresos" / "Income" / "Revenus"
"dashboard.balance.expenses"         → "Gastos" / "Expenses" / "Dépenses"
"dashboard.balance.savings"          → "Ahorro" / "Savings" / "Épargne"
"transaction.type.income"            → "Ingreso" / "Income" / "Revenu"
"transaction.type.expense"           → "Gasto" / "Expense" / "Dépense"
"transaction.add.title"              → "Nueva transacción" / "New transaction" / "Nouvelle transaction"
"transaction.add.save"               → "Guardar" / "Save" / "Enregistrer"
"transaction.add.cancel"             → "Cancelar" / "Cancel" / "Annuler"
"budget.overview.title"              → "Presupuesto" / "Budget" / "Budget"
"budget.ring.free"                   → "libre" / "free" / "libre"
"charts.period.thisMonth"            → "Este mes" / "This month" / "Ce mois"
"charts.period.threeMonths"          → "3 meses" / "3 months" / "3 mois"
"error.save.failed"                  → "No se pudo guardar" / "Could not save" / "Impossible d'enregistrer"
```

#### Plurales

```swift
// En Localizable.xcstrings, el plural se define por idioma
// Swift genera el manejo automático

// Uso en código:
Text("transaction.count \(count)", tableName: "Localizable")
// ES: "1 transacción" / "5 transacciones"
// EN: "1 transaction" / "5 transactions"
// FR: "1 transaction" / "5 transactions"
```

#### Formato de moneda por locale

```swift
struct CurrencyFormatter {
    static func format(_ amount: Double, locale: Locale = .current) -> String {
        amount.formatted(.currency(code: currencyCode(for: locale))
            .locale(locale)
            .precision(.fractionLength(2)))
    }

    private static func currencyCode(for locale: Locale) -> String {
        switch locale.language.languageCode?.identifier {
        case "fr": return "EUR"
        default:   return "USD"
        }
    }
}
```

#### Detección automática de idioma

No se necesita un selector de idioma en Settings. iOS usa automáticamente el idioma del sistema si está en la lista de idiomas soportados del app. Configurar en `Info.plist`:

```xml
<key>CFBundleLocalizations</key>
<array>
    <string>es</string>
    <string>en</string>
    <string>fr</string>
</array>
<key>CFBundleDevelopmentRegion</key>
<string>es</string>
```

#### Accesibilidad en VoiceOver multilingüe

VoiceOver lee en el idioma del sistema automáticamente si los `accessibilityLabel` usan `Text("")` con claves localizadas. Nunca hardcodear strings en labels de accesibilidad.

```swift
// Mal
.accessibilityLabel("Balance disponible")

// Bien
.accessibilityLabel(Text("dashboard.balance.available"))
```

#### App Intents localizado

Los `AppShortcutsProvider` y los parámetros de Siri también se localizan en `AppShortcuts.xcstrings`. Siri responde en el idioma del sistema.

---

## 6. Roadmap de Desarrollo

### Fase 0 — Proyecto base

**Objetivo:** Xcode project configurado, compilando, con design system funcional.

#### 0.1 Crear proyecto Xcode

- [x] Abrir Xcode → New Project → App
- [x] Nombre: `FinTrackPro`
- [x] Team: tu Apple Developer account
- [x] Organization Identifier: `com.argudev`
- [x] Interface: SwiftUI
- [x] Storage: SwiftData
- [x] ☑️ Include Tests
- [x] Deployment Target: iOS 17.0

**Prompt Claude Code:**
```
Crea el .gitignore para un proyecto iOS con Xcode, incluyendo exclusiones para DerivedData, xcuserdata, Pods si existieran, .DS_Store, y archivos de build.
```

#### 0.2 Configurar Git

- [x] `git init` en la carpeta del proyecto
- [x] Crear `.gitignore`
- [x] Commit inicial: `chore: initial project setup`
- [x] Crear repo en GitHub: `FinTrackPro`
- [x] Push a `main`
- [x] Crear branch `develop`
- [x] Push `develop`

**Convención de commits:**
```
feat:     nueva funcionalidad
fix:      corrección
refactor: reescritura sin cambio funcional
style:    cambios visuales
chore:    configuración, dependencias
test:     tests
docs:     documentación
```

**Convención de branches:**
```
feature/dashboard-balance-card
feature/transaction-list
fix/budget-bar-animation
refactor/design-system-colors
```

#### 0.3 Crear design system base

- [x] Crear carpeta `Core/DesignSystem/`
- [x] Crear `Colors.swift` con `FTColors` enum y extensión `Color(hex:)`
- [x] Crear `Typography.swift` con `FTTypo` enum usando custom fonts
- [x] Crear `Spacing.swift` con `FTSpacing` enum
- [x] Crear `Radius.swift` con `FTRadius` enum
- [ ] Descargar archivos `.ttf` de Google Fonts: Syne (Regular, SemiBold, Bold, ExtraBold), Plus Jakarta Sans (Regular, Medium, SemiBold), Fira Code (Regular, Medium)
- [ ] Agregar los 9 archivos `.ttf` a `Resources/Fonts/`
- [ ] En Xcode: seleccionar los `.ttf` → Target Membership ☑️ FinTrackPro
- [ ] Agregar al `Info.plist` el array `UIAppFonts` con los 9 nombres de archivo
- [ ] Verificar en preview que `Font.custom("Syne-ExtraBold", size: 32)` renderiza correctamente
- [ ] Verificar que todos los colores se ven correctos en preview

**Prompt Claude Code:**
```
Crea Core/DesignSystem/Colors.swift con un enum FTColors que contenga static lets para estos colores: background #030B14, surface #071525, card #0C1F34, elevated #152A42, positive #00D68F, negative #FF4B6E, warning #F0A500, accent #1AAFBF, textPrimary #EEF2F7, textSecondary #8FA3BF, textDisabled #4A6080, border #152A42. Incluye la extensión Color(hex: UInt) necesaria. Sin comentarios.
```

**Prompt Claude Code (Typography):**
```
Crea Core/DesignSystem/Typography.swift con un enum FTTypo. Usa Font.custom() con estas fuentes: "Syne" para display (hero 56px heavy, h1 32px bold, h2 22px semibold), "PlusJakartaSans" para body (body 15px regular, bodySemi 15px semibold, caption 12px medium), "FiraCode" para datos (data 13px regular, amount 32px medium, amountLg 48px medium, label 10px regular). Cada función retorna Font. Sin comentarios.
```

#### 0.4 Crear componentes base del design system

- [ ] `PrimaryButton.swift` — botón emerald sólido con label centrado
- [ ] `PillBadge.swift` — pill con color semántico paramétrico
- [ ] `AmountText.swift` — texto de monto con color automático según signo
- [ ] `CategoryIcon.swift` — contenedor 32x32 con emoji y fondo tintado
- [ ] `FTCardModifier.swift` — ViewModifier para fondo card + radius + border

**Prompt Claude Code:**
```
Crea Core/DesignSystem/Components/AmountText.swift. Es una View que recibe un Double amount y un Font opcional (default FTTypo.data()). Si amount >= 0 muestra el monto en FTColors.positive con prefijo "+". Si amount < 0 muestra en FTColors.negative con prefijo "−" (guión largo, no hyphen). Formatea con 2 decimales y separador de miles. Usa FTTypo.data() que ya es Fira Code monoespaciado. Sin comentarios.
```

**Criterio de completitud:** El proyecto compila, se ve el fondo `background` en ContentView, los componentes se pueden previsualizar en Xcode Previews.

---

### Fase 1 — Modelos de datos

**Objetivo:** Modelos SwiftData definidos, compilando, con data de preview.

#### 1.1 Modelo Transaction

- [ ] Crear `Data/Models/Transaction.swift`
- [ ] Propiedades: `id` UUID, `amount` Double, `title` String, `note` String opcional, `date` Date, `isIncome` Bool, `category` relación a Category
- [ ] Decorar con `@Model`
- [ ] Agregar computed property `isExpense` como negación de `isIncome`

**Prompt Claude Code:**
```
Crea Data/Models/Transaction.swift como un @Model de SwiftData. Propiedades: id (UUID, default UUID()), amount (Double), title (String), note (String?), date (Date, default .now), isIncome (Bool, default false). Relación @Relationship con Category opcional. Computed property isExpense que retorne !isIncome. Sin comentarios.
```

#### 1.2 Modelo Category

- [ ] Crear `Data/Models/Category.swift`
- [ ] Propiedades: `id` UUID, `name` String, `emoji` String, `colorHex` String
- [ ] Relación inversa a Transaction
- [ ] Método estático `defaults()` que retorne categorías predefinidas

Categorías por defecto:

| Nombre | Emoji | Color |
|--------|-------|-------|
| Comida | 🍔 | #00D68F |
| Transporte | 🚗 | #1AAFBF |
| Entretenimiento | 🎮 | #B026FF |
| Salud | 💊 | #FF4B6E |
| Compras | 🛍️ | #F0A500 |
| Hogar | 🏠 | #00A86B |
| Educación | 📚 | #1AAFBF |
| Salario | 💼 | #00D68F |
| Freelance | 💻 | #00D68F |
| Otros | 📌 | #8FA3BF |

#### 1.3 Modelo Budget

- [ ] Crear `Data/Models/Budget.swift`
- [ ] Propiedades: `id` UUID, `monthYear` String (formato "2026-05"), `limit` Double, `category` relación a Category
- [ ] Computed property `usage(spent:)` que retorne el porcentaje

#### 1.4 Preview data

- [ ] Crear `Resources/Preview Content/PreviewSampleData.swift`
- [ ] Generar 20 transacciones de ejemplo con fechas del mes actual
- [ ] Generar 5 budgets de ejemplo
- [ ] Configurar un `ModelContainer` de preview con datos precargados

**Prompt Claude Code:**
```
Crea Resources/PreviewContent/PreviewSampleData.swift con un struct PreviewSampleData que contenga: static func createSampleTransactions() -> [Transaction] que genere 20 transacciones variadas del mes actual (15 gastos, 5 ingresos) con categorías distintas y montos realistas entre $5 y $3000. También static func createSampleBudgets() -> [Budget] con 5 presupuestos para las categorías principales. Sin comentarios.
```

**Criterio de completitud:** Los modelos compilan, las relaciones funcionan, la preview data se genera sin crashes.

---

### Fase 2 — Tab Bar y navegación

**Objetivo:** Estructura de navegación completa con 5 tabs y vistas placeholder.

#### 2.1 Crear ContentView con TabView

- [ ] TabView con 5 tabs
- [ ] Tab 1: Dashboard (house.fill)
- [ ] Tab 2: Transacciones (list.bullet)
- [ ] Tab 3: Agregar (plus.circle.fill) — botón central
- [ ] Tab 4: Presupuesto (chart.pie.fill)
- [ ] Tab 5: Gráficos (chart.bar.fill)
- [ ] Estilo del TabBar: fondo `surface`, tint `positive`
- [ ] Cada tab contiene un `NavigationStack` propio

#### 2.2 Crear vistas placeholder

- [ ] `DashboardView.swift` — texto "Dashboard" centrado
- [ ] `TransactionListView.swift` — texto "Transactions" centrado
- [ ] `AddTransactionView.swift` — sheet modal
- [ ] `BudgetView.swift` — texto "Budget" centrado
- [ ] `ChartsView.swift` — texto "Charts" centrado

#### 2.3 Configurar el tab central como sheet

- [ ] El tab 3 no navega a una vista — abre un `.sheet` modal
- [ ] Al tocar el tab 3, se activa un binding `showAddTransaction`
- [ ] El sheet presenta `AddTransactionView`
- [ ] Al cerrar el sheet, el tab seleccionado vuelve al anterior

**Prompt Claude Code:**
```
Modifica ContentView.swift para que el tab "Agregar" (index 2) no navegue a una vista sino que abra un .sheet con AddTransactionView. Usa un @State showAddTransaction: Bool. Cuando el usuario toca el tab del "+" se activa el sheet y el tab selection vuelve al tab anterior. Fondo del TabBar: FTColors.surface. Tint: FTColors.positive. Sin comentarios.
```

**Criterio de completitud:** Los 5 tabs son navegables, el botón central abre un sheet, el back-navigation funciona en cada tab.

---

### Fase 3 — Dashboard

**Objetivo:** Pantalla principal con balance card, acciones rápidas y transacciones recientes.

#### 3.1 DashboardViewModel

- [ ] Crear `Features/Dashboard/DashboardViewModel.swift`
- [ ] `@Observable class`
- [ ] Propiedades computadas: `totalBalance`, `monthlyIncome`, `monthlyExpenses`, `savingsRate`
- [ ] Método `recentTransactions(limit: Int)` — últimas N transacciones del mes
- [ ] Dependencia: acceso al `ModelContext` a través de un service

#### 3.2 BalanceCardView

- [ ] Fondo `card` con `cornerRadius(20)`
- [ ] Monto total en `FTTypo.amount()` con `FTColors.textPrimary`
- [ ] Centavos en tamaño menor `.textSecondary`
- [ ] Label "BALANCE DISPONIBLE" en `FTTypo.data()` con `FTColors.textDisabled`
- [ ] Indicador de cambio mensual: "↑ +$3,200" en `positive` o "↓ −$500" en `negative`
- [ ] Divisor horizontal
- [ ] 3 stats en fila: Ingresos, Gastos, Ahorro %

**Prompt Claude Code:**
```
Crea Features/Dashboard/Components/BalanceCardView.swift. Recibe totalBalance: Double, monthlyIncome: Double, monthlyExpenses: Double, savingsRate: Double. Fondo FTColors.card, cornerRadius 20. Arriba label "BALANCE DISPONIBLE" en FTTypo.data() color textDisabled. Debajo el monto grande con FTTypo.amount() en textPrimary. Debajo un indicador de cambio mensual (income - expenses) con AmountText. Divisor de 0.5px en border color. Abajo HStack de 3 columnas: Ingresos en positive, Gastos en negative, Ahorro% en positive o negative según valor. Cada columna: label arriba en data() textDisabled, valor abajo en data() con color semántico. Sin comentarios.
```

#### 3.3 RecentTransactionsView

- [ ] Título "Recientes" con botón "Ver todo →"
- [ ] Lista de 5 transacciones más recientes usando `TransactionRowView`
- [ ] Tap en "Ver todo" navega a TransactionListView

#### 3.4 TransactionRowView

- [ ] HStack: CategoryIcon (32x32) + VStack(título, fecha) + Spacer + AmountText
- [ ] Título en `body()` con `textPrimary`
- [ ] Fecha en `data()` con `textDisabled` (formato "Hoy · 09:24" o "28 abr · 16:40")
- [ ] Monto con color semántico automático
- [ ] Tap navega a detalle (futuro)

#### 3.5 QuickActionsView

- [ ] Dos botones: "Agregar gasto" (negative tint) y "Agregar ingreso" (positive tint)
- [ ] Ambos abren AddTransactionView con el tipo pre-seleccionado

#### 3.6 Integrar todo en DashboardView

- [ ] ScrollView con VStack
- [ ] Orden: BalanceCard → QuickActions → RecentTransactions
- [ ] Toolbar: título "FinTrack Pro" a la izquierda, Settings gear a la derecha
- [ ] Fondo `background`

**Criterio de completitud:** Dashboard muestra datos de preview, scroll es fluido, los componentes se ven como el diseño definido en el brand document.

---

### Fase 4 — Agregar transacción

**Objetivo:** Sheet modal para registrar un gasto o ingreso en 3 segundos.

#### 4.1 AddTransactionViewModel

- [ ] `@Observable class`
- [ ] Propiedades: `amount` String (input crudo), `title` String, `note` String, `selectedCategory` Category?, `isIncome` Bool, `date` Date
- [ ] Validación: amount parseable a Double > 0, título no vacío, categoría seleccionada
- [ ] Computed `isValid: Bool`
- [ ] Método `save(context: ModelContext)` async throws

#### 4.2 Layout del sheet

- [ ] Toolbar: "Cancelar" a la izquierda, "Guardar" a la derecha (disabled si no válido)
- [ ] Toggle Income/Expense con segmented control
- [ ] Campo de monto gigante centrado (FTTypo.hero) — solo números y punto decimal
- [ ] Campo de título
- [ ] Grid de categorías (CategoryPicker)
- [ ] DatePicker (por defecto hoy)
- [ ] Campo de nota opcional (colapsado por defecto)

#### 4.3 CategoryPicker

- [ ] LazyVGrid con 5 columnas
- [ ] Cada celda: CategoryIcon + nombre debajo
- [ ] Celda seleccionada: borde `positive` + scale 1.05
- [ ] Animación de selección con `.spring()`

#### 4.4 Input de monto

- [ ] TextField con `keyboardType(.decimalPad)`
- [ ] Formateo en vivo: agregar "$" visual, separador de miles
- [ ] Color del monto según toggle: `positive` si ingreso, `negative` si gasto
- [ ] Auto-focus al abrir el sheet

#### 4.5 Guardar y cerrar

- [ ] Al guardar: crear Transaction, insertar en context, haptic success, dismiss sheet
- [ ] Si error: mostrar alert con FinTrackError
- [ ] Animación de confirmación: checkmark que aparece 0.5s antes de cerrar

**Prompt Claude Code:**
```
Crea Features/Transactions/AddTransactionView.swift. Es un sheet con NavigationStack. Toolbar: "Cancelar" (dismiss) y "Guardar" (calls viewModel.save, disabled si !viewModel.isValid). Contenido: Picker segmented para Income/Expense. TextField gigante centrado para monto con keyboardType .decimalPad, font FTTypo.hero(), color FTColors.positive si isIncome, FTColors.negative si no. TextField para título. CategoryPicker como LazyVGrid de 5 columnas. DatePicker. TextField para nota opcional. Fondo FTColors.background. Sin comentarios.
```

**Criterio de completitud:** Se puede agregar una transacción completa, se guarda en SwiftData, se refleja inmediatamente en Dashboard.

---

### Fase 5 — Lista de transacciones

**Objetivo:** Lista completa filtrable por tipo, categoría y rango de fechas.

#### 5.1 TransactionListViewModel

- [ ] `@Observable class`
- [ ] Propiedades: `filterType` (all/income/expense), `selectedCategory` Category?, `dateRange` (start, end)
- [ ] Método `filteredTransactions(from: [Transaction])` que aplique todos los filtros
- [ ] Computed: `groupedByDate` — agrupa transacciones por día

#### 5.2 TransactionFilterBar

- [ ] HStack scrollable horizontal con pills
- [ ] Pill "Todos", "Ingresos", "Gastos"
- [ ] Pill seleccionado: fondo sólido del color semántico
- [ ] Pill no seleccionado: fondo `elevated` con texto `textSecondary`

#### 5.3 Lista agrupada por fecha

- [ ] Secciones por día: "Hoy", "Ayer", "28 abril 2026", etc.
- [ ] Header de sección: fecha + total del día
- [ ] Contenido: `TransactionRowView` para cada transacción
- [ ] Swipe to delete con confirmación
- [ ] Pull to... nada (datos locales), pero visual de refresh por consistencia UX

#### 5.4 Empty state

- [ ] Cuando no hay transacciones: ilustración simple + texto "Sin transacciones" + CTA "Agregar primera"

#### 5.5 Buscar

- [ ] `.searchable()` en el NavigationStack
- [ ] Búsqueda por título de transacción

**Criterio de completitud:** Lista muestra todas las transacciones agrupadas, filtros funcionan, search funciona, delete con swipe funciona.

---

### Fase 6 — Presupuestos

**Objetivo:** Definir límites de gasto por categoría y ver progreso visual.

#### 6.1 BudgetViewModel

- [ ] `@Observable class`
- [ ] Método `budgetsForCurrentMonth()` — retorna budgets del mes actual con gasto acumulado
- [ ] Computed: `overallUsagePercent` — porcentaje total de todos los budgets
- [ ] Computed: `overBudgetCategories` — categorías que excedieron su límite

#### 6.2 BudgetRingView

- [ ] Anillo circular que muestra el % general de uso del presupuesto
- [ ] Color: positive < 60%, warning 60-85%, negative > 85%
- [ ] Centro: porcentaje libre + label "libre"
- [ ] Animación: `trim(from: to:)` con `.spring()` al aparecer

**Prompt Claude Code:**
```
Crea Features/Budget/Components/BudgetRingView.swift. Recibe usagePercent: Double (0.0 a 1.0). Dibuja un anillo circular con Shape custom y trim(from: 0, to: usagePercent). Color: FTColors.positive si < 0.6, FTColors.warning si 0.6-0.85, FTColors.negative si > 0.85. Fondo del track: FTColors.border. Centro del anillo: texto "\(Int((1 - usagePercent) * 100))%" en FTTypo.h2() y "libre" en FTTypo.caption() textDisabled. Anima el trim con .animation(.spring(duration: 0.8), value: usagePercent). Tamaño del anillo: 100x100. Grosor del stroke: 8. Sin comentarios.
```

#### 6.3 BudgetBarView

- [ ] Fila: nombre categoría + monto gastado / límite + barra horizontal
- [ ] Color de la barra según porcentaje (misma lógica que el ring)
- [ ] Animación de la barra al aparecer

#### 6.4 BudgetView layout

- [ ] ScrollView
- [ ] BudgetRingView centrado arriba
- [ ] Lista de BudgetBarView debajo, una por categoría
- [ ] Botón "Editar presupuestos" que navega a EditBudgetView
- [ ] Sección de categorías sobre presupuesto con alerta visual

#### 6.5 EditBudgetView

- [ ] Lista de categorías con TextField para el monto límite de cada una
- [ ] Guardar actualiza o crea Budget para el mes actual
- [ ] Categorías sin presupuesto definido: aparecen con campo vacío

**Criterio de completitud:** Se pueden definir presupuestos, las barras reflejan el gasto real vs. límite, los colores cambian según porcentaje.

---

### Fase 7 — Gráficos

**Objetivo:** Visualización de datos financieros con Swift Charts.

#### 7.1 ChartsViewModel

- [ ] `@Observable class`
- [ ] Computed: `monthlyBarData` — array de (mes, ingreso, gasto) para últimos 6 meses
- [ ] Computed: `categoryPieData` — array de (categoría, monto total) del mes actual
- [ ] Computed: `dailyTrendData` — array de (día, balance acumulado) del mes actual

#### 7.2 MonthlyBarChart

- [ ] `Chart` con `BarMark` agrupado por mes
- [ ] Barras de ingreso en `positive`, gastos en `negative`
- [ ] Eje X: nombres de meses abreviados
- [ ] Eje Y: montos formateados

#### 7.3 CategoryPieChart

- [ ] `Chart` con `SectorMark`
- [ ] Colores: usar `colorHex` de cada categoría
- [ ] Label: emoji + porcentaje
- [ ] Tap en sector: mostrar detalle de la categoría

#### 7.4 TrendLineChart

- [ ] `Chart` con `LineMark` + `AreaMark` debajo con gradiente
- [ ] Línea en `accent` con `interpolationMethod(.catmullRom)` para suavizado
- [ ] Área con gradiente de `accent.opacity(0.3)` a `clear`
- [ ] Punto de referencia: línea horizontal en $0 con label

#### 7.5 ChartsView layout

- [ ] ScrollView vertical
- [ ] Selector de rango: "Este mes", "3 meses", "6 meses", "1 año"
- [ ] Los 3 gráficos en orden: Monthly Bar → Category Pie → Daily Trend
- [ ] Cada gráfico en su card con título

**Criterio de completitud:** Los 3 gráficos renderizan datos reales de SwiftData, las animaciones de Chart son fluidas, el selector de rango cambia los datos.

---

### Fase 8 — Biometric Auth

**Objetivo:** Proteger la app con Face ID / Touch ID.

#### 8.1 BiometricService

- [ ] Protocolo `BiometricServiceProtocol` con `authenticate() async throws -> Bool`
- [ ] Implementación con `LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)`
- [ ] Manejo de errores: no disponible, usuario canceló, falló
- [ ] Info.plist: agregar `NSFaceIDUsageDescription`

#### 8.2 Lock screen

- [ ] Vista `LockScreenView` que se muestra al abrir la app
- [ ] Ícono de Face ID / Touch ID centrado con botón "Desbloquear"
- [ ] Auto-trigger al aparecer
- [ ] Si falla: mostrar botón de retry
- [ ] AppState guarda `isUnlocked: Bool`

#### 8.3 Integración

- [ ] En `FinTrackProApp.swift`: mostrar `LockScreenView` sobre `ContentView` si `!appState.isUnlocked`
- [ ] Al ir a background: volver a bloquear (`.scenePhase` observer)

**Criterio de completitud:** La app pide Face ID al abrir, se bloquea al ir a background, funciona sin biometría disponible (fallback a passcode del dispositivo).

---

### Fase 9 — Widget

**Objetivo:** Widget de pantalla de inicio mostrando balance del mes.

#### 9.1 Crear Widget Extension

- [ ] File → New → Target → Widget Extension
- [ ] Nombre: `FinTrackWidget`
- [ ] ☑️ Include Configuration App Intent

#### 9.2 WidgetProvider

- [ ] `TimelineProvider` que lee datos de SwiftData
- [ ] Snapshot: datos estáticos de ejemplo
- [ ] Timeline: actualizar cada hora con datos reales
- [ ] Compartir `ModelContainer` entre app y widget via App Group

#### 9.3 Widget Views

- [ ] Small: balance del mes + indicador ↑↓
- [ ] Medium: balance + últimas 3 transacciones
- [ ] Colores del design system
- [ ] Deep link al abrir: navegar a Dashboard

#### 9.4 App Group

- [ ] Crear App Group en Apple Developer Portal
- [ ] Configurar en ambos targets (app + widget)
- [ ] Configurar `ModelContainer` compartido con App Group URL

**Criterio de completitud:** Widget aparece en el home screen, muestra balance real, se actualiza, tap abre la app.

---

### Fase 10 — App Intents (Siri)

**Objetivo:** "Hey Siri, agrega un gasto de $50 en comida" funciona.

#### 10.1 AddExpenseIntent

- [ ] `@AssistantIntent` con parámetros: amount (Double), category (String), title (String opcional)
- [ ] Ejecuta la misma lógica que AddTransactionViewModel.save
- [ ] Confirmación en Siri: "Guardé un gasto de $50 en Comida"

#### 10.2 CheckBalanceIntent

- [ ] `@AssistantIntent` sin parámetros
- [ ] Retorna: "Tu balance es $12,840.50. Este mes ingresaste $5,000 y gastaste $1,840."

#### 10.3 Shortcuts App integration

- [ ] Los intents aparecen automáticamente en la app Shortcuts
- [ ] Agregar `AppShortcutsProvider` con shortcuts sugeridos

**Criterio de completitud:** Siri responde correctamente, los Shortcuts aparecen en la app Shortcuts, los datos se guardan realmente.

---

### Fase 11 — Settings

**Objetivo:** Pantalla de configuración con las opciones esenciales.

- [ ] Toggle Face ID / Touch ID
- [ ] Selector de moneda (USD, EUR, MXN)
- [ ] Toggle de CloudKit sync
- [ ] Botón exportar datos como CSV
- [ ] Botón de borrar todos los datos con doble confirmación
- [ ] Versión de la app + link a ArguDev
- [ ] Link a política de privacidad

---

### Fase 12 — Polish y animaciones

**Objetivo:** La app se siente premium, no funcional.

- [ ] Animación de entrada en Dashboard: cards hacen fadeUp staggered
- [ ] Animación al agregar transacción: bounce del balance card
- [ ] Haptic feedback: light en selección de categoría, success al guardar, warning al exceder presupuesto
- [ ] Transiciones entre tabs suaves
- [ ] Scroll to top al tocar tab activo
- [ ] Empty states con animación sutil
- [ ] Todas las animaciones gateadas con `@Environment(\.accessibilityReduceMotion)`

---

### Fase 15 — Accesibilidad Premium

**Objetivo:** La app pasa un audit de VoiceOver real sin friction. Cualquier persona invidente puede usar FinTrack Pro de forma autónoma.

#### 15.1 Dynamic Type en custom fonts

- [ ] Actualizar `FTTypo` para que cada función use `scaled(_:relativeTo:)` con `UIFontMetrics`
- [ ] Aplicar `.dynamicTypeSize(.xSmall ... .accessibility3)` en vistas con layout complejo (BalanceCard, BudgetBarView)
- [ ] Verificar en simulador: Configuración → Accesibilidad → Tamaño de texto → mover al máximo sin que ninguna vista se rompa

**Prompt Claude Code:**
```
Actualiza Core/DesignSystem/Typography.swift. Cada función de FTTypo debe usar Font.custom con fixedSize más un escalado relativo a un TextStyle de referencia usando UIFontMetrics. hero() escala relativeTo .largeTitle, h1() relativeTo .title, h2() relativeTo .title2, body() y bodySemi() relativeTo .body, caption() relativeTo .caption, data() relativeTo .callout, amount() relativeTo .title, amountLg() relativeTo .largeTitle, label() relativeTo .caption2. Sin comentarios.
```

#### 15.2 VoiceOver en componentes financieros

- [ ] `BalanceCardView`: `.accessibilityElement(children: .combine)` + label "Balance disponible" + value con `accessibilityFormatted`
- [ ] `AmountText`: label dinámico "Ingreso de X" o "Gasto de X" según signo
- [ ] `BudgetRingView`: label "Anillo de presupuesto" + value "N por ciento libre"
- [ ] `BudgetBarView`: label con nombre de categoría + value "X de Y. N por ciento"
- [ ] `TransactionRowView`: `.accessibilityElement(children: .combine)` + label título + hint "Toca dos veces para ver detalle"
- [ ] `CategoryIcon`: label con nombre de categoría, `.accessibilityHidden(false)`
- [ ] `PrimaryButton`: label descriptivo + hint de acción
- [ ] Crear extensión `Double.accessibilityFormatted: String` con `NumberFormatter` en spellOut

**Prompt Claude Code:**
```
Crea Core/Extensions/Double+Accessibility.swift. Extensión de Double con computed property accessibilityFormatted: String. Usa NumberFormatter con numberStyle .spellOut y Locale.current. Si self >= 0 retorna "[monto en palabras] dólares". Si self < 0 retorna "menos [monto absoluto en palabras] dólares". Sin comentarios.
```

#### 15.3 Orden de foco en vistas clave

- [ ] Dashboard: `BalanceCardView` primero (`.accessibilitySortPriority(3)`), QuickActions segundo, RecentTransactions tercero
- [ ] AddTransactionView: Toggle tipo → campo monto → campo título → CategoryPicker → DatePicker → nota → botón guardar
- [ ] BudgetView: BudgetRingView primero, luego cada BudgetBarView en orden

#### 15.4 Reduce Motion

- [ ] Auditar todas las animaciones con `.spring()` y `.easeInOut()`
- [ ] Gatear con `@Environment(\.accessibilityReduceMotion) var reduceMotion`
- [ ] Animaciones funcionales (loading, save confirmation): reducir duración a 0.1s pero no eliminar

#### 15.5 Audit manual

- [ ] Activar VoiceOver en iPhone físico
- [ ] Navegar por las 5 tabs sin ver la pantalla
- [ ] Completar el flujo: abrir app → agregar gasto → verificar en dashboard
- [ ] Ningún elemento debe ser inaccesible o tener label vacío

**Criterio de completitud:** Una persona con VoiceOver activado puede agregar una transacción completa sin ver la pantalla.

---

### Fase 16 — Soporte Multilingüe (ES · EN · FR)

**Objetivo:** La app cambia idioma automáticamente según el idioma del sistema. Cero strings hardcodeados.

#### 16.1 Configurar localización en Xcode

- [ ] Project → Info → Localizations → añadir English y French
- [ ] Crear `Localizable.xcstrings` (File → New → String Catalog)
- [ ] Crear `AppShortcuts.xcstrings` para los intents de Siri
- [ ] En `Info.plist`: agregar `CFBundleLocalizations` con `es`, `en`, `fr` y `CFBundleDevelopmentRegion` = `es`

#### 16.2 Migrar strings por feature

Orden recomendado: Dashboard → AddTransaction → TransactionList → Budget → Charts → Settings → Errors

- [ ] Extraer todos los strings literales de vistas a claves del catálogo
- [ ] Nomenclatura de claves: `[feature].[componente].[descripcion]`
- [ ] Agregar traducción EN y FR para cada clave
- [ ] Verificar plurales: "1 transacción" vs "5 transacciones" en los 3 idiomas

**Claves mínimas por feature:**

| Feature | Claves estimadas |
|---------|-----------------|
| Dashboard | 8 |
| AddTransaction | 14 |
| TransactionList | 10 |
| Budget | 12 |
| Charts | 8 |
| Settings | 16 |
| Errors | 8 |
| Widget | 4 |
| Siri Intents | 6 |
| **Total** | **~86** |

#### 16.3 Formato de moneda localizado

- [ ] Actualizar `CurrencyFormatter` para detectar locale del sistema
- [ ] Francés usa EUR por defecto, español y otros USD
- [ ] Formato de fecha también localizado: "hoy", "ayer", "28 avr.", "Apr 28"

**Prompt Claude Code:**
```
Crea Core/Utilities/CurrencyFormatter.swift. Struct con static func format(_ amount: Double, locale: Locale = .current) -> String. Usa amount.formatted(.currency(code: currencyCode(for: locale)).locale(locale).precision(.fractionLength(2))). currencyCode retorna "EUR" si el languageCode es "fr", "USD" en cualquier otro caso. También incluye static func formatDate(_ date: Date, locale: Locale = .current) -> String que retorna "Hoy" / "Today" / "Aujourd'hui" para hoy, "Ayer" / "Yesterday" / "Hier" para ayer, y fecha formateada con DateFormatter style .medium en el locale dado para el resto. Sin comentarios.
```

#### 16.4 VoiceOver localizado

- [ ] Todos los `accessibilityLabel` y `accessibilityHint` usan `Text("clave.localizada")`, nunca strings literales
- [ ] `Double.accessibilityFormatted` usa `NumberFormatter` con `Locale.current`
- [ ] Verificar en simulador en inglés y francés que VoiceOver lee correctamente

#### 16.5 Testing de localización

- [ ] Verificar en simulador: Configuración → General → Idioma y región → cambiar a English y French
- [ ] Ningún texto debe aparecer en la lengua base si hay traducción disponible
- [ ] Ningún layout debe romperse con strings franceses (generalmente más largos)

**Criterio de completitud:** Cambiar el idioma del simulador a EN o FR resulta en una app completamente traducida sin strings en español.

---

### Fase 13 — Testing

**Objetivo:** Coverage mínimo de 60% en ViewModels y Services.

- [ ] Tests de `AddTransactionViewModel`: validación, save success, save error
- [ ] Tests de `DashboardViewModel`: cálculo de balance, savings rate, agrupación
- [ ] Tests de `BudgetViewModel`: usage percent, over-budget detection
- [ ] Tests de `ChartsViewModel`: data grouping por mes, por categoría
- [ ] Tests de `CurrencyFormatter`: formatos, edge cases (0, negativo, muy grande)
- [ ] Tests de `BiometricService`: mock de LAContext

**Prompt Claude Code:**
```
Crea Features/Dashboard/Tests/DashboardViewModelTests.swift usando Swift Testing (@Test). Testea: totalBalance calcula correctamente con 5 transacciones mixtas. monthlyIncome solo suma isIncome == true. monthlyExpenses solo suma isIncome == false. savingsRate retorna porcentaje correcto. recentTransactions retorna máximo N items ordenados por fecha descendente. Usa @Model de SwiftData con ModelContainer in-memory para testing. Sin comentarios.
```

---

### Fase 14 — README y presentación

**Objetivo:** El repo en GitHub se ve como un proyecto open-source profesional.

- [ ] README.md con: título, badge de Swift/iOS/License, descripción de 2 líneas, screenshots (GIF animado), features lista, stack, arquitectura (diagrama Mermaid), instrucciones de instalación, roadmap, autor con link a ArguDev
- [ ] LICENSE MIT
- [ ] Video demo de 60 segundos grabado con QuickTime
- [ ] Screenshots en Assets del repo

---

## 7. Configuración Inicial

### Prerrequisitos

- macOS Sequoia o superior
- Xcode 16+ (última estable)
- Apple Developer Account ($99/año)
- iPhone físico para testing de Face ID y Widget (el simulador funciona limitado)
- Git configurado con SSH key en GitHub

### Paso a paso

1. Abrir Xcode → Create New Project → App
2. Product Name: `FinTrackPro`
3. Team: seleccionar tu developer account
4. Organization Identifier: `com.argudev`
5. Interface: SwiftUI
6. Storage: SwiftData
7. ☑️ Include Tests
8. Guardar en carpeta limpia
9. Cerrar Xcode
10. Abrir terminal en la carpeta del proyecto
11. `git init`
12. Crear `.gitignore` (ver prompt en Fase 0.2)
13. `git add .`
14. `git commit -m "chore: initial project setup"`
15. Crear repo en GitHub: `FinTrackPro` (público, sin README ni license)
16. `git remote add origin git@github.com:MauroArguDev/FinTrackPro.git`
17. `git push -u origin main`
18. `git checkout -b develop`
19. `git push -u origin develop`
20. Abrir Xcode de nuevo
21. Deployment Target: iOS 17.0
22. En Signing & Capabilities: agregar CloudKit y App Groups (para Widget)
23. Build y run — verificar que compila limpio

---

## 8. Estrategia con Claude Code

### Principios

| Regla | Por qué |
|-------|---------|
| Un archivo por prompt | Mantiene el contexto pequeño y el output preciso |
| Siempre pegar el design system primero | Claude Code necesita conocer FTColors, FTTypo, etc. para generar código consistente |
| Describir inputs y outputs | "Recibe X, muestra Y" es mejor que "Crea la vista de budget" |
| Pedir sin comentarios | Reduce tokens innecesarios y genera código limpio |
| Compilar después de cada prompt | No acumular 5 archivos sin verificar |
| Refactorizar en prompt separado | Generar primero, mejorar después |

### Prompt pattern

```
Crea [ruta/archivo.swift].
Es un [tipo: View / @Observable class / struct / protocol].
Recibe [parámetros con tipos].
[Descripción funcional de qué hace].
Usa [FTColors.X, FTTypo.Y, FTSpacing.Z] para estilos.
[Restricción específica si la hay].
Sin comentarios.
```

### Prompts malos vs buenos

**Malo:**
> Crea la pantalla de dashboard de una app de finanzas

**Bueno:**
> Crea Features/Dashboard/DashboardView.swift. Es un ScrollView vertical con fondo FTColors.background. Contiene en orden: BalanceCardView(totalBalance: viewModel.totalBalance, monthlyIncome: viewModel.monthlyIncome, monthlyExpenses: viewModel.monthlyExpenses, savingsRate: viewModel.savingsRate), QuickActionsView(onAddExpense:, onAddIncome:), RecentTransactionsView(transactions: viewModel.recentTransactions). NavigationStack con toolbar: título "FinTrack Pro" a la izquierda en FTTypo.h2() y botón gear a la derecha que navega a SettingsView. Sin comentarios.

**Malo:**
> Hazme tests del view model

**Bueno:**
> Crea Features/Transactions/Tests/AddTransactionViewModelTests.swift usando Swift Testing (@Test). Testea: isValid retorna false si amount está vacío. isValid retorna false si title está vacío. isValid retorna false si no hay categoría. isValid retorna true cuando todo está completo. save() inserta un Transaction en el context con los valores correctos. save() con amount inválido lanza FinTrackError.saveFailed. Usa ModelContainer in-memory. Sin comentarios.

### Cuándo NO usar Claude Code

- Decisiones de arquitectura (las tomas tú)
- Configuración de Xcode (signing, capabilities, targets)
- Debugging visual (usa Xcode Previews)
- Diseño de UX (usa Figma)
- Publicación en App Store (proceso manual en App Store Connect)

---

## 9. Estrategia de Testing

### Coverage goal: 60% ViewModels + Services

| Componente | Test | Prioridad |
|------------|------|-----------|
| AddTransactionViewModel | Validación, save, edge cases | Alta |
| DashboardViewModel | Cálculos financieros | Alta |
| BudgetViewModel | Usage %, over-budget | Alta |
| ChartsViewModel | Agrupación, rangos de fecha | Media |
| CurrencyFormatter | Formatos en ES, EN, FR + edge cases (0, negativo, muy grande) | Media |
| Double+Accessibility | accessibilityFormatted positivo, negativo, cero | Media |
| CurrencyFormatter.formatDate | Hoy / ayer / fecha con 3 locales | Media |
| BiometricService | Mock de LAContext | Baja |
| Views | Preview builds sin crash | Baja |

### Pattern de testing con SwiftData

```swift
@Test func balanceCalculatesCorrectly() async throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: Transaction.self, configurations: config)
    let context = container.mainContext

    let income = Transaction(amount: 5000, title: "Salario", isIncome: true)
    let expense = Transaction(amount: 1500, title: "Renta", isIncome: false)
    context.insert(income)
    context.insert(expense)

    let vm = DashboardViewModel(context: context)
    #expect(vm.totalBalance == 3500)
}
```

---

## 10. Estrategia de Escalabilidad

| Área | MVP | Futuro |
|------|-----|--------|
| Persistencia | SwiftData local | CloudKit sync habilitado |
| Networking | Ninguno | API REST para versión web eventual |
| Offline | 100% offline | Offline-first con sync queue |
| Analytics | Ninguno | TelemetryDeck (privacy-first) |
| Feature flags | Ninguno | Remote Config si escala |
| Caché | SwiftData es el caché | N/A |
| Módulos | Un target app + widget | SPM modules por feature si crece |
| CI/CD | Manual | Xcode Cloud al publicar |

---

## 11. Estrategia de Portafolio

### Qué impresiona a reclutadores iOS

| Feature | Por qué |
|---------|---------|
| SwiftData con relaciones | Demuestra persistencia moderna |
| Swift Charts nativos | API nueva que pocos dominan |
| WidgetKit | Integración con sistema operativo |
| App Intents / Siri | Pocos portafolios lo incluyen |
| Face ID | LocalAuthentication real |
| Async/Await everywhere | Sin Combine legacy |
| MVVM testeable | Arquitectura limpia demostrable |
| Design system propio | No usa librerías de UI de terceros |
| Accesibilidad VoiceOver premium | Casi ningún portafolio iOS lo incluye |
| Soporte EN · ES · FR | Demuestra pensamiento de producto, no solo código |

### README estructura

1. Título + badges (Swift 6, iOS 17+, MIT License)
2. Una línea de descripción
3. GIF animado de 10 segundos
4. Features como lista corta
5. Stack tecnológico como tabla
6. Diagrama de arquitectura Mermaid
7. Screenshots de 3 pantallas clave
8. Instrucciones de instalación (clone + open + run)
9. Autor: "Built by ArguDev" con links

### Screenshots obligatorios

1. Dashboard con balance y transacciones
2. Gráficos con Swift Charts
3. Widget en home screen
4. Sheet de agregar transacción

---

## 12. Riesgos y Antipatrones

| Riesgo | Mitigación |
|--------|-----------|
| Over-engineering servicios innecesarios | MVVM simple, sin Use Cases ni Repositories |
| SwiftData bugs con CloudKit | Implementar CloudKit al final, empezar solo local |
| Views acopladas a Model | Usar ViewModels como intermediarios |
| Animaciones que causan lag | Medir con Instruments antes de agregar más |
| Design system inconsistente | Nunca hardcodear colores ni sizes, siempre usar tokens |
| Acumular deuda técnica | Refactorizar cada 2 fases |
| Widget no actualiza | Verificar App Group y timeline refresh policy |
| Tests frágiles | Usar ModelContainer in-memory, no depender de estado externo |

### Antipatrones de SwiftUI

- No usar `@ObservedObject` para nuevo iOS 17 — usar `@Observable` y `@State`
- No poner lógica de negocio en Views
- No crear God ViewModels con 20 propiedades — dividir por feature
- No usar `AnyView` — usar `@ViewBuilder` y generics
- No forzar unwrap opcionales en Views — siempre manejar nil
- No animar todo — animar solo lo que comunica algo

---

## 13. Definition of Done

### Feature terminada

- [ ] Compila sin warnings
- [ ] Funciona en preview
- [ ] Funciona en simulador
- [ ] Usa tokens del design system (sin hardcode)
- [ ] Maneja empty state
- [ ] Maneja error state
- [ ] Todos los strings usan claves de `Localizable.xcstrings`, ninguno hardcodeado
- [ ] Accesibilidad: todos los elementos interactivos tienen `accessibilityLabel`
- [ ] Accesibilidad: elementos puramente decorativos marcados con `.accessibilityHidden(true)`
- [ ] Commit con mensaje semántico

### Pantalla terminada

- [ ] Todo lo de "feature terminada"
- [ ] Layout correcto en iPhone SE (smallest) y iPhone 16 Pro Max (largest)
- [ ] Layout correcto con Dynamic Type en tamaño máximo de accesibilidad
- [ ] Scroll funciona correctamente
- [ ] Navegación ida y vuelta funciona
- [ ] ViewModel tiene al menos 2 tests
- [ ] Verificado en simulador en inglés y francés sin strings rotos

### MVP

- [ ] 5 tabs funcionales
- [ ] CRUD completo de transacciones
- [ ] Presupuestos con barras visuales
- [ ] Al menos 1 gráfico con Swift Charts
- [ ] Face ID funcional
- [ ] Widget funcional
- [ ] 0 crashes en 10 minutos de uso
- [ ] README con screenshots

### Portfolio-ready

- [ ] Todo lo del MVP
- [ ] 3 gráficos con Swift Charts
- [ ] Siri shortcut funcional
- [ ] CloudKit sync funcional
- [ ] VoiceOver audit manual: flujo completo sin ver la pantalla ✅
- [ ] Dynamic Type: ninguna vista se rompe en tamaño máximo ✅
- [ ] App completamente traducida EN · ES · FR ✅
- [ ] `CurrencyFormatter` con locale correcto por idioma ✅
- [ ] Video demo de 60 segundos
- [ ] GIF animado en README
- [ ] Lighthouse mental: un iOS Lead no encuentra code smells
- [ ] TestFlight link disponible
- [ ] Subido a App Store (o en proceso de review)

---

## 14. Evoluciones Futuras

| Feature | Fase | Complejidad |
|---------|------|-------------|
| Importar estado de cuenta CSV | Post-MVP | Media |
| Metas de ahorro con progreso | Post-MVP | Baja |
| Notificaciones push diarias | Post-MVP | Baja |
| Apple Watch companion | V2 | Alta |
| iPad layout adaptativo | V2 | Media |
| Recurrentes (suscripciones) | V2 | Media |
| Multi-cuenta (efectivo, banco, tarjeta) | V2 | Alta |
| Análisis con Core ML (predicción de gastos) | V3 | Alta |
| Exportar reportes PDF | V2 | Media |
| Temas de color adicionales | Post-MVP | Baja |
| Gamificación (rachas de ahorro) | V3 | Media |
| SharePlay para presupuestos compartidos | V3 | Alta |

---

## 15. Execution Order

Orden exacto de construcción, de inicio a fin:

| # | Tarea | Branch | Fase |
|---|-------|--------|------|
| 1 | ~~Crear proyecto Xcode + Git + GitHub~~ ✅ | `main` | 0.1-0.2 |
| 2 | Design system: Colors, Typography con UIFontMetrics, Spacing, Radius + custom fonts | `feature/design-system` | 0.3 |
| 3 | Componentes base: AmountText, PillBadge, CategoryIcon, PrimaryButton, FTCardModifier | `feature/design-components` | 0.4 |
| 4 | Modelos SwiftData: Transaction, Category, Budget | `feature/data-models` | 1.1-1.3 |
| 5 | Preview sample data | `feature/preview-data` | 1.4 |
| 6 | TabView + NavigationStack + vistas placeholder | `feature/navigation` | 2.1-2.3 |
| 7 | TransactionRowView | `feature/transaction-row` | 3.4 |
| 8 | DashboardViewModel + BalanceCardView | `feature/dashboard-balance` | 3.1-3.2 |
| 9 | QuickActionsView + RecentTransactionsView | `feature/dashboard-sections` | 3.3, 3.5 |
| 10 | DashboardView integración completa | `feature/dashboard-integration` | 3.6 |
| 11 | AddTransactionViewModel + validación | `feature/add-transaction-vm` | 4.1 |
| 12 | AddTransactionView + CategoryPicker + amount input | `feature/add-transaction-ui` | 4.2-4.5 |
| 13 | TransactionListViewModel + filtros | `feature/transaction-list-vm` | 5.1 |
| 14 | TransactionListView + filter bar + grouped list | `feature/transaction-list-ui` | 5.2-5.5 |
| 15 | BudgetViewModel + BudgetRingView + BudgetBarView | `feature/budget` | 6.1-6.5 |
| 16 | ChartsViewModel + 3 gráficos con Swift Charts | `feature/charts` | 7.1-7.5 |
| 17 | BiometricService + LockScreenView | `feature/biometric-auth` | 8.1-8.3 |
| 18 | Widget Extension + App Group | `feature/widget` | 9.1-9.4 |
| 19 | App Intents (Siri) | `feature/siri-intents` | 10.1-10.3 |
| 20 | SettingsView | `feature/settings` | 11 |
| 21 | Animaciones y haptics polish + Reduce Motion | `feature/polish` | 12 |
| 22 | Accesibilidad premium: UIFontMetrics, VoiceOver audit, accessibilityFormatted, Reduce Motion, orden de foco | `feature/accessibility` | 15 |
| 23 | Localización: xcstrings, migrar strings, CurrencyFormatter multilocale, AppShortcuts.xcstrings | `feature/localization` | 16 |
| 24 | Tests de ViewModels + CurrencyFormatter + Double+Accessibility | `feature/tests` | 13 |
| 25 | README + screenshots + video demo | `docs/readme` | 14 |
| 26 | TestFlight upload | `main` (release tag) | — |
| 27 | App Store submission | `main` (release tag) | — |

**Regla:** Cada feature branch se crea desde `develop`. Al completar, merge a `develop`. Al cerrar una fase completa, merge `develop` a `main` con tag de versión.

**Tiempo estimado:** 17-22 días a 3-4 horas diarias.
