# Savings — control de gastos personales

App Android de control de gastos y ahorro, hecha a medida a partir del
presupuesto que antes se llevaba en una hoja de Excel. Funciona
**100% offline**: todos los datos se guardan en una base de datos local en
el propio teléfono, sin cuentas ni sincronización en la nube.

> Proyecto personal en desarrollo activo. Hecho con Flutter, para Android.

## Índice

- [Qué hace la app](#qué-hace-la-app)
- [Capturas](#capturas)
- [Stack técnico](#stack-técnico)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Requisitos previos](#requisitos-previos)
- [Instalación y puesta en marcha](#instalación-y-puesta-en-marcha)
- [Compilar un APK](#compilar-un-apk)
- [Actualizar la app (migraciones de base de datos)](#actualizar-la-app-migraciones-de-base-de-datos)
- [Copia de seguridad y restauración](#copia-de-seguridad-y-restauración)
- [Widget de pantalla de inicio](#widget-de-pantalla-de-inicio)
- [Versionado y changelog](#versionado-y-changelog)
- [Estado del proyecto](#estado-del-proyecto)
- [Aviso sobre la firma del APK](#aviso-sobre-la-firma-del-apk)
- [Licencia](#licencia)

## Qué hace la app

La idea de base: cada mes hay unos ingresos fijos, unos gastos fijos y
unos gastos variables. Con lo que sobra de verdad (ingresos − gastos), se
aparta automáticamente un 10% (configurable) a una "bolsa de caprichos" —
el dinero que te puedes gastar en cosas no esenciales sin sentir que
descuadras nada. El resto es ahorro real.

A partir de esa idea, la app cubre:

- **Apuntar un gasto o ingreso en pocos segundos**, con categorías y
  accesos rápidos personalizables.
- **Bolsa de caprichos** calculada automáticamente cada mes, con barra de
  progreso de lo gastado.
- **Ingresos y gastos recurrentes** (nómina, suscripciones, etc.) que se
  generan solos cada mes, sin tener que apuntarlos a mano.
- **Editar, eliminar y devolver movimientos**, con la distinción real
  entre "me equivoqué al apuntarlo" (se borra) y "me han devuelto el
  dinero" (se registra como una devolución enlazada al gasto original,
  sin reescribir el pasado).
- **Papelera** de movimientos eliminados (30 días) con opción de
  restaurar y deshacer.
- **Huchas de ahorro** con nombre propio y meta opcional (p. ej. "Ahorro
  Japón"), con aportaciones manuales o automáticas mensuales, sin que eso
  reduzca el ahorro calculado ese mes — es solo separar mentalmente
  dinero que sigue siendo tuyo. Se puede incluso pagar un gasto
  directamente con el dinero de una hucha.
- **Navegar a meses anteriores** para consultar el cierre de cualquier
  mes pasado.
- **Categorías propias**: crear, ocultar o borrar categorías (borrado
  bloqueado si tienen movimientos o son la única de su tipo).
- **Ajustar saldo** para corregir descuadres puntuales entre la app y el
  saldo real.
- **Gráfica de evolución del ahorro** mes a mes.
- **Copia de seguridad y restauración** de toda la base de datos.
- **Widget de pantalla de inicio de Android** con el disponible actual de
  la bolsa de caprichos y una barra de progreso.

Todo se recalcula siempre desde los movimientos guardados — no hay
totales "guardados" en ningún sitio que puedan desincronizarse.

## Capturas

_Pendiente de añadir capturas de pantalla reales del teléfono._

## Stack técnico

- **Flutter** (Dart), únicamente para **Android** por ahora.
- **Gestor de estado**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`).
- **Persistencia**: [Drift](https://drift.simonbinder.eu/) (ORM sobre
  SQLite), vía `drift_flutter`.
- **Widget de Android nativo**: `AppWidgetProvider` + `RemoteViews`
  escrito directamente en Kotlin (sin ningún paquete de Flutter de
  terceros), comunicado con Dart mediante un `MethodChannel` propio.
- Sin backend, sin cuentas, sin conexión a internet en ningún momento.

## Estructura del proyecto

```
lib/
├── app/          # Pantallas y providers de Riverpod (UI)
├── core/         # Utilidades (dinero en céntimos, tema visual, changelog)
├── data/         # Base de datos Drift, esquema y repositorio
└── domain/       # Motor de cálculo puro (sin dependencias de Flutter)

android/          # Proyecto Android nativo (widget, manifest, gradle)
test/             # Tests del motor de cálculo y del repositorio
```

El motor de cálculo (`lib/domain/engine/month_calculator.dart`) es
código Dart puro, sin ninguna dependencia de Flutter ni de la base de
datos — se puede testear de forma aislada, y así se hizo desde el
principio del proyecto (ver tests en `test/engine/`).

## Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal
  estable; el proyecto usa Dart ^3.11.4).
- Android Studio o VSCode con las extensiones de Flutter/Dart.
- Un dispositivo Android físico (con depuración USB activada) o un
  emulador.

Comprobar que todo está bien instalado:

```bash
flutter doctor
```

## Instalación y puesta en marcha

```bash
# 1. Clonar el repositorio
git clone https://github.com/Pchaoz/savings.git
cd savings

# 2. Instalar dependencias
flutter pub get

# 3. Generar el código de Drift (obligatorio la primera vez,
#    y cada vez que cambie el esquema de la base de datos)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Ejecutar en un dispositivo o emulador conectado
flutter run
```

Si `flutter run` falla justo después de tocar algún fichero de la
carpeta `lib/data/` (tablas, base de datos), lo primero a probar siempre
es repetir el paso 3 — es la causa más habitual.

## Compilar un APK

Para generar un APK instalable directamente (sin pasar por `flutter run`):

```bash
flutter build apk --release
```

El APK resultante queda en
`build/app/outputs/flutter-apk/app-release.apk`.

## Actualizar la app (migraciones de base de datos)

La base de datos usa migraciones reales (`onUpgrade` de Drift): al
instalar una versión nueva encima de una instalada, los datos existentes
se conservan y se adaptan solos al nuevo esquema. **No hace falta
desinstalar la app para actualizar.**

Al desarrollar: cada vez que cambia algo en `lib/data/tables.dart` o se
sube `schemaVersion` en `lib/data/database.dart`, hay que volver a correr:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Copia de seguridad y restauración

Desde **Ajustes**:

- **Copia de seguridad**: genera un volcado completo y consistente de la
  base de datos (con `VACUUM INTO`, así que funciona aunque la app esté
  en uso) y lo comprime como `.zip` para poder compartirlo por
  WhatsApp, Drive, correo, etc. sin que Android le cambie la extensión.
- **Restaurar copia de seguridad**: pide confirmación explícita (la
  operación sobrescribe todos los datos actuales y no se puede deshacer
  desde la app) y, antes de tocar nada, genera automáticamente una copia
  de los datos actuales por si acaso. Después deja elegir el fichero
  `.zip` (o `.sqlite`/`.bin` de copias antiguas) a restaurar.

Se recomienda hacer una copia de seguridad de vez en cuando y guardarla
fuera del teléfono (Drive, correo propio, etc.), ya que toda la
información vive únicamente en el dispositivo.

## Widget de pantalla de inicio

Se puede añadir un widget a la pantalla de inicio de Android que muestra
el disponible actual de la bolsa de caprichos, con una barra de progreso
(verde si queda margen, roja si el mes va en números rojos) y con un toque
abre la app directamente. Se actualiza solo cada vez que se abre la app.

## Versionado y changelog

El proyecto sigue un versionado tipo `MAYOR.MENOR.PARCHE+build`
(`pubspec.yaml`). Cada entrega, por pequeña que sea, sube al menos el
número de build, y añade su propia entrada en dos sitios que deben
mantenerse siempre sincronizados:

- [`CHANGELOG.md`](./CHANGELOG.md) — histórico completo en la raíz del
  proyecto.
- `lib/core/changelog.dart` — la misma información, mostrada dentro de la
  propia app en **Ajustes > Acerca de**.

## Estado del proyecto

El MVP (sustituir por completo el Excel) se dio por cumplido el
28/08/2026. Desde entonces el desarrollo sigue activo, añadiendo mejoras
por encima del objetivo mínimo: huchas de ahorro, navegación por meses
anteriores, copia de seguridad y restauración, gráfica de evolución del
ahorro, y el widget de pantalla de inicio, entre otras.

## Aviso sobre la firma del APK

Por ahora, los APKs de release se firman con la **clave de depuración
(debug)** de Android, no con una clave de firma propia — suficiente para
uso personal e instalación manual, pero a tener en cuenta si en algún
momento se quisiera distribuir la app de forma más amplia (p. ej. Google
Play), donde hace falta una clave de release propia.

## Licencia

_Pendiente de decidir._
