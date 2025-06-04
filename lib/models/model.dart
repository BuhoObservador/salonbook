import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salonbook/models/appointment.dart';
import 'package:salonbook/models/product.dart';
import 'package:salonbook/models/saloninfo.dart';
import 'package:salonbook/models/service.dart';
import 'package:salonbook/pages/auth_page.dart';

class Model extends ChangeNotifier {
  FirebaseFirestore fbStore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final PageController pageController = PageController();

  bool _isProcessing = false;
  User? _user;
  String _name = "";
  String _str = "";
  List<String> _userInfo = [];
  bool get isProcessing => _isProcessing;
  String get name => _name;
  String get str => _str;
  User? get user => _user;
  List<String> get userInfo => _userInfo;

  List<Service> _services = [];
  List<Appointment> _userAppointments = [];
  List<Appointment> _todayAppointments = [];
  SalonInfo? _salonInfo;

  List<Product> _products = [];
  List<Category> _categories = [];
  List<CartItem> _cartItems = [];
  List<ItemsOrder> _userOrders = [];
  List<ItemsOrder> _allOrders = [];

  List<Service> get services => _services;
  List<Appointment> get userAppointments => _userAppointments;
  List<Appointment> get todayAppointments => _todayAppointments;
  SalonInfo? get salonInfo => _salonInfo;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<CartItem> get cartItems => _cartItems;
  List<ItemsOrder> get userOrders => _userOrders;
  List<ItemsOrder> get allOrders => _allOrders;

  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void navigateToTab(int tabIndex) {
    pageController.jumpToPage(tabIndex);
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  processingData(bool process) {
    _isProcessing = process;
    notifyListeners();
  }

  Future<User?> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      return _user;
    } on FirebaseAuthException catch (e) {
      hideSnackbar(context);

      switch (e.code) {
        case 'user-not-found':
          showSnackbar(context, "No account found with this email address.");
          break;

        case 'wrong-password':
          showSnackbar(context, "Incorrect password. Please try again.");
          break;

        case 'invalid-email':
          showSnackbar(context, "Please enter a valid email address.");
          break;

        case 'invalid-credential':
          showSnackbar(context, "Invalid email or password. Please check your credentials.");
          break;

        case 'user-disabled':
          showSnackbar(context, "This account has been disabled. Please contact support.");
          break;

        case 'too-many-requests':
          showSnackbar(context, "Too many failed attempts. Please try again later.");
          break;

        case 'operation-not-allowed':
          showSnackbar(context, "Email/password sign-in is not enabled. Please contact support.");
          break;

        case 'network-request-failed':
          showSnackbar(context, "Network error. Please check your connection and try again.");
          break;

        case 'weak-password':
          showSnackbar(context, "Password is too weak. Please choose a stronger password.");
          break;

        case 'email-already-in-use':
          showSnackbar(context, "An account already exists with this email address.");
          break;

        case 'requires-recent-login':
          showSnackbar(context, "Please log out and log back in to perform this action.");
          break;

        case 'credential-already-in-use':
          showSnackbar(context, "This credential is already associated with another account.");
          break;

        case 'account-exists-with-different-credential':
          showSnackbar(context, "An account exists with the same email but different sign-in method.");
          break;

        case 'invalid-verification-code':
          showSnackbar(context, "Invalid verification code. Please try again.");
          break;

        case 'invalid-verification-id':
          showSnackbar(context, "Invalid verification ID. Please try again.");
          break;

        case 'session-cookie-expired':
          showSnackbar(context, "Your session has expired. Please sign in again.");
          break;

        case 'web-storage-unsupported':
          showSnackbar(context, "Your browser doesn't support local storage. Please enable it.");
          break;

        case 'app-deleted':
          showSnackbar(context, "App configuration error. Please contact support.");
          break;

        case 'api-key-not-valid':
          showSnackbar(context, "Invalid API key. Please contact support.");
          break;

        case 'app-not-authorized':
          showSnackbar(context, "App not authorized. Please contact support.");
          break;

        case 'expired-action-code':
          showSnackbar(context, "This action code has expired. Please request a new one.");
          break;

        case 'invalid-action-code':
          showSnackbar(context, "Invalid action code. Please check and try again.");
          break;

        case 'invalid-message-payload':
          showSnackbar(context, "Invalid request. Please try again.");
          break;

        case 'invalid-sender':
          showSnackbar(context, "Invalid sender email. Please contact support.");
          break;

        case 'missing-iframe-start':
          showSnackbar(context, "Email verification error. Please try again.");
          break;

        case 'missing-or-invalid-nonce':
          showSnackbar(context, "Security token error. Please try again.");
          break;

        case 'unauthorized-domain':
          showSnackbar(context, "This domain is not authorized. Please contact support.");
          break;

        case 'unverified-email':
          showSnackbar(context, "Please verify your email address before signing in.");
          break;

        case 'timeout':
          showSnackbar(context, "Request timed out. Please try again.");
          break;

        case 'missing-android-pkg-name':
        case 'missing-ios-bundle-id':
          showSnackbar(context, "App configuration error. Please contact support.");
          break;

        case 'unauthorized-continue-uri':
          showSnackbar(context, "Invalid continue URL. Please contact support.");
          break;

        case 'invalid-continue-uri':
          showSnackbar(context, "Invalid continue URL format. Please contact support.");
          break;

        case 'missing-continue-uri':
          showSnackbar(context, "Missing continue URL. Please contact support.");
          break;

        case 'captcha-check-failed':
          showSnackbar(context, "reCAPTCHA verification failed. Please try again.");
          break;

        case 'invalid-phone-number':
          showSnackbar(context, "Please enter a valid phone number.");
          break;

        case 'missing-phone-number':
          showSnackbar(context, "Phone number is required.");
          break;

        case 'quota-exceeded':
          showSnackbar(context, "Service quota exceeded. Please try again later.");
          break;

        case 'cancelled-popup-request':
          showSnackbar(context, "Sign-in was cancelled. Please try again.");
          break;

        case 'popup-blocked':
          showSnackbar(context, "Popup was blocked. Please allow popups and try again.");
          break;

        case 'popup-closed-by-user':
          showSnackbar(context, "Sign-in window was closed. Please try again.");
          break;

        case 'provider-already-linked':
          showSnackbar(context, "This account is already linked to another provider.");
          break;

        case 'no-such-provider':
          showSnackbar(context, "No sign-in provider found for this account.");
          break;

        case 'invalid-user-token':
          showSnackbar(context, "Invalid user token. Please sign in again.");
          break;

        case 'user-token-expired':
          showSnackbar(context, "Your session has expired. Please sign in again.");
          break;

        case 'null-user':
          showSnackbar(context, "No user signed in. Please sign in again.");
          break;

        case 'internal-error':
          showSnackbar(context, "An internal error occurred. Please try again later.");
          break;

        default:
          String errorMessage = "Sign-in failed: ${e.message ?? 'Unknown error occurred'}";

          if (e.message != null) {
            if (e.message!.toLowerCase().contains('network')) {
              errorMessage = "Network error. Please check your connection and try again.";
            } else if (e.message!.toLowerCase().contains('timeout')) {
              errorMessage = "Request timed out. Please try again.";
            } else if (e.message!.toLowerCase().contains('permission')) {
              errorMessage = "Permission denied. Please contact support.";
            }
          }

          showSnackbar(context, errorMessage);

          print("Unknown Firebase Auth error: ${e.code} - ${e.message}");
          break;
      }
      return null;
    } catch (e) {

      hideSnackbar(context);
      showSnackbar(context, "An unexpected error occurred. Please try again.");
      print("Unexpected sign-in error: $e");
      return null;
    }
  }

  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _name = name;
      _user = userCredential.user;
      await _user!.updateDisplayName(name);
      await _user?.reload();
      _user = auth.currentUser;
      return _user;
    } on FirebaseAuthException catch (e) {
      hideSnackbar(context);

      switch (e.code) {
        case 'weak-password':
          showSnackbar(context, "Password is too weak. Please use at least 8 characters with uppercase, lowercase, numbers, and symbols.");
          break;

        case 'email-already-in-use':
          showSnackbar(context, "An account already exists with this email address. Please sign in instead.");
          break;

        case 'invalid-email':
          showSnackbar(context, "Please enter a valid email address.");
          break;

        case 'operation-not-allowed':
          showSnackbar(context, "Email/password registration is not enabled. Please contact support.");
          break;

        case 'too-many-requests':
          showSnackbar(context, "Too many registration attempts. Please try again later.");
          break;

        case 'network-request-failed':
          showSnackbar(context, "Network error. Please check your connection and try again.");
          break;

        case 'admin-restricted-operation':
          showSnackbar(context, "Registration is currently restricted. Please contact support.");
          break;

        case 'app-deleted':
          showSnackbar(context, "App configuration error. Please contact support.");
          break;

        case 'api-key-not-valid':
          showSnackbar(context, "Invalid API key. Please contact support.");
          break;

        case 'app-not-authorized':
          showSnackbar(context, "App not authorized. Please contact support.");
          break;

        case 'captcha-check-failed':
          showSnackbar(context, "reCAPTCHA verification failed. Please try again.");
          break;

        case 'quota-exceeded':
          showSnackbar(context, "Registration quota exceeded. Please try again later.");
          break;

        case 'timeout':
          showSnackbar(context, "Registration timed out. Please try again.");
          break;

        case 'internal-error':
          showSnackbar(context, "An internal error occurred. Please try again later.");
          break;

        default:
          String errorMessage = "Registration failed: ${e.message ?? 'Unknown error occurred'}";

          if (e.message != null) {
            if (e.message!.toLowerCase().contains('network')) {
              errorMessage = "Network error. Please check your connection and try again.";
            } else if (e.message!.toLowerCase().contains('timeout')) {
              errorMessage = "Registration timed out. Please try again.";
            }
          }

          showSnackbar(context, errorMessage);
          print("Unknown Firebase Auth registration error: ${e.code} - ${e.message}");
          break;
      }
      return null;
    } catch (e) {
      hideSnackbar(context);
      showSnackbar(context, "An unexpected error occurred during registration. Please try again.");
      print("Unexpected registration error: $e");
      return null;
    }
  }

  cleanVar() {
    _isProcessing = false;
    _user = null;
    _name = "";
    _str = "";
    _userInfo = [];
    _services = [];
    _userAppointments = [];
    _todayAppointments = [];
    _salonInfo = null;
    _products = [];
    _categories = [];
    _cartItems = [];
    _userOrders = [];
    _allOrders = [];
  }

  Future<void> signOut(BuildContext context) async {
    cleanVar();
    await auth.signOut();
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginRegister(savedThemeMode: savedThemeMode,),
      ),
    );
    notifyListeners();
  }

  Future<void> resetPassword({required String email, BuildContext? context}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);

      if (context != null) {
        hideSnackbar(context);
        showSnackbar(
            context,
            "Password reset email sent successfully. Please check your inbox.",
            color: Colors.green
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context != null) {
        hideSnackbar(context);

        switch (e.code) {
          case 'user-not-found':
            showSnackbar(context, "No account found with this email address.");
            break;

          case 'invalid-email':
            showSnackbar(context, "Please enter a valid email address.");
            break;

          case 'missing-email':
            showSnackbar(context, "Email address is required.");
            break;

          case 'too-many-requests':
            showSnackbar(context, "Too many reset attempts. Please try again later.");
            break;

          case 'network-request-failed':
            showSnackbar(context, "Network error. Please check your connection and try again.");
            break;

          case 'operation-not-allowed':
            showSnackbar(context, "Password reset is not enabled. Please contact support.");
            break;

          case 'admin-restricted-operation':
            showSnackbar(context, "Password reset is currently restricted. Please contact support.");
            break;

          case 'app-deleted':
            showSnackbar(context, "App configuration error. Please contact support.");
            break;

          case 'api-key-not-valid':
            showSnackbar(context, "Invalid API key. Please contact support.");
            break;

          case 'app-not-authorized':
            showSnackbar(context, "App not authorized. Please contact support.");
            break;

          case 'invalid-continue-uri':
            showSnackbar(context, "Invalid configuration. Please contact support.");
            break;

          case 'missing-continue-uri':
            showSnackbar(context, "Missing configuration. Please contact support.");
            break;

          case 'unauthorized-continue-uri':
            showSnackbar(context, "Unauthorized configuration. Please contact support.");
            break;

          case 'invalid-message-payload':
            showSnackbar(context, "Invalid request format. Please try again.");
            break;

          case 'invalid-sender':
            showSnackbar(context, "Invalid sender configuration. Please contact support.");
            break;

          case 'timeout':
            showSnackbar(context, "Request timed out. Please try again.");
            break;

          case 'internal-error':
            showSnackbar(context, "An internal error occurred. Please try again later.");
            break;

          default:
            String errorMessage = "Password reset failed: ${e.message ?? 'Unknown error occurred'}";

            if (e.message != null) {
              if (e.message!.toLowerCase().contains('network')) {
                errorMessage = "Network error. Please check your connection and try again.";
              } else if (e.message!.toLowerCase().contains('timeout')) {
                errorMessage = "Request timed out. Please try again.";
              }
            }

            showSnackbar(context, errorMessage);
            print("Unknown Firebase Auth password reset error: ${e.code} - ${e.message}");
            break;
        }
      }
    } catch (e) {
      if (context != null) {
        hideSnackbar(context);
        showSnackbar(context, "An unexpected error occurred. Please try again.");
        print("Unexpected password reset error: $e");
      }
    }
  }

  void showSnackbar(BuildContext context, String str, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(str, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: color ?? Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void hideSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  Future<void> addUserInfo(String name, String email, String phone, String gender) async {
    await fbStore.collection("users").doc(email).set({
      "name": name,
      "email": email,
      "phone": phone,
      "gender": gender,
      "role": "client",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getUserInfo() async {
    _userInfo = [];
    var doc = await fbStore.collection("users").doc(auth.currentUser?.email).get();

    if (doc.exists && doc.data() != null) {
      _userInfo.add(doc.data()!["name"]);
      _userInfo.add(doc.data()!["email"]);
      _userInfo.add(doc.data()!["phone"]);
      _userInfo.add(doc.data()!["gender"]);
    }

    notifyListeners();
    return _userInfo;
  }

  Future<bool> isUserAdmin() async {
    if (auth.currentUser == null) return false;

    var doc = await fbStore.collection("users").doc(auth.currentUser?.email).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!["role"] == "admin";
    }

    return false;
  }

  Future<void> updateUserProfile({
    required String name,
    required String phone,
    String? gender,
  }) async {
    if (auth.currentUser == null) return;

    final data = {
      "name": name,
      "phone": phone,
    };

    if (gender != null) {
      data["gender"] = gender;
    }

    await fbStore.collection("users").doc(auth.currentUser?.email).update(data);
    await getUserInfo();
  }

  Future<List<Service>> getServices() async {
    _services = [];
    final snapshot = await fbStore.collection("services").where("isActive", isEqualTo: true).get();

    _services = snapshot.docs.map((doc) {
      return Service.fromMap(doc.id, doc.data());
    }).toList();

    notifyListeners();
    return _services;
  }

  Future<List<Service>> getServicesForGender(String gender) async {

    if (_services.isNotEmpty) {

      bool needsRefetch = false;

      if (!needsRefetch) return _services;
    }

    final snapshot = await fbStore.collection("services")
        .where("isActive", isEqualTo: true)
        .where("gender", whereIn: [gender, "All"])
        .get();

    _services = snapshot.docs.map((doc) {
      return Service.fromMap(doc.id, doc.data());
    }).toList();

    notifyListeners();
    return _services;
  }

  Future<Service?> getServiceById(String serviceId) async {
    final doc = await fbStore.collection("services").doc(serviceId).get();

    if (doc.exists && doc.data() != null) {
      return Service.fromMap(doc.id, doc.data()!);
    }

    return null;
  }

  Future<String> createAppointment({
    required String serviceId,
    required DateTime date,
    required String timeSlot,
    String? notes,
  }) async {
    if (auth.currentUser == null) {
      throw Exception("User not authenticated");
    }

    try {

      final service = await getServiceById(serviceId);
      if (service == null) {
        throw Exception("Service not found");
      }

      final availableSlots = await getAvailableTimeSlots(date, service.duration);
      if (!availableSlots.contains(timeSlot)) {
        throw Exception("Time slot is no longer available. Please select another time.");
      }

      final appointmentData = {
        "userId": auth.currentUser!.email,
        "serviceId": serviceId,
        "date": Timestamp.fromDate(date),
        "timeSlot": timeSlot,
        "status": "pending",
        "notes": notes ?? "",
        "serviceDuration": service.duration,
        "createdAt": FieldValue.serverTimestamp(),
      };

      final docRef = await fbStore.collection("appointments").add(appointmentData);

      await _updateTimeSlotsAfterBooking(date, timeSlot, service.duration);

      await getUserAppointments();
      return docRef.id;

    } catch (e) {
      print("Error creating appointment: $e");
      rethrow;
    }
  }

  Future<void> _updateTimeSlotsAfterBooking(DateTime date, String timeSlot, int serviceDuration) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final slotsRef = fbStore.collection('timeSlots').doc(dateString);

      final slotsDoc = await slotsRef.get();
      if (slotsDoc.exists) {

        final occupiedSlots = _calculateOccupiedSlots(timeSlot, serviceDuration);

        await slotsRef.update({
          'bookedSlots': FieldValue.arrayUnion(occupiedSlots),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {

      print('Warning: Could not update time slots: $e');
    }
  }

  Future<List<Appointment>> getUserAppointments() async {
    if (auth.currentUser == null) {
      _userAppointments = [];
      return _userAppointments;
    }

    try {
      final snapshot = await fbStore.collection("appointments")
          .where("userId", isEqualTo: auth.currentUser!.email)
          .orderBy("date", descending: true)
          .get();

      _userAppointments = await _processAppointments(snapshot);
      notifyListeners();
      return _userAppointments;
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }


  Future<void> cancelAppointment(String appointmentId) async {
    try {
      final appointmentDoc = await fbStore.collection("appointments").doc(appointmentId).get();

      if (!appointmentDoc.exists) {
        throw Exception("Appointment not found");
      }

      final appointmentData = appointmentDoc.data()!;
      final date = (appointmentData['date'] as Timestamp).toDate();
      final timeSlot = appointmentData['timeSlot'] as String;
      final serviceDuration = appointmentData['serviceDuration'] as int? ?? 30;

      await fbStore.collection("appointments").doc(appointmentId).update({
        "status": "cancelled",
        "cancelledAt": FieldValue.serverTimestamp(),
      });

      await _updateTimeSlotsAfterCancellation(date, timeSlot, serviceDuration);

      await getUserAppointments();

    } catch (e) {
      print("Error cancelling appointment: $e");
      rethrow;
    }
  }

  Future<void> _updateTimeSlotsAfterCancellation(DateTime date, String timeSlot, int serviceDuration) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final slotsRef = fbStore.collection('timeSlots').doc(dateString);

      final slotsDoc = await slotsRef.get();
      if (slotsDoc.exists) {
        final occupiedSlots = _calculateOccupiedSlots(timeSlot, serviceDuration);

        await slotsRef.update({
          'bookedSlots': FieldValue.arrayRemove(occupiedSlots),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('✅ Freed up ${occupiedSlots.length} time slots for $dateString');
      }
    } catch (e) {
      print('Warning: Could not update time slots after cancellation: $e');
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTimeSlotInPast(String timeSlot) {
    final now = DateTime.now();

    try {
      final timeParts = timeSlot.split(':');
      if (timeParts.length != 2) return true;

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final slotTime = DateTime(now.year, now.month, now.day, hour, minute);

      final bufferTime = now.add(const Duration(minutes: 30));

      return slotTime.isBefore(bufferTime);

    } catch (e) {
      print('Error parsing time slot $timeSlot: $e');
      return true;
    }
  }

  Future<List<String>> getAvailableTimeSlots(DateTime date, int serviceDuration) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      final slotsDoc = await fbStore.collection('timeSlots').doc(dateString).get();

      if (slotsDoc.exists) {
        final slotsData = slotsDoc.data()!;
        final allSlots = List<String>.from(slotsData['availableSlots'] ?? []);
        final bookedSlots = List<String>.from(slotsData['bookedSlots'] ?? []);
        final blockedSlots = List<String>.from(slotsData['blockedSlots'] ?? []);

        final unavailableSlots = {...bookedSlots, ...blockedSlots};

        return allSlots.where((slot) {
          if (unavailableSlots.contains(slot)) return false;

          if (_isToday(date)) {
            if (_isTimeSlotInPast(slot)) return false;
          }

          return _canServiceFitInSlot(slot, serviceDuration, allSlots, unavailableSlots);
        }).toList();

      } else {
        print('⚠️ No pre-generated slots found for $dateString, using fallback...');
        return await _generateSlotsOnDemand(date, serviceDuration);
      }

    } catch (e) {
      print('❌ Error getting available time slots: $e');
      return _getEmergencyTimeSlots();
    }
  }

  Future<List<String>> _generateSlotsOnDemand(DateTime date, int serviceDuration) async {
    try {
      await getSalonInfo();
      if (_salonInfo == null) return _getEmergencyTimeSlots();

      final dayOfWeek = DateFormat('EEEE').format(date).toLowerCase();
      final openHours = _salonInfo!.openHours[dayOfWeek];

      if (openHours == null) return [];

      final bookedSlots = await _getBookedTimeSlots(date);

      final availableSlots = _generateAvailableTimeSlots(
        openHours['open'],
        openHours['close'],
        serviceDuration,
        bookedSlots,
      );

      if (_isToday(date)) {
        return availableSlots.where((slot) => !_isTimeSlotInPast(slot)).toList();
      }

      return availableSlots;

    } catch (e) {
      print('Error generating slots on demand: $e');
      final emergencySlots = _getEmergencyTimeSlots();

      if (_isToday(date)) {
        return emergencySlots.where((slot) => !_isTimeSlotInPast(slot)).toList();
      }

      return emergencySlots;
    }
  }

  List<String> _getEmergencyTimeSlots() {
    return [
      '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
      '15:00', '15:30', '16:00', '16:30', '17:00', '17:30'
    ];
  }

  Future<List<String>> _getBookedTimeSlots(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {

      final snapshot = await fbStore.collection("appointments")
          .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where("date", isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final bookedSlots = <String>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;

        if (status == 'pending' || status == 'confirmed') {
          final timeSlot = data['timeSlot'] as String?;
          if (timeSlot != null) {
            bookedSlots.add(timeSlot);
          }
        }
      }

      return bookedSlots;
    } catch (e) {
      print('Error getting booked time slots: $e');
      return [];
    }
  }

  List<String> _generateAvailableTimeSlots(
      String openTime,
      String closeTime,
      int serviceDuration,
      List<String> bookedSlots,
      ) {

    final open = _parseTimeString(openTime);
    final close = _parseTimeString(closeTime);

    final slotDuration = Duration(minutes: serviceDuration);
    final availableSlots = <String>[];

    var currentTime = open;
    while (currentTime.isBefore(close)) {
      final timeString = _formatTimeOfDay(currentTime);

      if (!bookedSlots.contains(timeString)) {
        availableSlots.add(timeString);
      }

      final nextSlot = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        currentTime.hour,
        currentTime.minute + serviceDuration,
      );

      currentTime = nextSlot;
    }

    return availableSlots;
  }

  DateTime _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  String _formatTimeOfDay(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<SalonInfo?> getSalonInfo() async {
    if (_salonInfo != null) return _salonInfo;

    final doc = await fbStore.collection("salon").doc("info").get();

    if (doc.exists && doc.data() != null) {
      _salonInfo = SalonInfo.fromMap(doc.data()!);
      notifyListeners();
    }

    return _salonInfo;
  }

  Future<List<Appointment>> getTodayAppointments() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await fbStore.collection("appointments")
        .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where("date", isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy("date")
        .get();

    _todayAppointments = await _processAppointments(snapshot);
    notifyListeners();
    return _todayAppointments;
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await fbStore.collection("appointments")
        .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where("date", isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy("date")
        .get();

    return await _processAppointments(snapshot);
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      if (status == 'cancelled') {
        await cancelAppointment(appointmentId);
      } else {
        await fbStore.collection("appointments").doc(appointmentId).update({
          "status": status,
          "updatedAt": FieldValue.serverTimestamp(),
        });
      }

      await getTodayAppointments();
    } catch (e) {
      print("Error updating appointment status: $e");
      rethrow;
    }
  }

  Future<String> createAppointmentByAdmin({
    required String userEmail,
    required String serviceId,
    required DateTime date,
    required String timeSlot,
    String? notes,
  }) async {
    final appointmentData = {
      "userId": userEmail,
      "serviceId": serviceId,
      "date": Timestamp.fromDate(date),
      "timeSlot": timeSlot,
      "status": "confirmed",
      "notes": notes ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    };

    final docRef = await fbStore.collection("appointments").add(appointmentData);
    await getTodayAppointments();

    return docRef.id;
  }

  Future<String> addService({
    required String name,
    required String description,
    required double price,
    required int duration,
    required String gender,
    String? imageUrl,
  }) async {
    final serviceData = {
      "name": name,
      "description": description,
      "price": price,
      "duration": duration,
      "gender": gender,
      "imageUrl": imageUrl,
      "isActive": true,
    };

    final docRef = await fbStore.collection("services").add(serviceData);
    await getServices();

    return docRef.id;
  }

  Future<void> updateService(Service service) async {
    await fbStore.collection("services").doc(service.id).update(service.toMap());
    await getServices();
  }

  Future<void> toggleServiceStatus(String serviceId, bool isActive) async {
    await fbStore.collection("services").doc(serviceId).update({
      "isActive": isActive
    });

    await getServices();
  }

  Future<List<Appointment>> _processAppointments(QuerySnapshot snapshot) async {
    final appointments = snapshot.docs.map((doc) {
      return Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();

    for (var appointment in appointments) {
      final userDoc = await fbStore.collection("users").doc(appointment.userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        appointment.userName = userDoc.data()!["name"];
      }

      final serviceDoc = await fbStore.collection("services").doc(appointment.serviceId).get();
      if (serviceDoc.exists && serviceDoc.data() != null) {
        appointment.serviceName = serviceDoc.data()!["name"];
        appointment.servicePrice = (serviceDoc.data()!["price"] ?? 0).toDouble();
        appointment.serviceDuration = serviceDoc.data()!["duration"];
      }
    }

    return appointments;
  }


  Future<List<Category>> getCategories() async {
    final snapshot = await fbStore.collection("categories")
        .where("isActive", isEqualTo: true)
        .orderBy("sortOrder")
        .get();

    _categories = snapshot.docs.map((doc) {
      return Category.fromMap(doc.id, doc.data());
    }).toList();

    notifyListeners();
    return _categories;
  }

  Future<String> addCategory({
    required String name,
    required String description,
    String? imageUrl,
    int sortOrder = 0,
  }) async {
    final categoryData = {
      "name": name,
      "description": description,
      "imageUrl": imageUrl,
      "isActive": true,
      "sortOrder": sortOrder,
      "createdAt": FieldValue.serverTimestamp(),
    };

    final docRef = await fbStore.collection("categories").add(categoryData);
    await getCategories();
    return docRef.id;
  }

  Future<void> updateCategory(Category category) async {
    await fbStore.collection("categories").doc(category.id).update(category.toMap());
    await getCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    await fbStore.collection("categories").doc(categoryId).update({
      "isActive": false
    });
    await getCategories();
  }

  Future<List<Product>> getProducts({String? categoryId}) async {
    Query query = fbStore.collection("products").where("isActive", isEqualTo: true);

    if (categoryId != null) {
      query = query.where("categoryId", isEqualTo: categoryId);
    }

    final snapshot = await query.orderBy("createdAt", descending: true).get();

    _products = snapshot.docs.map((doc) {
      return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();

    notifyListeners();
    return _products;
  }

  Future<List<Product>> getFeaturedProducts() async {
    final snapshot = await fbStore.collection("products")
        .where("isActive", isEqualTo: true)
        .where("isFeatured", isEqualTo: true)
        .limit(6)
        .get();

    return snapshot.docs.map((doc) {
      return Product.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<Product?> getProductById(String productId) async {
    final doc = await fbStore.collection("products").doc(productId).get();

    if (doc.exists && doc.data() != null) {
      return Product.fromMap(doc.id, doc.data()!);
    }

    return null;
  }

  Future<String> addProduct({
    required String name,
    required String description,
    required double price,
    required List<String> images,
    required String categoryId,
    required String categoryName,
    required int stockQuantity,
    bool isFeatured = false,
    Map<String, dynamic>? specifications,
  }) async {
    final now = DateTime.now();
    final productData = {
      "name": name,
      "description": description,
      "price": price,
      "images": images,
      "categoryId": categoryId,
      "categoryName": categoryName,
      "stockQuantity": stockQuantity,
      "isActive": true,
      "isFeatured": isFeatured,
      "specifications": specifications ?? {},
      "createdAt": Timestamp.fromDate(now),
      "updatedAt": Timestamp.fromDate(now),
    };

    final docRef = await fbStore.collection("products").add(productData);
    await getProducts();
    return docRef.id;
  }

  Future<void> updateProduct(Product product) async {
    await fbStore.collection("products").doc(product.id).update(product.toMap());
    await getProducts();
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    await fbStore.collection("products").doc(productId).update({
      "stockQuantity": newStock,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleProductStatus(String productId, bool isActive) async {
    await fbStore.collection("products").doc(productId).update({
      "isActive": isActive,
      "updatedAt": FieldValue.serverTimestamp(),
    });
    await getProducts();
  }


  void addToCart(BuildContext context, Product product, int quantity) {
    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      final currentQuantity = _cartItems[existingIndex].quantity;
      final newQuantity = currentQuantity + quantity;

      if (newQuantity <= product.stockQuantity) {
        _cartItems[existingIndex].quantity = newQuantity;
      } else {
        showSnackbar(context, "Cannot add more items. Stock limit reached.");
        return;
      }
    } else {
      if (quantity <= product.stockQuantity) {
        _cartItems.add(CartItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          imageUrl: product.images.isNotEmpty ? product.images.first : null,
          quantity: quantity,
          maxStock: product.stockQuantity,
        ));
      } else {
        showSnackbar(context, "Not enough stock available.");
        return;
      }
    }

    notifyListeners();
    _saveCartToLocal();
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);

    if (index >= 0) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else if (newQuantity <= _cartItems[index].maxStock) {
        _cartItems[index].quantity = newQuantity;
      }

      notifyListeners();
      _saveCartToLocal();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
    _saveCartToLocal();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    _saveCartToLocal();
  }

  void _saveCartToLocal() {
  }

  Future<void> loadCartFromLocal() async {
  }

  Future<String> createOrder({
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> billingAddress,
    String? notes,
  }) async {
    if (auth.currentUser == null || _cartItems.isEmpty) {
      throw Exception("Invalid order data");
    }

    final userInfo = await getUserInfo();
    final now = DateTime.now();

    final subtotal = cartTotal;
    final tax = subtotal * 0.21;
    final shipping = subtotal > 50 ? 0 : 10;
    final total = subtotal + tax + shipping;

    final orderData = {
      "userId": auth.currentUser!.email,
      "userEmail": auth.currentUser!.email,
      "userName": userInfo.isNotEmpty ? userInfo[0] : "Unknown",
      "items": _cartItems.map((item) => {
        "productId": item.productId,
        "productName": item.productName,
        "price": item.price,
        "quantity": item.quantity,
        "imageUrl": item.imageUrl,
      }).toList(),
      "subtotal": subtotal,
      "tax": tax,
      "shipping": shipping,
      "total": total,
      "status": "pending",
      "paymentStatus": "pending",
      "shippingAddress": shippingAddress,
      "billingAddress": billingAddress,
      "notes": notes,
      "createdAt": Timestamp.fromDate(now),
      "updatedAt": Timestamp.fromDate(now),
    };

    final docRef = await fbStore.collection("orders").add(orderData);


    for (final item in _cartItems) {
      final product = await getProductById(item.productId);
      if (product != null) {
        await updateProductStock(
            item.productId,
            product.stockQuantity - item.quantity
        );
      }
    }

    clearCart();
    await getUserOrders();

    return docRef.id;
  }

  Future<List<ItemsOrder>> getUserOrders() async {
    if (auth.currentUser == null) {
      _userOrders = [];
      return _userOrders;
    }

    final snapshot = await fbStore.collection("orders")
        .where("userId", isEqualTo: auth.currentUser!.email)
        .orderBy("createdAt", descending: true)
        .get();

    _userOrders = snapshot.docs.map((doc) {
      return ItemsOrder.fromMap(doc.id, doc.data());
    }).toList();

    notifyListeners();
    return _userOrders;
  }

  Future<List<ItemsOrder>> getAllOrders() async {
    final snapshot = await fbStore.collection("orders")
        .orderBy("createdAt", descending: true)
        .get();

    _allOrders = snapshot.docs.map((doc) {
      return ItemsOrder.fromMap(doc.id, doc.data());
    }).toList();

    notifyListeners();
    return _allOrders;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await fbStore.collection("orders").doc(orderId).update({
      "status": status,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    await getAllOrders();
    await getUserOrders();
  }

  Future<void> updatePaymentStatus(String orderId, String paymentStatus, {String? paymentIntentId}) async {
    final updateData = {
      "paymentStatus": paymentStatus,
      "updatedAt": FieldValue.serverTimestamp(),
    };

    if (paymentIntentId != null) {
      updateData["paymentIntentId"] = paymentIntentId;
    }

    await fbStore.collection("orders").doc(orderId).update(updateData);

    await getAllOrders();
    await getUserOrders();
  }

  Future<List<Product>> searchProducts(String query) async {
    final snapshot = await fbStore.collection("products")
        .where("isActive", isEqualTo: true)
        .get();

    final allProducts = snapshot.docs.map((doc) {
      return Product.fromMap(doc.id, doc.data());
    }).toList();

    return allProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()) ||
          product.categoryName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Product> filterProducts({
    double? minPrice,
    double? maxPrice,
    String? categoryId,
    bool? inStock,
  }) {
    return _products.where((product) {
      if (minPrice != null && product.price < minPrice) return false;
      if (maxPrice != null && product.price > maxPrice) return false;
      if (categoryId != null && product.categoryId != categoryId) return false;
      if (inStock == true && product.stockQuantity <= 0) return false;
      return true;
    }).toList();
  }

  Future<Map<String, dynamic>> getStoreAnalytics() async {

    final ordersSnapshot = await fbStore.collection("orders").get();
    final orders = ordersSnapshot.docs.map((doc) => ItemsOrder.fromMap(doc.id, doc.data())).toList();

    final totalRevenue = orders.fold(0.0, (sum, order) => sum + order.total);
    final totalOrders = orders.length;
    final pendingOrders = orders.where((o) => o.status == "pending").length;
    final completedOrders = orders.where((o) => o.status == "delivered").length;

    final productsSnapshot = await fbStore.collection("products").where("isActive", isEqualTo: true).get();
    final totalProducts = productsSnapshot.docs.length;
    final lowStockProducts = productsSnapshot.docs.where((doc) {
      final data = doc.data();
      return (data['stockQuantity'] ?? 0) < 5;
    }).length;

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'completedOrders': completedOrders,
      'totalProducts': totalProducts,
      'lowStockProducts': lowStockProducts,
    };
  }

  static const String _salonOpenTime = '09:00';
  static const String _salonCloseTime = '18:00';
  static const int _slotDurationMinutes = 30;
  static const List<int> _operatingDays = [1, 2, 3, 4, 5];

  Future<void> generate3MonthsTimeSlots({bool overwrite = false}) async {
    print('🕒 Starting 3-month time slot generation...');

    try {
      final startDate = DateTime.now();
      final endDate = DateTime(2025, 8 + 3, 23);

      int totalSlotsGenerated = 0;
      int totalDaysProcessed = 0;

      for (DateTime date = startDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {

        if (_operatingDays.contains(date.weekday)) {
          final daySlots = await _generateDaySlotsAndStore(date, overwrite);
          totalSlotsGenerated += daySlots;
          totalDaysProcessed++;

          if (totalDaysProcessed % 10 == 0) {
            print('📅 Processed $totalDaysProcessed days, $totalSlotsGenerated total slots');
          }
        }
      }

      print('✅ Time slot generation completed!');
      print('📊 Summary:');
      print('   • Total days processed: $totalDaysProcessed');
      print('   • Total time slots generated: $totalSlotsGenerated');
      print('   • Average slots per day: ${(totalSlotsGenerated / totalDaysProcessed).toStringAsFixed(1)}');
      print('   • Date range: ${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}');

    } catch (e) {
      print('❌ Error generating time slots: $e');
      rethrow;
    }
  }

  Future<int> _generateDaySlotsAndStore(DateTime date, bool overwrite) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    if (!overwrite) {
      final existingSlots = await fbStore
          .collection('timeSlots')
          .doc(dateString)
          .get();

      if (existingSlots.exists) {
        print('⏭️ Skipping $dateString - slots already exist');
        return 0;
      }
    }

    final timeSlots = _generateTimeSlotsForDay();

    final slotData = {
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'dateString': dateString,
      'dayOfWeek': date.weekday,
      'dayName': DateFormat('EEEE').format(date),
      'isOperatingDay': true,
      'openTime': _salonOpenTime,
      'closeTime': _salonCloseTime,
      'totalSlots': timeSlots.length,
      'availableSlots': timeSlots,
      'bookedSlots': <String>[],
      'blockedSlots': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };


    await fbStore.collection('timeSlots').doc(dateString).set(slotData);

    return timeSlots.length;
  }

  List<String> _generateTimeSlotsForDay() {
    final slots = <String>[];
    final openTime = _parseTimeString(_salonOpenTime);
    final closeTime = _parseTimeString(_salonCloseTime);

    DateTime currentTime = openTime;

    while (currentTime.isBefore(closeTime)) {
      slots.add(DateFormat('HH:mm').format(currentTime));
      currentTime = currentTime.add(Duration(minutes: _slotDurationMinutes));
    }

    return slots;
  }

  bool _canServiceFitInSlot(String startSlot, int serviceDuration, List<String> allSlots, Set<String> unavailableSlots) {
    final startTime = _parseTimeString(startSlot);
    final endTime = startTime.add(Duration(minutes: serviceDuration));

    final closeTime = _parseTimeString('18:00');
    if (endTime.isAfter(closeTime)) return false;

    DateTime currentTime = startTime;
    while (currentTime.isBefore(endTime)) {
      final currentSlot = DateFormat('HH:mm').format(currentTime);
      if (unavailableSlots.contains(currentSlot)) return false;
      currentTime = currentTime.add(const Duration(minutes: 30));
    }

    return true;
  }

  Future<void> _updateTimeSlotsForBooking(String dateString, String startTimeSlot, int serviceDuration, String action) async {
    try {
      final slotsRef = fbStore.collection('timeSlots').doc(dateString);

      await fbStore.runTransaction((transaction) async {
        final slotsDoc = await transaction.get(slotsRef);

        if (slotsDoc.exists) {
          final currentBookedSlots = List<String>.from(slotsDoc.data()!['bookedSlots'] ?? []);

          final occupiedSlots = _calculateOccupiedSlots(startTimeSlot, serviceDuration);

          if (action == 'book') {

            for (final slot in occupiedSlots) {
              if (!currentBookedSlots.contains(slot)) {
                currentBookedSlots.add(slot);
              }
            }
          } else if (action == 'cancel') {
            currentBookedSlots.removeWhere((slot) => occupiedSlots.contains(slot));
          }

          transaction.update(slotsRef, {
            'bookedSlots': currentBookedSlots,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

    } catch (e) {
      print('Error updating time slots: $e');
    }
  }

  List<String> _calculateOccupiedSlots(String startTimeSlot, int serviceDuration) {
    final occupiedSlots = <String>[];
    final startTime = _parseTimeString(startTimeSlot);
    final endTime = startTime.add(Duration(minutes: serviceDuration));

    DateTime currentTime = startTime;
    while (currentTime.isBefore(endTime)) {
      occupiedSlots.add(DateFormat('HH:mm').format(currentTime));
      currentTime = currentTime.add(Duration(minutes: _slotDurationMinutes));
    }

    return occupiedSlots;
  }

  Future<void> blockTimeSlots({
    required DateTime date,
    required List<String> slotsToBlock,
    String reason = 'Blocked by admin',
  }) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final slotsRef = fbStore.collection('timeSlots').doc(dateString);

      await fbStore.runTransaction((transaction) async {
        final slotsDoc = await transaction.get(slotsRef);

        if (slotsDoc.exists) {
          final currentBlockedSlots = List<String>.from(slotsDoc.data()!['blockedSlots'] ?? []);

          for (final slot in slotsToBlock) {
            if (!currentBlockedSlots.contains(slot)) {
              currentBlockedSlots.add(slot);
            }
          }

          transaction.update(slotsRef, {
            'blockedSlots': currentBlockedSlots,
            'blockReason': reason,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      print('✅ Blocked ${slotsToBlock.length} time slots for $dateString');

    } catch (e) {
      print('❌ Error blocking time slots: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTimeSlotStatistics() async {
    try {
      final now = DateTime.now();
      final oneWeekFromNow = now.add(const Duration(days: 7));

      final querySnapshot = await fbStore.collection('timeSlots')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('date', isLessThan: Timestamp.fromDate(oneWeekFromNow))
          .get();

      int totalSlots = 0;
      int bookedSlots = 0;
      int blockedSlots = 0;
      int availableSlots = 0;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final total = (data['totalSlots'] as int?) ?? 0;
        final booked = (data['bookedSlots'] as List?)?.length ?? 0;
        final blocked = (data['blockedSlots'] as List?)?.length ?? 0;

        totalSlots += total;
        bookedSlots += booked;
        blockedSlots += blocked;
        availableSlots += (total - booked - blocked);
      }

      return {
        'totalSlots': totalSlots,
        'bookedSlots': bookedSlots,
        'blockedSlots': blockedSlots,
        'availableSlots': availableSlots,
        'bookingRate': totalSlots > 0 ? (bookedSlots / totalSlots * 100) : 0,
        'daysAnalyzed': querySnapshot.docs.length,
      };

    } catch (e) {
      print('Error getting time slot statistics: $e');
      return {};
    }
  }

  bool canCompleteAppointment(Appointment appointment) {
    final now = DateTime.now();
    final appointmentDateTime = parseAppointmentDateTime(appointment);

    final completionEligibleTime = appointmentDateTime.add(const Duration(minutes: 15));

    return now.isAfter(completionEligibleTime);
  }

  bool canConfirmAppointment(Appointment appointment) {
    if (appointment.status != 'pending') return false;

    final now = DateTime.now();
    final appointmentDateTime = parseAppointmentDateTime(appointment);

    return appointmentDateTime.isAfter(now.subtract(const Duration(hours: 1)));
  }

  bool canCancelAppointment(Appointment appointment) {
    if (appointment.status == 'completed') return false;

    final now = DateTime.now();
    final appointmentDateTime = parseAppointmentDateTime(appointment);

    return appointmentDateTime.isAfter(now);
  }

  bool canMarkAsNoShow(Appointment appointment) {
    if (appointment.status == 'completed' || appointment.status == 'cancelled') {
      return false;
    }

    final now = DateTime.now();
    final appointmentDateTime = parseAppointmentDateTime(appointment);

    final noShowEligibleTime = appointmentDateTime.add(const Duration(minutes: 15));
    return now.isAfter(noShowEligibleTime);
  }

  Color getAppointmentStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'no-show':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String getAppointmentStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no-show':
        return 'No Show';
      default:
        return 'Unknown';
    }
  }

  DateTime parseAppointmentDateTime(Appointment appointment) {
    try {
      final timeParts = appointment.timeSlot.split(':');
      if (timeParts.length != 2) {
        return appointment.date;
      }

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
        hour,
        minute,
      );
    } catch (e) {
      print('Error parsing appointment time: $e');
      return appointment.date;
    }
  }

  List<String> getAvailableStatusTransitions(Appointment appointment) {
    final transitions = <String>[];

    if (canConfirmAppointment(appointment)) {
      transitions.add('confirmed');
    }

    if (canCompleteAppointment(appointment)) {
      transitions.add('completed');
    }

    if (canCancelAppointment(appointment)) {
      transitions.add('cancelled');
    }

    if (canMarkAsNoShow(appointment)) {
      transitions.add('no-show');
    }

    return transitions;
  }

  String getStatusChangeReason(Appointment appointment, String targetStatus) {
    final now = DateTime.now();
    final appointmentDateTime = parseAppointmentDateTime(appointment);

    switch (targetStatus) {
      case 'completed':
        if (appointmentDateTime.isAfter(now)) {
          return 'Cannot complete future appointments';
        }
        final completionTime = appointmentDateTime.add(const Duration(minutes: 15));
        if (now.isBefore(completionTime)) {
          final waitTime = completionTime.difference(now);
          return 'Wait ${waitTime.inMinutes} more minutes to mark as completed';
        }
        break;

      case 'confirmed':
        if (appointment.status != 'pending') {
          return 'Only pending appointments can be confirmed';
        }
        if (appointmentDateTime.isBefore(now.subtract(const Duration(hours: 1)))) {
          return 'Cannot confirm past appointments';
        }
        break;

      case 'cancelled':
        if (appointment.status == 'completed') {
          return 'Cannot cancel completed appointments';
        }
        if (appointmentDateTime.isBefore(now)) {
          return 'Cannot cancel past appointments - mark as no-show instead';
        }
        break;

      case 'no-show':
        if (appointment.status == 'completed' || appointment.status == 'cancelled') {
          return 'Cannot mark completed or cancelled appointments as no-show';
        }
        final noShowTime = appointmentDateTime.add(const Duration(minutes: 15));
        if (now.isBefore(noShowTime)) {
          return 'Wait until appointment time has passed';
        }
        break;
    }

    return 'Status change not allowed';
  }
}