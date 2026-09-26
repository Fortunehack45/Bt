import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/solid_wellness_card.dart';
import '../../core/services/wearable_device_service.dart';
import '../../domain/models/smart_device_models.dart';
import '../../domain/state/wellness_provider.dart';

/// Command Center for Smart Watches, Smart Rings, and Health Sensors.
/// Tracks Blood Pressure, Heart Rate, Body Temperature, Steps, SpO2, and HRV.
class WearablesHubScreen extends StatefulWidget {
  final VoidCallback onBack;

  const WearablesHubScreen({super.key, required this.onBack});

  @override
  State<WearablesHubScreen> createState() => _WearablesHubScreenState();
}

class _WearablesHubScreenState extends State<WearablesHubScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  late Animation<double> _radarAnimation;
  bool _isSyncing = false;
  StreamSubscription? _telemetrySub;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _radarAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeInOut),
    );

    // Subscribe to live telemetry stream updates
    _telemetrySub = WearableDeviceService.instance.telemetryStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _telemetrySub?.cancel();
    super.dispose();
  }

  Future<void> _handleManualSync(WellnessProvider provider) async {
    setState(() => _isSyncing = true);
    await WearableDeviceService.instance.syncDeviceTelemetry(provider);
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${provider.activeDevice?.name ?? "Wearable"} synchronized successfully',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = WellnessStateScope.of(context);
    final activeDevice = provider.activeDevice;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: ResponsiveLayout.pageContainer(
        context: context,
        padding: EdgeInsets.zero,
        topSafeArea: true,
        bottomSafeArea: false,
        child: Column(
          children: [
            ScreenHeader(
              title: 'Smart Devices & Hub',
              subtitle: 'Rings, Watches & Biometrics',
              onLeadingTap: widget.onBack,
              trailing: IconButton(
                icon: const Icon(Icons.radar_rounded, size: 22),
                tooltip: 'Scan for Devices',
                color: const Color(0xFF10B981),
                onPressed: () {
                  WearableDeviceService.instance.startScan();
                  _showScanBottomSheet(context, provider);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: AppSpacing.pageMargin,
                  right: AppSpacing.pageMargin,
                  top: AppSpacing.xs,
                  bottom: AppSpacing.contentBottomPadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Active Device Hero Card
                    _buildActiveDeviceCard(context, provider, activeDevice, isDark),
                    const SizedBox(height: 20),

                    // 2. Section Header: Live Multi-Sensor Telemetry
                    Row(
                      children: [
                        Text(
                          'LIVE BIOMETRIC TELEMETRY',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.bolt_rounded, size: 12, color: Color(0xFF10B981)),
                              SizedBox(width: 4),
                              Text(
                                'LIVE STREAM',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3. 2x2 Telemetry Grid: BP, Heart Rate, Temperature, Blood Oxygen
                    _buildTelemetryGrid(provider, isDark),
                    const SizedBox(height: 24),

                    // 4. Paired Devices Management Section
                    _buildPairedDevicesSection(context, provider, isDark),
                    const SizedBox(height: 24),

                    // 5. Stream Simulation & Diagnostics Card
                    _buildDiagnosticsCard(provider, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeviceCard(
    BuildContext context,
    WellnessProvider provider,
    SmartDevice? device,
    bool isDark,
  ) {
    const brandEmerald = Color(0xFF10B981);

    if (device == null) {
      return SolidWellnessCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brandEmerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bluetooth_searching_rounded, size: 36, color: brandEmerald),
            ),
            const SizedBox(height: 14),
            Text(
              'No Smart Device Connected',
              style: AppTypography.h3(isDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Pair your Smart Ring (Oura, Ultrahuman, Galaxy) or Smart Watch (Apple Watch, Wear OS, Garmin) for continuous health telemetry.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(isDark),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                WearableDeviceService.instance.startScan();
                _showScanBottomSheet(context, provider);
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Pair Device Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandEmerald,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return SolidWellnessCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: brandEmerald.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandEmerald.withValues(alpha: 0.35), width: 1.2),
                ),
                child: Icon(device.type.icon, color: brandEmerald, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2B22) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            device.brand.displayName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Battery indicator
                        Row(
                          children: [
                            Icon(
                              device.batteryLevel > 20
                                  ? Icons.battery_charging_full_rounded
                                  : Icons.battery_alert_rounded,
                              size: 16,
                              color: device.batteryLevel > 20 ? brandEmerald : Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${device.batteryLevel}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.name,
                      style: AppTypography.h3(isDark).copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Connected • Live Synced',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: brandEmerald,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.sync_rounded, size: 14, color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 6),
              Text(
                'Last synced just now',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isSyncing ? null : () => _handleManualSync(provider),
                icon: _isSyncing
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh_rounded, size: 14),
                label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandEmerald,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid(WellnessProvider provider, bool isDark) {
    return Column(
      children: [
        // Row 1: Blood Pressure & Heart Rate
        Row(
          children: [
            // Blood Pressure Card
            Expanded(
              child: _buildMetricTile(
                title: 'BLOOD PRESSURE',
                value: '${provider.systolicBp}/${provider.diastolicBp}',
                unit: 'mmHg',
                subtitle: provider.bpCategory.label,
                badgeColor: provider.bpCategory.color,
                icon: Icons.monitor_heart_rounded,
                isDark: isDark,
                onTap: () => _showManualBpDialog(context, provider),
              ),
            ),
            const SizedBox(width: 12),

            // Heart Rate & HRV Card
            Expanded(
              child: _buildMetricTile(
                title: 'HEART BEAT',
                value: '${provider.bpm > 0 ? provider.bpm : 72}',
                unit: 'BPM',
                subtitle: 'HRV: ${provider.hrvMs} ms',
                badgeColor: const Color(0xFFEF4444),
                icon: Icons.favorite_rounded,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Body Temperature & Blood Oxygen
        Row(
          children: [
            // Body Temperature Card
            Expanded(
              child: _buildMetricTile(
                title: 'TEMPERATURE',
                value: '${provider.bodyTemperatureCelsius.toStringAsFixed(1)}°C',
                unit: '${provider.bodyTemperatureFahrenheit.toStringAsFixed(1)}°F',
                subtitle: 'Basal: Optimal',
                badgeColor: const Color(0xFFF59E0B),
                icon: Icons.device_thermostat_rounded,
                isDark: isDark,
                onTap: () => _showManualTempDialog(context, provider),
              ),
            ),
            const SizedBox(width: 12),

            // Blood Oxygen (SpO2) Card
            Expanded(
              child: _buildMetricTile(
                title: 'BLOOD OXYGEN',
                value: '${provider.bloodOxygenSpO2}%',
                unit: 'SpO2',
                subtitle: 'Resting Pulse Ox',
                badgeColor: const Color(0xFF2EB5FA),
                icon: Icons.air_rounded,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required Color badgeColor,
    required IconData icon,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161E18) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF233025) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: badgeColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: badgeColor, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPairedDevicesSection(
    BuildContext context,
    WellnessProvider provider,
    bool isDark,
  ) {
    final devices = provider.connectedDevices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PAIRED HARDWARE (${devices.length})',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                WearableDeviceService.instance.startScan();
                _showScanBottomSheet(context, provider);
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Device', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...devices.map((device) {
          final isSelected = provider.activeDevice?.id == device.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161E18) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF10B981)
                    : (isDark ? const Color(0xFF233025) : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.4 : 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(device.type.icon, color: const Color(0xFF10B981), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${device.brand.displayName} • ${device.batteryLevel}% Battery',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 20, color: isDark ? Colors.white54 : Colors.black54),
                  onSelected: (val) {
                    if (val == 'disconnect') {
                      WearableDeviceService.instance.disconnectDevice(device, provider);
                    } else if (val == 'set_active') {
                      provider.pairDevice(device);
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (!isSelected)
                      const PopupMenuItem(value: 'set_active', child: Text('Set as Active Device')),
                    const PopupMenuItem(value: 'disconnect', child: Text('Disconnect Device')),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDiagnosticsCard(WellnessProvider provider, bool isDark) {
    const brandEmerald = Color(0xFF10B981);
    return SolidWellnessCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stream_rounded, color: brandEmerald, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sensor Stream & Auto-Sync',
                style: AppTypography.bodyLarge(isDark).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Keep Bluetooth Low Energy GATT health sync active for real-time background vitals updates.',
            style: AppTypography.bodySmall(isDark),
          ),
          const SizedBox(height: 14),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Live Telemetry Streaming', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Continuous micro-updates for BP, BPM & Temp', style: TextStyle(fontSize: 11)),
            activeColor: brandEmerald,
            value: provider.isAutoSyncEnabled,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              provider.toggleAutoSync(val);
              if (val) {
                WearableDeviceService.instance.startLiveTelemetryStream(provider);
              } else {
                WearableDeviceService.instance.stopLiveTelemetryStream();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showScanBottomSheet(BuildContext context, WellnessProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const brandEmerald = Color(0xFF10B981);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131A15) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? const Color(0xFF233025) : const Color(0xFFE2E8F0),
            ),
          ),
          child: StreamBuilder<List<SmartDevice>>(
            stream: WearableDeviceService.instance.discoveryStream,
            initialData: WearableDeviceService.instance.discoveredDevices,
            builder: (context, snapshot) {
              final discovered = snapshot.data ?? [];
              return Column(
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        ScaleTransition(
                          scale: _radarAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: brandEmerald.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.radar_rounded, color: brandEmerald, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nearby Smart Devices',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Scanning for Smart Rings, Watches & Cuffs...',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24, thickness: 0.6),
                  Expanded(
                    child: discovered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircularProgressIndicator(color: brandEmerald),
                                SizedBox(height: 16),
                                Text('Scanning Bluetooth Low Energy peripherals...'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: discovered.length,
                            itemBuilder: (context, index) {
                              final dev = discovered[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF19221C) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF263329) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(dev.type.icon, color: brandEmerald, size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dev.name,
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                          ),
                                          Text(
                                            '${dev.brand.displayName} • ${dev.macAddressOrUuid ?? ""}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        WearableDeviceService.instance.pairDevice(dev, provider);
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: brandEmerald,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedPill),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      ),
                                      child: const Text('Pair'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showManualBpDialog(BuildContext context, WellnessProvider provider) {
    final sysCtrl = TextEditingController(text: provider.systolicBp.toString());
    final diaCtrl = TextEditingController(text: provider.diastolicBp.toString());

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Blood Pressure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sysCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Systolic (mmHg)', hintText: '120'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: diaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Diastolic (mmHg)', hintText: '80'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final sys = int.tryParse(sysCtrl.text);
              final dia = int.tryParse(diaCtrl.text);
              if (sys != null && dia != null) {
                provider.recordBloodPressure(sys, dia);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showManualTempDialog(BuildContext context, WellnessProvider provider) {
    final tempCtrl = TextEditingController(text: provider.bodyTemperatureCelsius.toString());

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Body Temperature'),
        content: TextField(
          controller: tempCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Temperature (°C)', hintText: '36.6'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final temp = double.tryParse(tempCtrl.text);
              if (temp != null) {
                provider.recordBodyTemperature(temp);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
