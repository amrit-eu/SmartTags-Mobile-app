/// Official OceanOPS reference code lists used by the deploy/recover forms'
/// "Other fields" dropdowns (`method.code` and `endingCause.code` in the
/// Gateway `goos-passport-events` API contract).
abstract final class OceanopsCodes {
  /// Valid `method.code` values for a deployment event.
  static const List<String> deploymentMethodCodes = [
    'throw-over',
    'crane',
    'parachute',
    'toboggan',
    'manual',
    'unknown',
    'rope',
    'asfar',
    'ship',
    'snow-mobile',
  ];

  /// Valid `endingCause.code` values for a recovery event.
  static const List<String> endingCauseCodes = [
    'beached-platform',
    'battery-failure',
    'telemetry-issues',
    'bad-data',
    'platform-picked-up-by-a-ship',
    'vandalized',
    'no-investigation',
    'platform-permanently-under-sea-ice',
    'groundings-at-the-seafloor',
    'misc-hardware-issues',
    'software-issues',
    'oceanops-auto-closure',
    'end-of-life-drifting-at-surface',
    'deployment-issues',
    'manual-closure',
    'internal-vacuum-issues',
    'voluntary-recovery-of-the-platform',
    'hit-by-ship',
    'platform-damaged-by-a-leak',
    'anchor-broken-adrift',
    'electrical-issues',
    'hydraulic-issues',
    'ballast-issues',
    'bluetooth-problem',
    'positioning-issues',
    'battery-exhausted',
    'defect-of-the-primary-ctd-sensor',
    'unknown',
    'altimeter-issue',
  ];
}
