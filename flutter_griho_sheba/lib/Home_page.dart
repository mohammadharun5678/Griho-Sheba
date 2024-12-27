import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_griho_sheba/const.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'worker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _servicesSectionKey = GlobalKey();
  final GlobalKey _homesectionkey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  Map<String, dynamic> serviceDetails = {};
  bool isLoading = true;
  List<Worker> _workers = [];
  bool _isSignUpLoading = false;
  bool _isLoginLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
    _fetchWorkers();
  }

  void _fetchWorkers() async {
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('workers');
    DatabaseEvent event = await dbRef.once();
    final data = event.snapshot.value as Map<dynamic, dynamic>;

    List<Worker> loadedWorkers = [];
    data.forEach((key, value) {
      loadedWorkers.add(Worker.fromJson(Map<String, dynamic>.from(value)));
    });

    setState(() {
      _workers = loadedWorkers;
    });
  }

  Future<void> _loadServiceDetails() async {
    FirebaseRelated firebaseService = FirebaseRelated();
    Map<String, dynamic> fetchedDetails =
        await firebaseService.fetchServiceDetails();

    if (fetchedDetails.isNotEmpty) {
      String firstKey = fetchedDetails.keys.first;
    }

    setState(() {
      serviceDetails = fetchedDetails;
      isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {});
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {});
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {});
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  void scrollToServices() {
    final context = _servicesSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  void scrollToHome() {
    final context = _homesectionkey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Griho Sheba',
              style: GoogleFonts.dancingScript(
                color: const Color(0xFF151515),
                fontWeight: FontWeight.w500,
                fontSize: 30,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    scrollToHome();
                  },
                  child: Text(
                    'Home',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF151515),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    scrollToServices();
                  },
                  child: Text(
                    'Services',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF151515),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Contact Us',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF151515),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                  onPressed: _getCurrentLocation,
                  color: Colors.black,
                ),
                _auth.currentUser != null
                    ? Row(
                        children: [
                          const Icon(Icons.person, color: Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            SavedUsername.isNotEmpty ? SavedUsername : 'User',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : OutlinedButton(
                        onPressed: () {
                          _showLoginDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF151515)),
                        ),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF151515),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
              child: Container(
            color: Colors.black.withOpacity(0.2),
          )),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    key: _homesectionkey,
                    'Here we provide\nquality services',
                    style: GoogleFonts.asap(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'We are dedicated to delivering top-notch services tailored to your needs, '
                    'with expertise and professionalism at every step.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      scrollToServices();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 12.0),
                      child: Text(
                        'View Services',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF151515),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: Colors.white54),
                  Text(
                    'Explore our services',
                    style: GoogleFonts.asap(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We offer a wide range of quality services to meet your everyday needs.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildServiceCard(
                            'Car Service', 'assets/images/service_1.png'),
                        buildServiceCard(
                            'Plumbing', 'assets/images/service_2.png'),
                        buildServiceCard(
                            'Cleaning', 'assets/images/service_3.png'),
                        buildServiceCard(
                            'AC Servicing', 'assets/images/service_4.png'),
                        buildServiceCard(
                            'Appliance Repair', 'assets/images/service_5.png'),
                        buildServiceCard(
                            'Truck Service', 'assets/images/service_6.png'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white54),
                  Text(
                    'Quality services near you',
                    key: _servicesSectionKey,
                    style: GoogleFonts.asap(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width < 600 ? 2 : 3,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 6,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // Example data, replace as needed
                      List<Map<String, String>> services = [
                        {
                          'title': 'Car Service',
                          'description':
                              'Keep your car in top condition with our expert car service, from engine tune-ups to tire checks.',
                          'image': 'assets/images/solution_1.jpg'
                        },
                        {
                          'title': 'Plumbing',
                          'description':
                              'Professional plumbing services for all your home and office needs, ensuring smooth water flow and leak-free systems.',
                          'image': 'assets/images/solution_2.jpg'
                        },
                        {
                          'title': 'Cleaning',
                          'description':
                              'Sparkling clean spaces with our comprehensive cleaning services, from homes to commercial properties.',
                          'image': 'assets/images/solution_3.jpg'
                        },
                        {
                          'title': 'AC Servicing',
                          'description':
                              'Stay cool with our reliable AC servicing and repairs, ensuring optimal performance in every season.',
                          'image': 'assets/images/solution_4.jpg'
                        },
                        {
                          'title': 'Appliance Repair',
                          'description':
                              'Get your appliances back in action with our fast and professional repair services for all major brands.',
                          'image': 'assets/images/solution_5.jpg'
                        },
                        {
                          'title': 'Truck Service',
                          'description':
                              'Reliable truck maintenance and repair services to keep your heavy-duty vehicles running smoothly on the road.',
                          'image': 'assets/images/solution_6.jpg'
                        },
                      ];

                      return buildDetailedServiceCard(
                        services[index]['title']!,
                        services[index]['description']!,
                        services[index]['image']!,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white54),
                  // Your footer here
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Divider(color: Colors.white54),
                          Text(
                            '© 2024 Griho Sheba. All rights reserved.',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Privacy Policy | Terms of Service',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkerDetailsPopup(BuildContext context) {
    Worker? selectedWorker;
    if (_workers.isNotEmpty) {
      final random = Random();
      int randomIndex = random.nextInt(_workers.length);
      setState(() {
        selectedWorker = _workers[randomIndex];
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(25.0),
            constraints: BoxConstraints(
              maxWidth: 400, // Same width as the sign-in/sign-up dialogs
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Thank You for Choosing Our Service!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(selectedWorker!.picture),
                ),
                const SizedBox(height: 20),
                Text(
                  selectedWorker!.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  selectedWorker!.phone,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                const Flexible(
                  child: Text(
                    'Our technician will be in touch with you shortly to provide the best service experience. We appreciate your trust in us!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent[700],
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showServicePopup(BuildContext context, String serviceType) async {
    final service = serviceDetails[serviceType];

    if (service == null) {
      return;
    }

    Map<String, int> selectedQuantities = {};

    service['services'].forEach((subService) {
      if (subService is Map && subService.containsKey('name')) {
        selectedQuantities[subService['name']] = 0;
      }
    });

    String locationText = "Customize Service";

    double calculateTotalPrice() {
      double total = 0;
      selectedQuantities.forEach((serviceName, quantity) {
        try {
          final serviceDetail = service['services']
              .firstWhere((service) => service['name'] == serviceName);
          total += serviceDetail['price'] * quantity;
        } catch (e) {
          //
        }
      });
      return total;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          image: DecorationImage(
                            image: AssetImage(service['image']),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.6),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.green[700], size: 24),
                                const SizedBox(width: 5),
                                Text(
                                  '${service['rating']} out of 5',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '(${service['ratingsCount']} ratings)',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              service['description'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Additional Info:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...service['additionalInfo']
                                .entries
                                .map<Widget>((entry) {
                              return Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locationText,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ...service['services'].map<Widget>((subService) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    subService['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove,
                                            color: Colors.black),
                                        onPressed: () {
                                          setState(() {
                                            if (selectedQuantities[
                                                    subService['name']]! >
                                                0) {
                                              selectedQuantities[
                                                      subService['name']] =
                                                  selectedQuantities[
                                                          subService['name']]! -
                                                      1;
                                            }
                                          });
                                        },
                                      ),
                                      Text(
                                        '${selectedQuantities[subService['name']]}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add,
                                            color: Colors.black),
                                        onPressed: () {
                                          setState(() {
                                            selectedQuantities[
                                                    subService['name']] =
                                                selectedQuantities[
                                                        subService['name']]! +
                                                    1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                            const SizedBox(height: 20),
                            Text(
                              'Total Price: ৳${calculateTotalPrice().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showWorkerDetailsPopup(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent[700],
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                'Checkout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildServiceCard(String serviceType, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: () async {
          if (FirebaseAuth.instance.currentUser == null) {
            _showLoginDialog(context);
          } else {
            _showServicePopup(context, serviceType);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 39,
              backgroundImage: AssetImage(imagePath),
            ),
            const SizedBox(height: 10),
            Text(
              serviceType,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Your e-mail',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 15.0),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 15.0),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isLoginLoading
                          ? null
                          : () {
                              setState(() {
                                _isLoginLoading = true;
                              });

                              FirebaseRelated()
                                  .signInUser(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                context,
                              )
                                  .whenComplete(() {
                                setState(() {
                                  _isLoginLoading = false;
                                });
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 5,
                      ),
                      child: _isLoginLoading
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'By continuing, you agree to the terms of use & privacy policy.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _showSignUpDialog(context);
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 15.0),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Your e-mail',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 15.0),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 15.0),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isSignUpLoading
                          ? null
                          : () {
                              setState(() {
                                _isSignUpLoading = true;
                              });

                              FirebaseRelated()
                                  .signUpUser(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                context,
                                nameController.text.trim(),
                                _phoneNumberController.text.trim(),
                              )
                                  .whenComplete(() {
                                setState(() {
                                  _isSignUpLoading = false;
                                });
                                if (FirebaseAuth.instance.currentUser != null) {
                                  _showPhoneNumberDialog(context);
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 5,
                      ),
                      child: _isSignUpLoading
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'By continuing, you agree to the terms of use & privacy policy.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _showLoginDialog(context);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPhoneNumberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phone Verification',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: '+1234567890',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 15.0),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    _verifyPhoneNumber(
                        _phoneNumberController.text.trim(), context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Verify Phone Number',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verifyPhoneNumber(String phoneNumber, BuildContext context) async {
    FirebaseRelated().saveUsernameToDatabase(
        _auth.currentUser!.uid,
        _emailController.text.trim(),
        nameController.text.trim(),
        _phoneNumberController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Phone number verified successfully!"),
        duration: Duration(seconds: 2),
      ),
    );
    navigateToPage(context, HomePage());
  }

  void _showOtpDialog(BuildContext context, String verificationId) {
    final TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(25.0),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enter OTP',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP Code',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    // Verify the OTP
                    _verifyOtp(
                        verificationId, otpController.text.trim(), context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Center(
                    child: Text('Verify OTP'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verifyOtp(
      String verificationId, String otp, BuildContext context) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign the user in with the provided OTP code
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Phone number verified successfully!"),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(); // Close OTP dialog
      }
    } on FirebaseAuthException catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to verify OTP: ${e.message}"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget buildDetailedServiceCard(
      String title, String description, String imagePath) {
    return GestureDetector(
      onTap: () async {
        if (FirebaseAuth.instance.currentUser == null) {
          _showLoginDialog(context);
        } else {
          _showServicePopup(context, title);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Icon(Icons.star_border, color: Colors.amber, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
