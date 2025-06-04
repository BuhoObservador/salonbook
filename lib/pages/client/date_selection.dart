import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonbook/models/model.dart';
import 'package:salonbook/models/saloninfo.dart';
import 'package:salonbook/models/service.dart';
import 'package:salonbook/pages/client/time_selection.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DateSelectionScreen extends StatefulWidget {
  final Service service;

  const DateSelectionScreen({super.key, required this.service});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  late DateTime _selectedDate;
  late DateTime _focusedDay;
  late SalonInfo? _salonInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = _getValidFutureDate(DateTime.now());
    _focusedDay = _selectedDate;
    _loadSalonInfo();
  }

  DateTime _getValidFutureDate(DateTime date) {
    final now = DateTime.now();
    DateTime validDate = DateTime(date.year, date.month, date.day);

    if (validDate.isBefore(DateTime(now.year, now.month, now.day))) {
      validDate = DateTime(now.year, now.month, now.day);
    }

    return validDate;
  }

  Future<void> _loadSalonInfo() async {
    final model = Provider.of<Model>(context, listen: false);
    _salonInfo = await model.getSalonInfo();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isDateAvailable(DateTime date) {
    if (_salonInfo == null) return false;

    final dayOfWeek = DateFormat('EEEE').format(date).toLowerCase();
    return _salonInfo!.openHours.containsKey(dayOfWeek) &&
        _salonInfo!.openHours[dayOfWeek] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildServiceHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a Date',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCalendar(),
                  const SizedBox(height: 16),
                  _buildContinueButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                widget.service.gender == 'Male' ? Icons.male :
                widget.service.gender == 'Female' ? Icons.female : Icons.people,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.service.price.toStringAsFixed(2)} € • ${widget.service.duration} minutes',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 90)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      enabledDayPredicate: (day) {
        return !day.isBefore(DateTime.now().subtract(const Duration(days: 1))) &&
            _isDateAvailable(day);
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha:0.5),
          shape: BoxShape.circle,
        ),
        disabledTextStyle: const TextStyle(color: Colors.grey),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimeSelectionScreen(
                service: widget.service,
                selectedDate: _selectedDate,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'CONTINUE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}