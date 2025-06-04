import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonbook/models/model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salonbook/models/service.dart';

class AdminCreateAppointmentScreen extends StatefulWidget {
  const AdminCreateAppointmentScreen({super.key});

  @override
  State<AdminCreateAppointmentScreen> createState() => _AdminCreateAppointmentScreenState();
}

class _AdminCreateAppointmentScreenState extends State<AdminCreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClientEmail;
  Service? _selectedService;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  final _notesController = TextEditingController();

  List<Map<String, dynamic>> _clients = [];
  List<Service> _services = [];
  List<String> _availableTimeSlots = [];
  bool _isLoading = true;
  bool _isLoadingTimeSlots = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    final model = Provider.of<Model>(context, listen: false);


    await _loadClients();


    _services = await model.getServices();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadClients() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('users').where('role', isEqualTo: 'client').get();

    _clients = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'email': doc.id,
        'name': data['name'] ?? 'Unknown',
        'gender': data['gender'] ?? 'Unknown',
      };
    }).toList();
  }

  Future<void> _loadTimeSlots() async {
    if (_selectedService == null) return;

    setState(() {
      _isLoadingTimeSlots = true;
      _selectedTimeSlot = null;
    });

    final model = Provider.of<Model>(context, listen: false);
    _availableTimeSlots = await model.getAvailableTimeSlots(
      _selectedDate,
      _selectedService!.duration,
    );

    setState(() {
      _isLoadingTimeSlots = false;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Appointment'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildSectionTitle('Select Client'),
              _buildClientDropdown(),
              const SizedBox(height: 24),

              _buildSectionTitle('Select Service'),
              _buildServiceDropdown(),
              const SizedBox(height: 24),

              _buildSectionTitle('Select Date'),
              _buildDatePicker(),
              const SizedBox(height: 24),

              _buildSectionTitle('Select Time'),
              _buildTimeSlotGrid(),
              const SizedBox(height: 24),

              _buildSectionTitle('Notes (Optional)'),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Add any special instructions or notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _canCreateAppointment() ? _createAppointment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text(
                    'CREATE APPOINTMENT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildClientDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedClientEmail,
          hint: const Text('Select a client'),
          isExpanded: true,
          items: _clients.map((client) {
            return DropdownMenuItem<String>(
              value: client['email'] as String,
              child: Row(
                children: [
                  Icon(
                    client['gender'] == 'Male' ? Icons.male : Icons.female,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${client['name']} (${client['email']})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedClientEmail = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildServiceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Service>(
          value: _selectedService,
          hint: const Text('Select a service'),
          isExpanded: true,
          items: _services.map((service) {
            return DropdownMenuItem<Service>(
              value: service,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${service.price.toStringAsFixed(2)} € • ${service.duration} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedService = value;
            });
            _loadTimeSlots();
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
        );

        if (pickedDate != null && pickedDate != _selectedDate) {
          setState(() {
            _selectedDate = pickedDate;
            _selectedTimeSlot = null;
          });
          _loadTimeSlots();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    if (_selectedService == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Please select a service first'),
        ),
      );
    }

    if (_isLoadingTimeSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availableTimeSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.access_time,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              const Text(
                'No available time slots for this date',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate.add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _selectedTimeSlot = null;
                    });
                    _loadTimeSlots();
                  }
                },
                child: const Text('Try Another Date'),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _availableTimeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = _availableTimeSlots[index];
        final isSelected = timeSlot == _selectedTimeSlot;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedTimeSlot = timeSlot;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                timeSlot,
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _canCreateAppointment() {
    return _selectedClientEmail != null &&
        _selectedService != null &&
        _selectedTimeSlot != null;
  }

  Future<void> _createAppointment() async {
    if (!_canCreateAppointment()) return;

    final model = Provider.of<Model>(context, listen: false);

    try {
      await model.createAppointmentByAdmin(
        userEmail: _selectedClientEmail!,
        serviceId: _selectedService!.id,
        date: _selectedDate,
        timeSlot: _selectedTimeSlot!,
        notes: _notesController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment created successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}