import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonbook/models/appointment.dart';
import 'package:salonbook/models/model.dart';
import 'package:salonbook/models/saloninfo.dart';
import 'package:salonbook/models/service.dart';
import 'package:salonbook/pages/client/my_orders_screen.dart';
import 'package:salonbook/pages/client/service_selection.dart';
import 'package:salonbook/pages/client/appointment.dart';
import 'package:salonbook/pages/client/profile.dart';
import 'package:intl/intl.dart';
import 'package:salonbook/pages/client/store_screen.dart';

import 'client/product_details_screen.dart';

class SalonBook extends StatefulWidget {
  const SalonBook({super.key});

  @override
  State<SalonBook> createState() => _SalonBookState();
}

class _SalonBookState extends State<SalonBook> {
  int _selectedIndex = 0;

  late Future<SalonInfo?> _salonInfoFuture;
  late Future<List<Service>> _servicesFuture;
  late Future<List<Appointment>> _appointmentsFuture;
  late Future<List<String>> _userInfoFuture;
  late final model;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    model = Provider.of<Model>(context, listen: false);
    _salonInfoFuture = model.getSalonInfo();
    _userInfoFuture = model.getUserInfo();

    _servicesFuture = model.getServicesForGender('All');

    _userInfoFuture.then((_) {
      final userGender = model.userInfo.isNotEmpty ? model.userInfo[3] : 'All';
      if (mounted) {
        setState(() {
          _servicesFuture = model.getServicesForGender(userGender);
        });
      }
    });

    _appointmentsFuture = model.getUserAppointments();

    model.loadCartFromLocal();
  }

  void _refreshDataOnTabChange(int index) {
    if (index == 0) {
      setState(() {
        _appointmentsFuture = model.getUserAppointments();
      });
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: model.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildHomeTab(context),
            const StoreScreen(),
            const AppointmentsScreen(),
            const MyOrdersScreen(),
            const ProfileScreen(),
          ],
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _refreshDataOnTabChange(index);
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            model.navigateToTab(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final model = Provider.of<Model>(context);

    return FutureBuilder<SalonInfo?>(
      future: _salonInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final salonInfo = snapshot.data;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  salonInfo?.name ?? 'Salon',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (salonInfo?.images != null && salonInfo!.images.isNotEmpty)
                      Image.network(
                        salonInfo!.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Consumer<Model>(
                  builder: (context, model, child) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          onPressed: () {
                            model.navigateToTab(1);
                          },
                        ),
                        if (model.cartItemCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${model.cartItemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildQuickActionsSection(context),
                  const SizedBox(height: 24),
                  _buildFeaturedServicesSection(context),
                  const SizedBox(height: 24),
                  _buildFeaturedProductsSection(context),
                  const SizedBox(height: 24),
                  _buildUpcomingAppointmentSection(context),
                  const SizedBox(height: 24),
                  _buildSalonInfoSection(context, salonInfo),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Actions'),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Book Appointment',
                Icons.event_available,
                Colors.blue,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServiceSelectionScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Shop Products',
                Icons.shopping_bag,
                Colors.green,
                    () {
                      model.navigateToTab(1);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsSection(BuildContext context) {
    final model = Provider.of<Model>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Featured Products'),
            const Spacer(),
            TextButton(
              onPressed: () {
                model.navigateToTab(1);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        FutureBuilder(
          future: model.getFeaturedProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No featured products',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              );
            }

            final products = snapshot.data!.take(3).toList();

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: product,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  color: Colors.grey[200],
                                  image: product.images.isNotEmpty
                                      ? DecorationImage(
                                    image: NetworkImage(product.images.first),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    if (product.images.isEmpty)
                                      const Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    if (product.isFeatured)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'FEATURED',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          color: Colors.black.withValues(alpha: 0.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '${product.price.toStringAsFixed(2)} €',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (product.stockQuantity <= 5)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: product.stockQuantity == 0
                                                ? Colors.red[100]
                                                : Colors.orange[100],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            product.stockQuantity == 0 ? 'Out' : 'Low',
                                            style: TextStyle(
                                              color: product.stockQuantity == 0
                                                  ? Colors.red[800]
                                                  : Colors.orange[800],
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeaturedServicesSection(BuildContext context) {
    final model = Provider.of<Model>(context);
    final userGender = model.userInfo.isNotEmpty ? model.userInfo[3] : 'All';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Featured Services'),
        FutureBuilder<List<Service>>(
          future: _servicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No services available'));
            }

            final services = snapshot.data!.take(4).toList();

            return SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(service, context);
                },
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServiceSelectionScreen(),
                ),
              );
            },
            child: const Text('View All Services'),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Service service, BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceSelectionScreen(
                initialSelectedService: service,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
              ),
              child: Center(
                child: Icon(
                  service.gender == 'Male' ? Icons.male :
                  service.gender == 'Female' ? Icons.female : Icons.people,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${service.price.toStringAsFixed(2)} € • ${service.duration} min',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAppointmentState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'No upcoming appointments',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointmentSection(BuildContext context) {
    final model = Provider.of<Model>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Upcoming Appointment'),
        FutureBuilder<List<Appointment>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyAppointmentState();
            }

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final upcomingAppointments = snapshot.data!
                .where((a) {
              final appointmentDate = DateTime(a.date.year, a.date.month, a.date.day);

              return (appointmentDate.isAfter(today) ||
                  (appointmentDate.isAtSameMomentAs(today) &&
                      a.status != 'cancelled' &&
                      a.status != 'completed')) &&
                  a.status != 'cancelled';
            })
                .toList();

            if (upcomingAppointments.isEmpty) {
              return _buildEmptyAppointmentState();
            }

            upcomingAppointments.sort((a, b) => a.date.compareTo(b.date));
            final nextAppointment = upcomingAppointments.first;

            print("Upcoming appointment found: ${nextAppointment.serviceName} on ${DateFormat('yyyy-MM-dd').format(nextAppointment.date)} at ${nextAppointment.timeSlot} (status: ${nextAppointment.status})");

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha:0.7),
                    Theme.of(context).colorScheme.secondary.withValues(alpha:0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.event,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nextAppointment.serviceName ?? 'Unknown Service',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d • ${nextAppointment.timeSlot}')
                                  .format(nextAppointment.date),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      model.navigateToTab(2);
                      _refreshDataOnTabChange(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpecialOffersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Special Offers'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha:0.8),
                Colors.deepPurple.withValues(alpha:0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '20% OFF YOUR FIRST VISIT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use code WELCOME20 when booking your first appointment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServiceSelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                ),
                child: const Text('BOOK NOW'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalonInfoSection(BuildContext context, SalonInfo? salonInfo) {
    if (salonInfo == null) return const SizedBox.shrink();

    final dayOrder = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday'
    ];

    final dayDisplayNames = {
      'sunday': 'Sunday',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday'
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Salon Information'),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Address'),
                  subtitle: Text(salonInfo.address),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Phone'),
                  subtitle: Text(salonInfo.phone),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(salonInfo.email),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(),
                const Text(
                  'Opening Hours',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: dayOrder.map((day) {
                      final hours = salonInfo.openHours[day];
                      final isToday = _isToday(day);
                      final isOpen = hours != null;

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isToday ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Text(
                                    dayDisplayNames[day] ?? day,
                                    style: TextStyle(
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                      color: isToday ? Theme.of(context).colorScheme.primary : null,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (isToday) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Today',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isOpen) ...[
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.green[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${hours['open']} - ${hours['close']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ] else ...[
                                    Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.red[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Closed',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isToday(String day) {
    final today = DateTime.now();
    final todayName = DateFormat('EEEE').format(today).toLowerCase();
    return day == todayName;
  }
}