/// Ajustes > Acerca de: qué versión de la app tienes instalada ahora
/// mismo y qué ha cambiado en cada versión, de más reciente a más
/// antigua. El historial vive en `core/changelog.dart` -- se actualiza a
/// mano con cada entrega, junto con `CHANGELOG.md` en la raíz del
/// proyecto (mismo contenido, para poder verlo también fuera de la app).
library;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/changelog.dart';
import '../core/theme/tokens.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: const Text('Acerca de')),
      body: SafeArea(
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final info = snapshot.data;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: C.raised,
                    borderRadius: BorderRadius.circular(R.container),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info?.appName ?? 'savings', style: T.amountLarge),
                      const SizedBox(height: 4),
                      Text(
                        info == null
                            ? 'Cargando versión…'
                            : 'Versión ${info.version} (build ${info.buildNumber})',
                        style: T.body.copyWith(color: C.inkDim),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('HISTORIAL DE CAMBIOS', style: T.eyebrow),
                const SizedBox(height: 10),
                for (final entry in appChangelog) ...[
                  _ChangelogCard(entry: entry),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChangelogCard extends StatelessWidget {
  const _ChangelogCard({required this.entry});

  final ChangelogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(R.container),
        border: Border.all(color: C.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'v${entry.version}',
                style: T.body.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(entry.date, style: T.meta),
            ],
          ),
          const SizedBox(height: 10),
          for (final change in entry.changes)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: T.body.copyWith(color: C.inkDim)),
                  Expanded(child: Text(change, style: T.body)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
