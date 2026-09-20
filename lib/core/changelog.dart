/// Historial de versiones de la app (Ajustes > Acerca de).
///
/// Se actualiza a mano con cada entrega: una entrada nueva aquí Y la misma
/// entrada en `CHANGELOG.md`, en la raíz del proyecto -- mismo contenido en
/// los dos sitios, uno para leer dentro de la app y otro para verlo desde
/// fuera (o en el propio repositorio). Va de más reciente a más antigua.
library;

class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.changes,
  });

  final String version;
  final String date;
  final List<String> changes;
}

const appChangelog = <ChangelogEntry>[
  ChangelogEntry(
    version: '1.6.0+7',
    date: '19/09/2026',
    changes: [
      'Arreglado: el widget de la bolsa de caprichos se quedaba siempre '
          'en verde aunque el mes estuviera en negativo.',
      'El widget muestra ahora también una barra de progreso, igual que '
          'en Inicio, con lo gastado del margen disponible.',
    ],
  ),
  ChangelogEntry(
    version: '1.5.0+6',
    date: '19/09/2026',
    changes: [
      'Widget de pantalla de inicio del teléfono con la bolsa de '
          'caprichos disponible -- se actualiza al abrir la app y al '
          'tocarlo abre la app.',
    ],
  ),
  ChangelogEntry(
    version: '1.4.0+5',
    date: '19/09/2026',
    changes: [
      'Nueva pantalla "Acerca de" en Ajustes, con la versión instalada y '
          'este historial de cambios.',
    ],
  ),
  ChangelogEntry(
    version: '1.3.0+4',
    date: '19/09/2026',
    changes: [
      'Comparativa entre meses en el resumen de categorías de "Evolución '
          'del ahorro": cada categoría muestra si subió o bajó respecto al '
          'mes/ciclo anterior.',
    ],
  ),
  ChangelogEntry(
    version: '1.2.0+3',
    date: '01/09/2026',
    changes: [
      '"Mes de nómina a nómina": ajuste opcional en Ajustes > '
          'Personalización para que el "mes" de la app vaya de un día de '
          'cobro a otro en vez de por calendario.',
      'Resumen de ingresos y gastos por categoría, integrado en la '
          'pantalla "Evolución del ahorro".',
      'Arreglado: "Ahorro total" contaba dinero de nóminas o recurrentes '
          'que todavía no habían llegado.',
      'Arreglado: el aviso de mover el sobrante de caprichos a una hucha '
          'no aparecía si no tenías ninguna hucha creada.',
      'Arreglado: podían aparecer nóminas fantasma al activar "mes de '
          'nómina a nómina" con el día de cobro igual al día de inicio de '
          'mes.',
    ],
  ),
  ChangelogEntry(
    version: '1.1.0+2',
    date: '29/08/2026',
    changes: [
      'Huchas de ahorro: crear, meter/sacar dinero, meta opcional, '
          'aportación automática, pagar un gasto con una hucha, borrar '
          'una hucha.',
      'Ingresos puntuales, sin necesidad de crear un recurrente.',
      'Navegar a meses anteriores desde Inicio y Movimientos.',
      'Copia de seguridad y restaurar la base de datos.',
      'Aviso para mover el sobrante de caprichos del mes a una hucha.',
      'Ocultar y borrar categorías sin usar.',
      'Gráfica de evolución del ahorro.',
      'Margen de caprichos personalizable, y ajuste de si el ahorro '
          'total incluye las huchas.',
      'Varios arreglos de errores e interfaz (aportaciones a huchas '
          'duplicadas, avisos que parecían no desaparecer, compilación en '
          'Windows).',
    ],
  ),
  ChangelogEntry(
    version: '1.0.0+1',
    date: 'agosto 2026',
    changes: [
      'Primera versión: gastos e ingresos, categorías, accesos rápidos, '
          'recurrentes, saldo inicial, resumen mensual en Inicio, ajuste '
          'de cuadre, papelera con deshacer.',
    ],
  ),
];
