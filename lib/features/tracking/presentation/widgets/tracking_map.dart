import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_status.dart';

// إحداثيات وهمية في دمشق. تُستبدل بإحداثيات حقيقية من الـ API لاحقاً.
const _restaurantPoint = LatLng(33.5186, 36.2780);
const _customerPoint = LatLng(33.5010, 36.2540);

/// مدة رحلة السائق؛ تساوي stepDelay في FakeOrderRepository
/// كي يصل السائق مع صدور حالة "تم التسليم".
const _driverTravelDuration = Duration(seconds: 5);

class TrackingMap extends StatelessWidget {
  const TrackingMap({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    // 0 = عند المطعم، 1 = عند العميل
    final progress = switch (status) {
      OrderStatus.placed || OrderStatus.preparing => 0.0,
      OrderStatus.onTheWay || OrderStatus.delivered => 1.0,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 240,
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: LatLngBounds(_restaurantPoint, _customerPoint),
              padding: const EdgeInsets.all(48),
            ),
            // بلا تفاعل: السحب داخل ListView يتعارض مع التمرير
            interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hamza.bite_go',
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: progress),
              duration: _driverTravelDuration,
              builder: (context, t, _) {
                final driver = LatLng(
                  _restaurantPoint.latitude +
                      (_customerPoint.latitude - _restaurantPoint.latitude) * t,
                  _restaurantPoint.longitude +
                      (_customerPoint.longitude - _restaurantPoint.longitude) *
                          t,
                );
                return MarkerLayer(
                  markers: [
                    _marker(_restaurantPoint, Icons.storefront,
                        AppColors.secondary),
                    _marker(_customerPoint, Icons.location_on, AppColors.error),
                    _marker(driver, Icons.delivery_dining, AppColors.primary),
                  ],
                );
              },
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Marker _marker(LatLng point, IconData icon, Color color) => Marker(
      point: point,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, size: 22, color: color),
      ),
    );