import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  GoogleMapController? _mapController;

  LatLng? selectedLatLng;
  LatLng? currentUserLatLng;
  String selectedAddress = '';

  bool isLoadingCurrentLocation = true;
  bool isLoadingAddress = false;

  static const LatLng defaultPosition = LatLng(13.7563, 100.5018);

  CameraPosition get _initialCameraPosition {
    if (widget.latitude != null && widget.longitude != null) {
      return CameraPosition(
        target: LatLng(widget.latitude!, widget.longitude!),
        zoom: 16,
      );
    }

    if (currentUserLatLng != null) {
      return CameraPosition(target: currentUserLatLng!, zoom: 16);
    }

    return const CameraPosition(target: defaultPosition, zoom: 14);
  }

  @override
  void initState() {
    super.initState();

    if (widget.latitude != null && widget.longitude != null) {
      selectedLatLng = LatLng(widget.latitude!, widget.longitude!);
      selectedAddress = widget.address ?? '';
    }

    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          isLoadingCurrentLocation = false;
          selectedLatLng ??= defaultPosition;
        });

        if (widget.isPickerMode && selectedAddress.isEmpty) {
          await _getAddressFromLatLng(selectedLatLng!);
        }
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          isLoadingCurrentLocation = false;
          selectedLatLng ??= defaultPosition;
        });

        if (widget.isPickerMode && selectedAddress.isEmpty) {
          await _getAddressFromLatLng(selectedLatLng!);
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final userPoint = LatLng(position.latitude, position.longitude);

      setState(() {
        currentUserLatLng = userPoint;
        isLoadingCurrentLocation = false;
        if (widget.isPickerMode && selectedLatLng == null) {
          selectedLatLng = userPoint;
        }
      });

      if (widget.isPickerMode &&
          selectedLatLng != null &&
          selectedAddress.isEmpty) {
        await _getAddressFromLatLng(selectedLatLng!);
      }

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(selectedLatLng ?? userPoint, 16),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingCurrentLocation = false;
        selectedLatLng ??= defaultPosition;
      });

      if (widget.isPickerMode && selectedAddress.isEmpty) {
        await _getAddressFromLatLng(selectedLatLng!);
      }
      debugPrint('Location error: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    if (!mounted) return;

    setState(() {
      isLoadingAddress = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final parts = <String>[
          if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
          if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
          if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          if ((p.administrativeArea ?? '').trim().isNotEmpty)
            p.administrativeArea!.trim(),
          if ((p.postalCode ?? '').trim().isNotEmpty) p.postalCode!.trim(),
          if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
        ];

        setState(() {
          selectedAddress =
              parts.isNotEmpty ? parts.join(', ') : 'ไม่พบข้อมูลที่อยู่';
        });
      } else {
        setState(() {
          selectedAddress = 'ไม่พบข้อมูลที่อยู่';
        });
      }
    } catch (e) {
      if (!mounted) return;
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

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (!widget.isPickerMode) {
      if (selectedLatLng != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('selected_location'),
            position: selectedLatLng!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(title: widget.markerTitle ?? 'ตำแหน่ง'),
          ),
        );
      }

      if (widget.caregiverLatitude != null &&
          widget.caregiverLongitude != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('caregiver_location'),
            position: LatLng(
              widget.caregiverLatitude!,
              widget.caregiverLongitude!,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: InfoWindow(
              title: widget.caregiverMarkerTitle ?? 'ตำแหน่งผู้ดูแล',
            ),
          ),
        );
      }
    }

    return markers;
  }

  Future<void> _goToMyLocation() async {
    if (currentUserLatLng == null || _mapController == null) return;
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(currentUserLatLng!, 16),
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
              onPressed: _goToMyLocation,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  myLocationEnabled: !isViewMode,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: _buildMarkers(),
                  onMapCreated: (controller) async {
                    _mapController = controller;

                    final target =
                        selectedLatLng ?? currentUserLatLng ?? defaultPosition;
                    await _mapController!.moveCamera(
                      CameraUpdate.newLatLngZoom(target, 16),
                    );
                  },
                  onTap: isViewMode
                      ? null
                      : (position) async {
                          setState(() {
                            selectedLatLng = position;
                            selectedAddress = 'กำลังค้นหาที่อยู่...';
                          });
                          await _getAddressFromLatLng(position);
                        },
                  onLongPress: isViewMode
                      ? null
                      : (position) async {
                          setState(() {
                            selectedLatLng = position;
                            selectedAddress = 'กำลังค้นหาที่อยู่...';
                          });
                          await _getAddressFromLatLng(position);
                        },
                ),
                if (isViewMode && selectedLatLng == null)
                  const SizedBox.shrink(),
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
