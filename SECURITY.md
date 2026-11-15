# Security policy

## Supported versions

Only the latest release on the
[Releases](https://github.com/BraveBanana420/avidididadi/releases) page gets
security fixes.

## Reporting a vulnerability

**Please don't open a public issue for security problems.** Report them
privately on GitHub: go to the **Security** tab of this repository and click
**Report a vulnerability**. Only the maintainer sees the report.

Include, if you can: the app version, what an attacker could do, and the steps
to reproduce. Do not include your own backup, CSV files, GPX tracks or API
keys.

You'll get an answer within 14 days. When the fix is released, you'll be
credited in the release notes unless you prefer not to be.

## What counts

Examples of what we care about most, because the app handles health and
location data:

- data leaving the phone without the user's choice (CSV files, routes, health
  data, API keys);
- API keys readable outside `flutter_secure_storage` (files, backups, logs);
- other apps able to start a workout, inject text into the assistant or read
  the app's files;
- a crafted backup, CSV or GPX file that crashes the app or corrupts data;
- the release APK signed with the wrong key.
