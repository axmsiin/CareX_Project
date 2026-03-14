import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class map extends StatefulWidget {
  final bool isPickerMode;

  final double? latitude;
  final double? longitude;
  final String? address;
  final String? markerTitle;

  final double? caregiverLatitude;
  final double? caregiverLongitude;
  final String? caregiverMarkerTitle;

  const map({
    super.key,
    this.isPickerMode = true,
    this.latitude,
    this.longitude,
    this.address,
    this.markerTitle,
    this.caregiverLatitude,
    this.caregiverLongitude,
    this.caregiverMarkerTitle,
  });

  @override
  State<map> createState() => _mapState();
}

class _mapState extends State<map> {
  final MapController _mapController = MapController();

  latlng.LatLng? selectedLatLng;
  latlng.LatLng? currentUserLatLng;
  String selectedAddress = '';

  bool isLoadingCurrentLocation = true;
  bool isLoadingAddress = false;
  bool mapReady = false;

  final latlng.LatLng defaultPosition = const latlng.LatLng(13.7563, 100.5018);

  latlng.LatLng get _initialPosition {
    if (widget.latitude != null && widget.longitude != null) {
      return latlng.LatLng(widget.latitude!, widget.longitude!);
    }
    if (currentUserLatLng != null) {
      return currentUserLatLng!;
    }
    return defaultPosition;
  }

  @override
  void initState() {
    super.initState();

    if (!widget.isPickerMode &&
        widget.latitude != null &&
        widget.longitude != null) {
      selectedLatLng = latlng.LatLng(widget.latitude!, widget.longitude!);
      selectedAddress = widget.address ?? '';
    }

    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          isLoadingCurrentLocation = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          isLoadingCurrentLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final userPoint = latlng.LatLng(position.latitude, position.longitude);

      setState(() {
        currentUserLatLng = userPoint;
        isLoadingCurrentLocation = false;

        // ถ้าเป็นโหมดเลือกตำแหน่ง ให้ใช้ตำแหน่งปัจจุบันเป็นจุดเริ่มต้นเลย
        if (widget.isPickerMode && selectedLatLng == null) {
          selectedLatLng = userPoint;
        }
      });

      if (widget.isPickerMode && selectedAddress.isEmpty) {
        await _getAddressFromLatLng(userPoint);
      }

      _moveToCurrentLocationIfPossible();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingCurrentLocation = false;
      });
      debugPrint('Location error: $e');
    }
  }

  void _moveToCurrentLocationIfPossible() {
    if (!mapReady) return;
    if (currentUserLatLng == null) return;

    if (widget.isPickerMode) {
      _mapController.move(currentUserLatLng!, 16);
    } else {
      _fitBoundsIfNeeded();
    }
  }

  Future<void> _getAddressFromLatLng(latlng.LatLng position) async {
    setState(() {
      isLoadingAddress = true;
    });

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2'
        '&lat=${position.latitude}'
        '&lon=${position.longitude}'
        '&accept-language=th',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'carex-app/1.0 (contact: carex@example.com)',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final displayName = (data['display_name'] ?? '').toString().trim();

        setState(() {
          selectedAddress = displayName.isNotEmpty
              ? displayName
              : 'ไม่พบข้อมูลที่อยู่';
        });
      } else {
        setState(() {
          selectedAddress = 'ไม่สามารถดึงที่อยู่ได้';
        });
        debugPrint('Reverse geocoding failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        selectedAddress = 'ไม่สามารถดึงที่อยู่ได้';
      });
      debugPrint('Reverse geocoding error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingAddress = false;
        });
      }
    }
  }

  String _extractProvince(String address) {
    const provinces = [
      'กรุงเทพมหานคร',
      'กระบี่',
      'กาญจนบุรี',
      'กาฬสินธุ์',
      'กำแพงเพชร',
      'ขอนแก่น',
      'จันทบุรี',
      'ฉะเชิงเทรา',
      'ชลบุรี',
      'ชัยนาท',
      'ชัยภูมิ',
      'ชุมพร',
      'เชียงราย',
      'เชียงใหม่',
      'ตรัง',
      'ตราด',
      'ตาก',
      'นครนายก',
      'นครปฐม',
      'นครพนม',
      'นครราชสีมา',
      'นครศรีธรรมราช',
      'นครสวรรค์',
      'นนทบุรี',
      'นราธิวาส',
      'น่าน',
      'บึงกาฬ',
      'บุรีรัมย์',
      'ปทุมธานี',
      'ประจวบคีรีขันธ์',
      'ปราจีนบุรี',
      'ปัตตานี',
      'พระนครศรีอยุธยา',
      'พังงา',
      'พัทลุง',
      'พิจิตร',
      'พิษณุโลก',
      'เพชรบุรี',
      'เพชรบูรณ์',
      'แพร่',
      'พะเยา',
      'ภูเก็ต',
      'มหาสารคาม',
      'มุกดาหาร',
      'แม่ฮ่องสอน',
      'ยโสธร',
      'ยะลา',
      'ร้อยเอ็ด',
      'ระนอง',
      'ระยอง',
      'ราชบุรี',
      'ลพบุรี',
      'ลำปาง',
      'ลำพูน',
      'เลย',
      'ศรีสะเกษ',
      'สกลนคร',
      'สงขลา',
      'สตูล',
      'สมุทรปราการ',
      'สมุทรสงคราม',
      'สมุทรสาคร',
      'สระแก้ว',
      'สระบุรี',
      'สิงห์บุรี',
      'สุโขทัย',
      'สุพรรณบุรี',
      'สุราษฎร์ธานี',
      'สุรินทร์',
      'หนองคาย',
      'หนองบัวลำภู',
      'อ่างทอง',
      'อำนาจเจริญ',
      'อุดรธานี',
      'อุตรดิตถ์',
      'อุทัยธานี',
      'อุบลราชธานี',
    ];

    for (final province in provinces) {
      if (address.contains(province)) {
        return province;
      }
    }
    return '';
  }

  void _confirmLocation() {
    if (selectedLatLng == null || selectedAddress.isEmpty) return;

    final province = _extractProvince(selectedAddress);

    Navigator.pop(context, {
      'address': selectedAddress,
      'province': province,
      'latitude': selectedLatLng!.latitude,
      'longitude': selectedLatLng!.longitude,
    });
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (currentUserLatLng != null) {
      markers.add(
        Marker(
          point: currentUserLatLng!,
          width: 60,
          height: 60,
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 28,
          ),
        ),
      );
    }

    if (selectedLatLng != null) {
      markers.add(
        Marker(
          point: selectedLatLng!,
          width: 70,
          height: 70,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 42,
          ),
        ),
      );
    }

    if (widget.caregiverLatitude != null && widget.caregiverLongitude != null) {
      markers.add(
        Marker(
          point: latlng.LatLng(
            widget.caregiverLatitude!,
            widget.caregiverLongitude!,
          ),
          width: 70,
          height: 70,
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 42,
          ),
        ),
      );
    }

    return markers;
  }

  void _fitBoundsIfNeeded() {
    final points = <latlng.LatLng>[];

    if (selectedLatLng != null) points.add(selectedLatLng!);
    if (currentUserLatLng != null) points.add(currentUserLatLng!);

    if (widget.caregiverLatitude != null && widget.caregiverLongitude != null) {
      points.add(
        latlng.LatLng(widget.caregiverLatitude!, widget.caregiverLongitude!),
      );
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          latlng.LatLng(minLat, minLng),
          latlng.LatLng(maxLat, maxLng),
        ),
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isViewMode = !widget.isPickerMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isViewMode ? 'ตำแหน่งบนแผนที่' : 'เลือกตำแหน่ง'),
        actions: [
          if (currentUserLatLng != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                _mapController.move(currentUserLatLng!, 16);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialPosition,
                initialZoom: 14,
                onMapReady: () {
                  mapReady = true;
                  _moveToCurrentLocationIfPossible();
                },
                onTap: isViewMode
                    ? null
                    : (tapPosition, point) async {
                        setState(() {
                          selectedLatLng = point;
                          selectedAddress = 'กำลังค้นหาที่อยู่...';
                        });
                        await _getAddressFromLatLng(point);
                      },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.carex',
                ),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoadingCurrentLocation)
                  const Text('กำลังค้นหาตำแหน่งปัจจุบัน...')
                else if (isLoadingAddress)
                  const Text('กำลังค้นหาที่อยู่...')
                else
                  Text(
                    selectedAddress.isEmpty
                        ? (currentUserLatLng != null
                              ? 'เจอตำแหน่งปัจจุบันแล้ว สามารถกดยืนยันได้เลย หรือแตะบนแผนที่เพื่อเปลี่ยนตำแหน่ง'
                              : isViewMode
                              ? 'ไม่มีข้อมูลที่อยู่'
                              : 'ยังไม่พบตำแหน่งปัจจุบัน กรุณาเปิดสิทธิ์ location แล้วลองใหม่ หรือแตะบนแผนที่เพื่อปักหมุด')
                        : selectedAddress,
                    style: const TextStyle(fontSize: 14),
                  ),
                const SizedBox(height: 12),
                if (!isViewMode)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          selectedLatLng == null || selectedAddress.isEmpty
                          ? null
                          : _confirmLocation,
                      child: const Text('ยืนยันตำแหน่ง'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}