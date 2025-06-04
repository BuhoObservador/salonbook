import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonbook/models/appointment.dart';
import 'package:salonbook/models/model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AdminCalendarScreen extends StatefulWidget {
  const AdminCalendarScreen({super.key});

  @override
  State<AdminCalendarScreen> createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late List<Appointment> _selectedDayAppointments;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay;
    _selectedDayAppointments = [];
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    final model = Provider.of<Model>(context, listen: false);
    _selectedDayAppointments = await model.getAppointmentsByDate(_selectedDay);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(height: 1),
          _buildSelectedDateHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildAppointmentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        _loadAppointments();
      },
      calendarFormat: CalendarFormat.month,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        selectedDecoration: BoxDecoration(
          color: Colors.deepPurple,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha:0.5),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildSelectedDateHeader() {
    final isToday = isSameDay(_selectedDay, DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black,
      child: Row(
        children: [
          const Icon(Icons.event, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            '${_selectedDayAppointments.length} appointment${_selectedDayAppointments.length != 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_selectedDayAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments on ${DateFormat('MMM d').format(_selectedDay)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    _selectedDayAppointments.sort((a, b) {
      return a.timeSlot.compareTo(b.timeSlot);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedDayAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(context, _selectedDayAppointments[index]);
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    final model = Provider.of<Model>(context, listen: false);
    final statusColor = model.getAppointmentStatusColor(appointment.status);
    final statusText = model.getAppointmentStatusText(appointment.status);
    final availableTransitions = model.getAvailableStatusTransitions(appointment);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      appointment.timeSlot,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.userName ?? 'Unknown Client',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.serviceName ?? 'Unknown Service',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      if (appointment.servicePrice != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${appointment.servicePrice!.toStringAsFixed(2)} €',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusBadge(appointment.status, statusColor, statusText),
              ],
            ),
            if (appointment.serviceDuration != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Duration: ${appointment.serviceDuration} minutes',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (availableTransitions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildActionButtons(context, appointment, availableTransitions, model),
            ] else ...[
              const SizedBox(height: 12),
              _buildNoActionsAvailable(context, appointment, model),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color statusColor, String statusText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha:0.5)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context,
      Appointment appointment,
      List<String> availableTransitions,
      Model model,
      ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTransitions.map((status) {
        return _buildActionButton(
          context,
          appointment,
          status,
          model,
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      Appointment appointment,
      String targetStatus,
      Model model,
      ) {
    final buttonConfig = _getButtonConfig(targetStatus);

    return ElevatedButton.icon(
      onPressed: () => _showStatusChangeDialog(
        context,
        appointment,
        targetStatus,
        model,
      ),
      icon: Icon(buttonConfig['icon'], size: 16),
      label: Text(buttonConfig['label']),
      style: ElevatedButton.styleFrom(
        backgroundColor: (buttonConfig['color'] as Color).withValues(alpha:0.1),
        foregroundColor: buttonConfig['color'],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildNoActionsAvailable(BuildContext context, Appointment appointment, Model model) {
    final reasons = <String>[];

    if (!model.canConfirmAppointment(appointment)) {
      reasons.add(model.getStatusChangeReason(appointment, 'confirmed'));
    }
    if (!model.canCompleteAppointment(appointment)) {
      reasons.add(model.getStatusChangeReason(appointment, 'completed'));
    }
    if (!model.canCancelAppointment(appointment)) {
      reasons.add(model.getStatusChangeReason(appointment, 'cancelled'));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              appointment.status == 'completed'
                  ? 'Appointment completed'
                  : appointment.status == 'cancelled'
                  ? 'Appointment cancelled'
                  : 'No actions available at this time',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getButtonConfig(String status) {
    switch (status) {
      case 'confirmed':
        return {
          'label': 'Confirm',
          'icon': Icons.check,
          'color': Colors.green,
        };
      case 'completed':
        return {
          'label': 'Complete',
          'icon': Icons.done_all,
          'color': Colors.blue,
        };
      case 'cancelled':
        return {
          'label': 'Cancel',
          'icon': Icons.cancel,
          'color': Colors.red,
        };
      case 'no-show':
        return {
          'label': 'No Show',
          'icon': Icons.person_off,
          'color': Colors.purple,
        };
      default:
        return {
          'label': 'Update',
          'icon': Icons.update,
          'color': Colors.grey,
        };
    }
  }

  Future<void> _showStatusChangeDialog(
      BuildContext context,
      Appointment appointment,
      String newStatus,
      Model model,
      ) async {
    final config = _getButtonConfig(newStatus);
    final statusText = model.getAppointmentStatusText(newStatus);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${config['label']} Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change status to "$statusText"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client: ${appointment.userName ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('Service: ${appointment.serviceName ?? 'Unknown'}'),
                  Text('Time: ${appointment.timeSlot}'),
                  Text('Date: ${DateFormat('MMM d, yyyy').format(appointment.date)}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: config['color'],
            ),
            child: Text(
              config['label'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await model.updateAppointmentStatus(appointment.id, newStatus);
        await _loadAppointments();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment ${config['label'].toLowerCase()}ed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}