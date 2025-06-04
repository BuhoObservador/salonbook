import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonbook/models/appointment.dart';
import 'package:salonbook/models/model.dart';
import 'package:salonbook/pages/admin/admin_calendar.dart';
import 'package:salonbook/pages/admin/admin_services_screen.dart';
import 'package:salonbook/pages/admin/admin_create_appointment.dart';
import 'package:salonbook/pages/admin/manage_categories_screen.dart';
import 'package:salonbook/pages/admin/manage_products_screen.dart';
import 'package:salonbook/pages/admin/orders_management_screen.dart';
import 'package:intl/intl.dart';
import 'package:salonbook/pages/admin/time_slot_management_screen.dart';

import 'add_edit_product_screen.dart';
import 'admin_store_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Appointment>> _appointmentsFuture;
  late Future<Map<String, dynamic>> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final model = Provider.of<Model>(context, listen: false);
    _appointmentsFuture = model.getTodayAppointments();
    _analyticsFuture = model.getStoreAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadData();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              model.signOut(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Appointments', icon: Icon(Icons.event)),
            Tab(text: 'Store', icon: Icon(Icons.shopping_bag)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsTab(),
          _buildStoreTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        if (_tabController.index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminCreateAppointmentScreen(),
            ),
          );
        } else {
          _showStoreQuickActions();
        }
      },
      child: Icon(_tabController.index == 0 ? Icons.add : Icons.add_shopping_cart),
    );
  }

  void _showStoreQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_box, color: Colors.blue),
              title: const Text('Add Product'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditProductScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.green),
              title: const Text('Add Category'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageCategoriesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.orange),
              title: const Text('View Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrdersManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodayHeader(),
          const SizedBox(height: 24),
          _buildAppointmentStats(),
          const SizedBox(height: 32),
          _buildQuickActionsGrid(isAppointments: true),
          const SizedBox(height: 32),
          _buildTodayAppointments(),
        ],
      ),
    );
  }

  Widget _buildStoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStoreHeader(),
          const SizedBox(height: 24),
          _buildStoreStats(),
          const SizedBox(height: 32),
          _buildQuickActionsGrid(isAppointments: false),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTodayHeader() {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Schedule',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(now),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Store Management',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Manage products, orders, and inventory',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentStats() {
    return FutureBuilder<List<Appointment>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final appointments = snapshot.data ?? [];
        final confirmed = appointments.where((a) => a.status == 'confirmed').length;
        final pending = appointments.where((a) => a.status == 'pending').length;
        final completed = appointments.where((a) => a.status == 'completed').length;

        return Row(
          children: [
            _buildStatCard(
              'Total',
              appointments.length.toString(),
              Icons.event_note,
              Colors.blue,
            ),
            _buildStatCard(
              'Confirmed',
              confirmed.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Pending',
              pending.toString(),
              Icons.hourglass_empty,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStoreStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _analyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final analytics = snapshot.data ?? {};

        return Column(
          children: [
            Row(
              children: [
                _buildStatCard(
                  'Revenue',
                  '${(analytics['totalRevenue'] ?? 0).toStringAsFixed(0)} €',
                  Icons.euro_outlined,
                  Colors.green,
                ),
                _buildStatCard(
                  'Orders',
                  '${analytics['totalOrders'] ?? 0}',
                  Icons.shopping_bag,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Products',
                  '${analytics['totalProducts'] ?? 0}',
                  Icons.inventory,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  'Pending',
                  '${analytics['pendingOrders'] ?? 0}',
                  Icons.hourglass_empty,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Completed',
                  '${analytics['completedOrders'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Low Stock',
                  '${analytics['lowStockProducts'] ?? 0}',
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid({required bool isAppointments}) {
    if (isAppointments) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                'Calendar',
                'View appointments calendar',
                Icons.calendar_today,
                Colors.blue,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminCalendarScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                'Services',
                'Manage salon services',
                Icons.spa,
                Colors.green,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminServicesScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                'Products',
                'Manage product inventory',
                Icons.inventory_2,
                Colors.blue,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageProductsScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                'Categories',
                'Organize product categories',
                Icons.category,
                Colors.green,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageCategoriesScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                'Orders',
                'Manage customer orders',
                Icons.receipt_long,
                Colors.orange,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrdersManagementScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildActionCard(
      String title,
      String description,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Appointments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Appointment>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final appointments = snapshot.data ?? [];

            if (appointments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No appointments for today',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            appointments.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appointments.length > 3 ? 3 : appointments.length,
              itemBuilder: (context, index) {
                return _buildAppointmentCard(context, appointments[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    final model = Provider.of<Model>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersManagementScreen(),
                ),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder(
          future: model.getAllOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = model.allOrders.take(3).toList();

            if (orders.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getOrderStatusColor(order.status).withValues(alpha:0.1),
                      child: Icon(
                        Icons.shopping_bag,
                        color: _getOrderStatusColor(order.status),
                      ),
                    ),
                    title: Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${order.userName} • ${order.total.toStringAsFixed(2)} €'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getOrderStatusColor(order.status).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          color: _getOrderStatusColor(order.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (availableTransitions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: availableTransitions.take(3).map((status) {
                  final config = _getQuickActionConfig(status);
                  return TextButton.icon(
                    onPressed: () => _quickUpdateStatus(appointment, status, model),
                    icon: Icon(config['icon'], size: 16),
                    label: Text(config['label']),
                    style: TextButton.styleFrom(
                      foregroundColor: config['color'],
                      backgroundColor: (config['color'] as Color).withValues(alpha:0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else if (appointment.status != 'completed' && appointment.status != 'cancelled') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.orange[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getWaitMessage(appointment, model),
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Map<String, dynamic> _getQuickActionConfig(String status) {
    switch (status) {
      case 'confirmed':
        return {'label': 'Confirm', 'icon': Icons.check, 'color': Colors.green};
      case 'completed':
        return {'label': 'Complete', 'icon': Icons.done_all, 'color': Colors.blue};
      case 'cancelled':
        return {'label': 'Cancel', 'icon': Icons.cancel, 'color': Colors.red};
      case 'no-show':
        return {'label': 'No Show', 'icon': Icons.person_off, 'color': Colors.purple};
      default:
        return {'label': 'Update', 'icon': Icons.update, 'color': Colors.grey};
    }
  }

  String _getWaitMessage(Appointment appointment, Model model) {
    if (!model.canCompleteAppointment(appointment)) {
      final appointmentDateTime = model.parseAppointmentDateTime(appointment);
      final now = DateTime.now();
      final completionTime = appointmentDateTime.add(const Duration(minutes: 15));

      if (appointmentDateTime.isAfter(now)) {
        return 'Appointment starts in ${_getTimeUntil(appointmentDateTime)}';
      } else if (now.isBefore(completionTime)) {
        final waitMinutes = completionTime.difference(now).inMinutes;
        return 'Wait ${waitMinutes}m to mark as completed';
      }
    }

    return 'No actions available';
  }

  String _getTimeUntil(DateTime target) {
    final now = DateTime.now();
    final difference = target.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Future<void> _quickUpdateStatus(Appointment appointment, String newStatus, Model model) async {
    try {
      await model.updateAppointmentStatus(appointment.id, newStatus);
      setState(() {
        _loadData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment ${_getQuickActionConfig(newStatus)['label'].toLowerCase()}ed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getAppointmentStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}