/// Historial de versiones de la app (Ajustes > Acerca de).
///
/// Se actualiza a mano con cada entrega: una entrada nueva aquí Y la misma
/// entrada en `CHANGELOG.md`, en la raíz del proyecto -- mismo contenido en
/// los dos sitios, uno para leer dentro de la app y otro para verlo desde
/// fuera (o en el propio repositorio). Va de más reciente a más antigua.
library;

/// Convierte la version tecnica de pubspec/Android (p. ej. "1.6.0" o
/// "1.6.1") en el formato que se muestra en la app y en el changelog:
/// sin el ".0" final cuando la entrega no trae ningun arreglo despues
/// de la version con novedades (p. ej. "1.6"), o con el tercer numero
/// tal cual cuando si es un arreglo sobre esa misma version (p. ej.
/// "1.6.1"). El numero de build (`+N`) nunca se muestra aqui.
String displayVersion(String pubspecVersion) {
  final base = pubspecVersion.split('+').first;
  final parts = base.split('.');
  if (parts.length == 3 && parts[2] == '0') {
    return '${parts[0]}.${parts[1]}';
  }
  return base;
}

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
    version: '1.7.1',
    date: '20/09/2026',
    changes: [
      'El tutorial guiado de Inicio pasa de señalar dos botones a ser un '
          'asistente que configura la app de verdad: ayuda a poner el '
          'saldo inicial, dar de alta la nómina (si cobras una) y '
          'ajustar el margen de caprichos.',
      'El asistente termina destacando las huchas de ahorro, la '
          'gráfica de evolución del ahorro y los recurrentes (gastos e '
          'ingresos que se repiten cada mes, trimestre o año), y '
          'después sigue con el mismo repaso guiado de la bolsa de '
          'caprichos y el botón de apuntar un gasto.',
      'Repetir el tutorial desde Ajustes ya no vuelve a pedir la '
          'nómina si ya la tenías configurada -- solo la enseña, para no '
          'crear una segunda por error.',
    ],
  ),
  ChangelogEntry(
    version: '1.7',
    date: '20/09/2026',
    changes: [
      'Tutorial guiado para quien abre la app por primera vez: señala la '
          'bolsa de caprichos y el botón de apuntar un gasto, con un paso '
          'a paso sencillo de "siguiente"/"saltar".',
      'Nuevo botón "Repetir tutorial" en Ajustes > Personalización, por '
          'si quieres volver a verlo.',
    ],
  ),
  ChangelogEntry(
    version: '1.6.1',
    date: '20/09/2026',
    changes: [
      'Nuevo formato de numero de version: una entrega con novedades se '
          'muestra como, por ejemplo, "1.6", y un arreglo sobre esa misma '
          'entrega se muestra como "1.6.1" (antes se veia siempre con tres '
          'numeros y el numero de build, tipo "1.6.0+7").',
    ],
  ),
  ChangelogEntry(
    version: '1.6',
    date: '19/09/2026',
    changes: [
      'Arreglado: el widget de la bolsa de caprichos se quedaba siempre '
          'en verde aunque el mes estuviera en negativo.',
      'El widget muestra ahora también una barra de progreso, igual que '
          'en Inicio, con lo gastado del margen disponible.',
    ],
  ),
  ChangelogEntry(
    version: '1.5',
    date: '19/09/2026',
    changes: [
      'Widget de pantalla de inicio del teléfono con la bolsa de '
          'caprichos disponible -- se actualiza al abrir la app y al '
          'tocarlo abre la app.',
    ],
  ),
  ChangelogEntry(
    version: '1.4',
    date: '19/09/2026',
    changes: [
      'Nueva pantalla "Acerca de" en Ajustes, con la versión instalada y '
          'este historial de cambios.',
    ],
  ),
  ChangelogEntry(
    version: '1.3',
    date: '19/09/2026',
    changes: [
      'Comparativa entre meses en el resumen de categorías de "Evolución '
          'del ahorro": cada categoría muestra si subió o bajó respecto al '
          'mes/ciclo anterior.',
    ],
  ),
  ChangelogEntry(
    version: '1.2',
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
    version: '1.1',
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
    version: '1.0',
    date: 'agosto 2026',
    changes: [
      'Primera versión: gastos e ingresos, categorías, accesos rápidos, '
          'recurrentes, saldo inicial, resumen mensual en Inicio, ajuste '
          'de cuadre, papelera con deshacer.',
    ],
  ),
];
