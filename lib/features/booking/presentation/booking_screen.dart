import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/constants.dart';
import '../data/mock_booking_repository.dart';
import '../domain/sacco.dart';
import 'dart:async';
import 'dart:math' as math;

enum BookingStep {
  formEntry,
  mapView,
  selectBus,
  bookSeat,
}

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with SingleTickerProviderStateMixin {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _repository = MockBookingRepository();
  final _mapController = MapController();
  
  BookingStep _currentStep = BookingStep.formEntry;
  bool _isLoading = false;
  
  List<Sacco> _availableVehicles = [];
  Sacco? _selectedVehicle;
  String? _selectedNumberPlate;

  Timer? _vehicleTimer;
  final LatLng _currentCenter = const LatLng(-1.2921, 36.8219);
  List<Marker> _vehicleMarkers = [];

  @override
  void initState() {
    super.initState();
    _destinationController.addListener(() => setState(() {}));
    _startVehicleSimulation();
  }

  @override
  void dispose() {
    _vehicleTimer?.cancel();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _startVehicleSimulation() {
    final random = math.Random();
    _generateVehicleMarkers(random);

    _vehicleTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) return;
      setState(() {
        _moveVehicles(random);
      });
    });
  }

  void _generateVehicleMarkers(math.Random random) {
    _vehicleMarkers = List.generate(4, (index) {
      double lat = _currentCenter.latitude + (random.nextDouble() - 0.5) * 0.05;
      double lng = _currentCenter.longitude + (random.nextDouble() - 0.5) * 0.05;
      
      return Marker(
        point: LatLng(lat, lng),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: index % 2 == 0 ? AppColors.yellow : AppColors.navy,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
              )
            ]
          ),
          child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
        ),
      );
    });
  }

  void _moveVehicles(math.Random random) {
    _vehicleMarkers = _vehicleMarkers.map((m) {
      double lat = m.point.latitude + (random.nextDouble() - 0.5) * 0.0005;
      double lng = m.point.longitude + (random.nextDouble() - 0.5) * 0.0005;
      
      return Marker(
        point: LatLng(lat, lng),
        width: m.width,
        height: m.height,
        child: m.child,
      );
    }).toList();
  }

  Future<void> _handleSearch() async {
    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 1));
    
    final vehicles = await _repository.getAvailableVehicles(
      _originController.text, 
      _destinationController.text
    );
    
    setState(() {
      _isLoading = false;
      _availableVehicles = vehicles;
      _currentStep = BookingStep.selectBus;
    });
  }

  void _selectVehicle(Sacco sacco) {
     final randomPlate =
        'K${String.fromCharCode(65 + DateTime.now().second % 26)}B ${100 + DateTime.now().millisecond % 899}';
        
    setState(() {
      _selectedVehicle = sacco;
      _selectedNumberPlate = randomPlate;
      _currentStep = BookingStep.bookSeat;
    });
  }

  void _proceedToPayment() {
    if (_selectedVehicle == null) return;
    
    context.push('/booking-confirmation', extra: {
      'sacco': _selectedVehicle!.name,
      'amount': _selectedVehicle!.price,
      'from': _selectedVehicle!.origin,
      'to': _selectedVehicle!.destination,
      'numberPlate': _selectedNumberPlate,
    });
  }

  void _goBack() {
    setState(() {
      if (_currentStep == BookingStep.bookSeat) {
        _currentStep = BookingStep.selectBus;
        _selectedVehicle = null;
      } else if (_currentStep == BookingStep.selectBus) {
        _currentStep = BookingStep.mapView;
        _availableVehicles = [];
      } else {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == BookingStep.formEntry) {
      return _buildFormEntryScreen();
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.komiut.app',
                  maxZoom: 18,
                  keepBuffer: 5,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentCenter,
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 20, height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 15, height: 15,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._vehicleMarkers,
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),
          
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
               onTap: _goBack,
               child: Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   shape: BoxShape.circle,
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.1),
                       blurRadius: 10,
                     )
                   ]
                 ),
                 child: const Icon(Icons.arrow_back, color: Colors.black),
               ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormEntryScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: const Text('Book a Trip', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Where From', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.yellow, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _originController,
                decoration: const InputDecoration(
                  hintText: 'Enter your location...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: Icon(Icons.my_location, color: AppColors.success),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Destination', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.yellow, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  hintText: 'Search by name or address...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: Icon(Icons.location_on, color: AppColors.error),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _destinationController.text.isEmpty ? null : () {
                  if (_originController.text.isEmpty) {
                    _originController.text = 'Current Location';
                  }
                  setState(() => _currentStep = BookingStep.mapView);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('CREATE TRIP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: _buildStepContent(),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case BookingStep.formEntry:
        return const SizedBox.shrink();
      case BookingStep.mapView:
        return _buildWhereToStep();
      case BookingStep.selectBus:
        return _buildSelectBusStep();
      case BookingStep.bookSeat:
        return _buildBookSeatStep();
    }
  }

  Widget _buildWhereToStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _handleSearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isLoading 
            ? const SizedBox(
                height: 24, width: 24, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : const Text(
                'Find Buses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
        ),
      ),
    );
  }

  Widget _buildSelectBusStep() {
    if (_availableVehicles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.directions_bus_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No buses found for "${_destinationController.text}"', 
              style: const TextStyle(color: Colors.grey)
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Available Buses', 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy)
            ),
          ),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              shrinkWrap: true,
              itemCount: _availableVehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final bus = _availableVehicles[index];
                return _buildBusCard(bus);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildBusCard(Sacco bus) {
    return GestureDetector(
      onTap: () => _selectVehicle(bus),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_bus, color: AppColors.navy),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bus.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                  const SizedBox(height: 4),
                  Text('${bus.seatsAvailable} seats left', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('KES ${bus.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                const SizedBox(height: 4),
                const Text('15 min away', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSeatStep() {
    if (_selectedVehicle == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _buildInfoItem('Distance', '12 km'),
               _buildInfoItem('Time', '25 min'),
               _buildInfoItem('Price', 'KES ${_selectedVehicle!.price.toInt()}'),
            ],
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text('BOOK SEAT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.navy)),
      ],
    );
  }
}
