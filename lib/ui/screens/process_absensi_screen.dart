import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../../data/services/absensi_service.dart';
import '../widgets/glossy_widgets.dart';

class ProcessAbsensiScreen extends StatefulWidget {
  final bool isCheckIn;

  const ProcessAbsensiScreen({super.key, required this.isCheckIn});

  @override
  State<ProcessAbsensiScreen> createState() => _ProcessAbsensiScreenState();
}

class _ProcessAbsensiScreenState extends State<ProcessAbsensiScreen> {
  final AbsensiService _absensiService = AbsensiService();
  GoogleMapController? _mapController;

  bool _isLoadingLocation = true;
  bool _isSubmitting = false;
  Position? _currentPosition;
  String _address = 'Mengambil alamat...';
  String? _errorMessage;

  static const Color _primaryText = Color(0xFF1E293B);
  static const Color _accentColor = Color(0xFF8EC5FC);
  static const Color _checkInColor = Color(0xFF34D399); // Emerald
  static const Color _checkOutColor = Color(0xFFFBBF24); // Amber

  // Dark mode map style
  static const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
  {"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},
  {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
  {"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},
  {"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
  {"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}
]
''';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Layanan lokasi dinonaktifkan.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen. Aktifkan di pengaturan.');
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _currentPosition = position);
      
      _getAddressFromLatLng(position);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _address = "${p.street}, ${p.subLocality}, ${p.locality}";
        });
      }
    } catch (e) {
      setState(() => _address = "Lokasi: ${position.latitude}, ${position.longitude}");
    }
  }

  Future<void> _submitAbsensi() async {
    if (_currentPosition == null) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final result = widget.isCheckIn
          ? await _absensiService.checkIn(
              latitude: _currentPosition!.latitude,
              longitude: _currentPosition!.longitude,
            )
          : await _absensiService.checkOut(
              latitude: _currentPosition!.latitude,
              longitude: _currentPosition!.longitude,
            );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Absen berhasil!'),
            backgroundColor: widget.isCheckIn ? _checkInColor.withOpacity(0.9) : _checkOutColor.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true); // Return true indicating success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal absen.'),
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isCheckIn ? 'Proses Absen Masuk' : 'Proses Absen Pulang';
    final actionColor = widget.isCheckIn ? _checkInColor : _checkOutColor;

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(

        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, color: _primaryText, fontSize: 20),
        ),
      ),
      body: GlossyBackground(
        child: _isLoadingLocation
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: _accentColor),
                    SizedBox(height: 16),
                    Text(
                      'Mendeteksi lokasi saat ini...',
                      style: TextStyle(color: _primaryText, fontSize: 16),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_off_rounded, size: 64, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _getLocation,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Map View
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          child: Stack(
                            children: [
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                  zoom: 17,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('current_location'),
                                    position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                    infoWindow: const InfoWindow(title: 'Lokasi Anda'),
                                  ),
                                },
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                  _mapController?.setMapStyle(_darkMapStyle);
                                },
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                mapToolbarEnabled: false,
                              ),
                              // Recenter button
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: FloatingActionButton(
                                  heroTag: 'btn_recenter',
                                  backgroundColor: Colors.black54,
                                  mini: true,
                                  child: const Icon(Icons.my_location_rounded, color: Colors.white),
                                  onPressed: () {
                                    _mapController?.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                          zoom: 17,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Info & Submit Action
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GlossyCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: actionColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(Icons.location_on_rounded, color: actionColor, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Lokasi Terdeteksi',
                                          style: TextStyle(color: _primaryText, fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _address,
                                          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitAbsensi,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: actionColor,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 8,
                                shadowColor: actionColor.withOpacity(0.4),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                    )
                                  : Text(
                                      "KONFIRMASI ${widget.isCheckIn ? 'MASUK' : 'PULANG'}",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                                    ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

