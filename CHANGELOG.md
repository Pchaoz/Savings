# Changelog

Historial de versiones de la app, de más reciente a más antigua. Se
actualiza con cada entrega (misma información que Ajustes > Acerca de,
dentro de la propia app). A partir de la 1.6.1, una entrega con
novedades se numera "X.Y" (p. ej. "1.6") y un arreglo sobre esa misma
entrega se numera "X.Y.Z" (p. ej. "1.6.1") -- antes siempre se veían
tres números más el número de build (p. ej. "1.6.0+7").

## [1.6.1] - 2026-09-20

### Cambiado
- Nuevo formato de número de versión (ver nota de arriba). Solo afecta
  a cómo se muestra la versión; no cambia ningún comportamiento de la
  app.

## [1.6] - 2026-09-19

### Añadido
- El widget de la bolsa de caprichos muestra ahora también una barra de
  progreso, igual que en Inicio, con lo gastado del margen disponible.

### Corregido
- El widget se quedaba siempre en verde aunque el mes estuviera en
  negativo; ahora sigue el mismo verde/rojo que "A CAPRICHOS" en Inicio.

## [1.5] - 2026-09-19

### Añadido
- Widget de pantalla de inicio del teléfono con la bolsa de caprichos
  disponible. Se actualiza al abrir la app (o mientras la tengas
  abierta y algo cambie), y tocarlo abre la app.

## [1.4] - 2026-09-19

### Añadido
- Nueva pantalla "Acerca de" en Ajustes, con la versión instalada y este
  historial de cambios.

## [1.3] - 2026-09-19

### Añadido
- Comparativa entre meses en el resumen de categorías de "Evolución del
  ahorro": cada categoría muestra si subió o bajó respecto al mes/ciclo
  anterior.

## [1.2] - 2026-09-01

### Añadido
- "Mes de nómina a nómina": ajuste opcional en Ajustes > Personalización
  para que el "mes" de la app vaya de un día de cobro a otro en vez de
  por calendario.
- Resumen de ingresos y gastos por categoría, integrado en la pantalla
  "Evolución del ahorro".

### Corregido
- "Ahorro total" contaba dinero de nóminas o recurrentes que todavía no
  habían llegado.
- El aviso de mover el sobrante de caprichos a una hucha no aparecía si
  no tenías ninguna hucha creada.
- Podían aparecer nóminas fantasma al activar "mes de nómina a nómina"
  con el día de cobro igual al día de inicio de mes.

## [1.1] - 2026-08-29

### Añadido
- Huchas de ahorro: crear, meter/sacar dinero, meta opcional, aportación
  automática, pagar un gasto con una hucha, borrar una hucha.
- Ingresos puntuales, sin necesidad de crear un recurrente.
- Navegar a meses anteriores desde Inicio y Movimientos.
- Copia de seguridad y restaurar la base de datos.
- Aviso para mover el sobrante de caprichos del mes a una hucha.
- Ocultar y borrar categorías sin usar.
- Gráfica de evolución del ahorro.
- Margen de caprichos personalizable, y ajuste de si el ahorro total
  incluye las huchas.

### Corregido
- Aportaciones automáticas a huchas que a veces se duplicaban la primera
  vez.
- Avisos (SnackBar) que parecían quedarse en pantalla al borrar o
  restaurar varios movimientos seguidos.
- Problema de compilación en Windows con el compilador incremental de
  Kotlin.
- Varios arreglos menores de interfaz (barra de navegación tapando
  botones, desbordamientos con el teclado).

## [1.0] - 2026-08

### Añadido
- Primera versión: gastos e ingresos, categorías, accesos rápidos,
  recurrentes, saldo inicial, resumen mensual en Inicio, ajuste de
  cuadre, papelera con deshacer.
