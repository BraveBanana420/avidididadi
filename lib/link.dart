import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'avviso.dart';
import 'l10n/lingua.dart';

/// Apre un link esterno nel browser del telefono (non dentro l'app).
Future<void> apriLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok) {
    messenger.showSnackBar(avviso(content: Text(l10n.linkNonAperto)));
  }
}
