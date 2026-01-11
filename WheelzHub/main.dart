import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';

void main() {
  runApp(const WheelzHubApp());
}

// --- STATE MANAGEMENT ---

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  final List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }
}

class Order {
  final String brand;
  final String model;
  final String engine;
  final String seats;
  final String color;
  final String wheels;
  final double price;
  final double tax;
  final double total;
  final String deliveryCode;
  final String email;
  final String phone;
  final DateTime deliveryDate;

  Order({
    required this.brand,
    required this.model,
    required this.engine,
    required this.seats,
    required this.color,
    required this.wheels,
    required this.price,
    required this.tax,
    required this.total,
    required this.deliveryCode,
    required this.email,
    required this.phone,
    required this.deliveryDate,
  });
}

// --- APP ENTRY ---

class WheelzHubApp extends StatefulWidget {
  const WheelzHubApp({super.key});

  @override
  State<WheelzHubApp> createState() => _WheelzHubAppState();
}

class _WheelzHubAppState extends State<WheelzHubApp> {
  @override
  void initState() {
    super.initState();
    AppState().addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WheelzHub',
      debugShowCheckedModeBanner: false,
      themeMode: AppState().themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      home: const LaunchScreen(),
    );
  }
}

// --- UTILS & MOCK DATA ---

final Map<String, List<String>> carModels = {
  'Bugatti': ['Chiron Super Sport', 'Veyron Grand Sport', 'Divo', 'Centodieci', 'Bolide', 'Mistral'],
  'Pagani': ['Huayra R', 'Zonda HP Barchetta', 'Utopia', 'Imola', 'Huayra BC'],
  'Tesla': ['Model S Plaid', 'Model 3 Performance', 'Model X Plaid', 'Model Y Performance', 'Cybertruck', 'Roadster'],
  'Lamborghini': ['Revuelto', 'Huracan STO', 'Urus Performante', 'Aventador Ultimae', 'Huracan Tecnica', 'Urus S'],
  'Mercedes': ['AMG GT Black Series', 'S-Class Maybach', 'G-Wagon G63', 'EQS 580', 'AMG One', 'SL 63 AMG'],
  'BMW': ['M4 Competition', 'M5 CS', 'i8 Roadster', 'X7 M60i', 'M8 Competition', 'iX M60', 'M3 CS'],
  'Audi': ['R8 V10 Plus', 'RS7 Performance', 'e-tron GT', 'Q8 RS', 'RS6 Avant', 'RSQ8'],
  'Cadillac': ['Escalade-V', 'CT5-V Blackwing', 'Lyriq', 'Celestiq', 'CT4-V Blackwing'],
  'Bentley': ['Continental GT Speed', 'Flying Spur', 'Bentayga EWB', 'Mulliner Batur', 'Continental GTC'],
  'Ferrari': ['SF90 Stradale', 'F8 Tributo', '296 GTB', 'Purosangue', '812 Competizione', 'Roma Spider', 'Daytona SP3'],
  'Ford': ['Mustang GT', 'Mustang Shelby GT500', 'F-150 Raptor R', 'Bronco Raptor', 'GT Supercar'],
  'Mustang': ['GT Premium', 'Shelby GT500', 'Mach 1', 'Dark Horse', 'Mach-E GT'],
  'Porsche': ['911 Turbo S', 'Taycan Turbo S', 'Cayenne Turbo GT', 'Panamera Turbo S', '718 Cayman GT4 RS', 'Macan GTS'],
  'Rolls-Royce': ['Phantom', 'Ghost Black Badge', 'Cullinan', 'Spectre', 'Wraith Black Badge', 'Dawn'],
  'McLaren': ['765LT', 'Artura', '720S', 'GT', 'Elva', '750S'],
  'Aston Martin': ['DB12', 'DBS 770 Ultimate', 'Vantage', 'DBX707', 'Valkyrie', 'DB11'],
  'Maserati': ['MC20', 'Quattroporte Trofeo', 'Levante Trofeo', 'Ghibli Trofeo', 'GranTurismo'],
};

// Using emoji/icons instead of network images to avoid network dependency
final Map<String, IconData> brandIcons = {
  'Bugatti': Icons.speed,
  'Pagani': Icons.sports_score,
  'Tesla': Icons.electric_car,
  'Lamborghini': Icons.directions_car,
  'Mercedes': Icons.star,
  'BMW': Icons.drive_eta,
  'Audi': Icons.circle,
  'Cadillac': Icons.local_shipping,
  'Bentley': Icons.diamond,
  'Ferrari': Icons.local_fire_department,
  'Ford': Icons.agriculture,
  'Mustang': Icons.flash_on,
  'Porsche': Icons.directions_car_filled,
  'Rolls-Royce': Icons.workspace_premium,
  'McLaren': Icons.rocket_launch,
  'Aston Martin': Icons.military_tech,
  'Maserati': Icons.auto_awesome,
};

// Country of origin for each brand
final Map<String, String> brandCountry = {
  'Bugatti': 'France',
  'Pagani': 'Italy',
  'Tesla': 'USA',
  'Lamborghini': 'Italy',
  'Mercedes': 'Germany',
  'BMW': 'Germany',
  'Audi': 'Germany',
  'Cadillac': 'USA',
  'Bentley': 'United Kingdom',
  'Ferrari': 'Italy',
  'Ford': 'USA',
  'Mustang': 'USA',
  'Porsche': 'Germany',
  'Rolls-Royce': 'United Kingdom',
  'McLaren': 'United Kingdom',
  'Aston Martin': 'United Kingdom',
  'Maserati': 'Italy',
};

// Brand descriptions
final Map<String, String> brandDescription = {
  'Bugatti': 'Built for speed and sports excellence',
  'Pagani': 'Handcrafted automotive masterpieces',
  'Tesla': 'Revolutionary electric innovation',
  'Lamborghini': 'Aggressive power meets Italian design',
  'Mercedes': 'Luxury and engineering perfection',
  'BMW': 'The ultimate driving machine',
  'Audi': 'Vorsprung durch Technik',
  'Cadillac': 'Bold American luxury',
  'Bentley': 'Exquisite British craftsmanship',
  'Ferrari': 'Racing heritage and passion',
  'Ford': 'American muscle and reliability',
  'Mustang': 'Raw power and freedom',
  'Porsche': 'Precision German engineering',
  'Rolls-Royce': 'The pinnacle of luxury',
  'McLaren': 'Formula 1 technology for roads',
  'Aston Martin': 'British elegance and performance',
  'Maserati': 'Italian luxury and style',
};

// --- SCREENS ---

// 0. ANIMATION HELPERS

class StaggeredFadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  const StaggeredFadeIn({super.key, required this.child, required this.index});

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fadeAnimation, child: SlideTransition(position: _slideAnimation, child: widget.child));
  }
}

// 1. LAUNCH SCREEN
class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.grey.shade900],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'WHEELZHUB',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.white,
                          fontSize: 42
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 2,
                      width: 100,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to WheelzHub',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.withOpacity(0.3), Colors.purple.withOpacity(0.3)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.psychology, color: Colors.lightBlueAccent, size: 28),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'AI-Powered Car Selection\nFind Your Perfect Match',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        '🚗 Premium vehicles delivered to your doorstep\n💎 Hassle-free paperwork & tax handling\n🤖 Smart AI recommendations',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const HomeScreen(),
                            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                            transitionDuration: const Duration(milliseconds: 800),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 10,
                        shadowColor: Colors.redAccent.withOpacity(0.5),
                      ),
                      child: const Text('ENTER DEALERSHIP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 2. HOME SCREEN & DRAWER
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    AppState().addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    AppState().removeListener(_onThemeChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WheelzHub', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(AppState().themeMode == ThemeMode.light
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded),
            onPressed: () => AppState().toggleTheme(),
          )
        ],
      ),
      drawer: const MainDrawer(),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppState().themeMode == ThemeMode.dark
                ? [Colors.grey[900]!, Colors.black]
                : [Colors.blueGrey[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to',
                        style: TextStyle(fontSize: 24, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'WHEELZHUB',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      const SizedBox(height: 10),
                      Container(width: 60, height: 4, decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: brandIcons.length,
                    itemBuilder: (context, index) {
                      String brand = brandIcons.keys.elementAt(index);
                      return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ModelSelectionScreen(brand: brand)));
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Column(
                                  children: [
                                    Hero(
                                      tag: 'logo_$brand',
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade900],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,5))
                                            ]
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(brandIcons[brand], size: 45, color: Colors.white),
                                            const SizedBox(height: 4),
                                            Text(
                                              brandCountry[brand] ?? '',
                                              style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(brand, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        brandDescription[brand] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 10, color: Colors.grey[600], height: 1.2),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ));
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, opacity, child) {
                      return Opacity(
                        opacity: opacity,
                        child: child,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Why Choose WheelzHub?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppState().themeMode == ThemeMode.dark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1a1a2e),
                                const Color(0xFF16213e),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.verified_user, color: Colors.white, size: 30),
                                  ),
                                  const SizedBox(width: 15),
                                  const Expanded(
                                    child: Text(
                                      'Hassle-Free Luxury Delivered',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildBenefitRow(Icons.payment, 'You Pay Only Price + Tax'),
                              const SizedBox(height: 12),
                              _buildBenefitRow(Icons.local_shipping, 'Showroom to Your Doorstep'),
                              const SizedBox(height: 12),
                              _buildBenefitRow(Icons.description, 'We Handle All Paperwork'),
                              const SizedBox(height: 12),
                              _buildBenefitRow(Icons.account_balance, 'Tax Processing Included'),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                                ),
                                child: const Text(
                                  '🚗 Sit back, relax, and let WheelzHub bring your dream car home. No stress, no hassle, just pure luxury delivered to your door!',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white70,
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.redAccent, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
      ],
    );
  }
}

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
            child: const Center(
              child: Text(
                'WheelzHub Menu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _drawerTile(context, 'Home', Icons.home, const HomeScreen()),
          _drawerTile(context, 'Cars', Icons.directions_car, const CarsScreen()),
          _drawerTile(context, 'Delivery', Icons.local_shipping, const DeliveryScreenPlaceholder()),
          _drawerTile(context, 'My Orders', Icons.shopping_basket, const MyOrdersScreen()),
          _drawerTile(context, 'Compare', Icons.compare_arrows, const CompareScreen()),
          _drawerTile(context, 'About', Icons.info, const AboutScreen()),
        ],
      ),
    );
  }

  Widget _drawerTile(BuildContext context, String title, IconData icon, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}

// 3. CARS SCREEN
class CarsScreen extends StatelessWidget {
  const CarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Brand')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: brandIcons.length,
        itemBuilder: (context, index) {
          String brand = brandIcons.keys.elementAt(index);
          return StaggeredFadeIn(
              index: index,
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ModelSelectionScreen(brand: brand))),
                child: Card(
                  elevation: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(brandIcons[brand], size: 70, color: Colors.blueGrey),
                      const SizedBox(height: 10),
                      Text(brand, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }
}

class ModelSelectionScreen extends StatelessWidget {
  final String brand;
  const ModelSelectionScreen({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    List<String> models = carModels[brand] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text('$brand Models')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: models.length,
        itemBuilder: (context, index) {
          String model = models[index];
          return StaggeredFadeIn(
              index: index,
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(model, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CustomizationScreen(brand: brand, model: model)),
                  ),
                ),
              ));
        },
      ),
    );
  }
}

// 4. CUSTOMIZATION SCREEN
class CustomizationScreen extends StatefulWidget {
  final String brand;
  final String model;
  const CustomizationScreen({super.key, required this.brand, required this.model});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  String selectedEngine = 'V6 Turbo';
  String selectedSeats = 'Premium Leather';
  String selectedColor = 'Phantom Black';
  String selectedWheels = '20" Alloy';
  String selectedTransmission = 'Automatic';
  String selectedInterior = 'Black Leather';
  String selectedSunroof = 'Panoramic Sunroof';

  final Map<String, double> enginePrices = {
    'V6 Turbo': 50000,
    'V8 Bi-Turbo': 75000,
    'V12 Luxury': 120000,
    'Electric Motor': 65000,
    'Hybrid V6': 55000,
  };

  final Map<String, double> engineTax = {
    'V6 Turbo': 0.10,
    'V8 Bi-Turbo': 0.15,
    'V12 Luxury': 0.25,
    'Electric Motor': 0.05,
    'Hybrid V6': 0.08,
  };

  final Map<String, double> transmissionPrices = {
    'Automatic': 5000,
    'Manual': 0,
    'Dual-Clutch': 8000,
    'CVT': 3000,
  };

  final Map<String, double> interiorPrices = {
    'Black Leather': 0,
    'Beige Leather': 2000,
    'Carbon Fiber': 15000,
    'Alcantara': 10000,
    'Nappa Leather': 8000,
  };

  final Map<String, double> sunroofPrices = {
    'No Sunroof': 0,
    'Standard Sunroof': 2000,
    'Panoramic Sunroof': 5000,
  };

  double get basePrice => 100000.0;
  double get enginePrice => enginePrices[selectedEngine]!;
  double get transmissionPrice => transmissionPrices[selectedTransmission]!;
  double get interiorPrice => interiorPrices[selectedInterior]!;
  double get sunroofPrice => sunroofPrices[selectedSunroof]!;
  double get taxRate => engineTax[selectedEngine]!;
  double get totalBeforeTax => basePrice + enginePrice + transmissionPrice + interiorPrice + sunroofPrice;
  double get taxAmount => totalBeforeTax * taxRate;
  double get totalPrice => totalBeforeTax + taxAmount;

  void _showConfirmationDialog() {
    final deliveryDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
              const SizedBox(width: 10),
              const Expanded(child: Text('Confirm Your Purchase')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to buy this car?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _confirmRow('Brand', widget.brand),
                _confirmRow('Model', widget.model),
                _confirmRow('Engine', selectedEngine),
                _confirmRow('Transmission', selectedTransmission),
                _confirmRow('Interior', selectedInterior),
                _confirmRow('Color', selectedColor),
                const Divider(height: 20),
                _confirmRow('Total Amount', '\$${totalPrice.toStringAsFixed(2)}', isBold: true),
                const Divider(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated Delivery:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}',
                              style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚠️ This action cannot be undone. Please review all details carefully before confirming.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeliveryScreen(
                      brand: widget.brand,
                      model: widget.model,
                      engine: selectedEngine,
                      seats: selectedSeats,
                      color: selectedColor,
                      wheels: selectedWheels,
                      price: totalBeforeTax,
                      tax: taxAmount,
                      total: totalPrice,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Yes, Proceed to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _confirmRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customize ${widget.model}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Engine Selection'),
            _dropdown(selectedEngine, enginePrices.keys.toList(), (val) => setState(() => selectedEngine = val!)),
            _sectionHeader('Transmission'),
            _dropdown(selectedTransmission, transmissionPrices.keys.toList(), (val) => setState(() => selectedTransmission = val!)),
            _sectionHeader('Interior Trim'),
            _dropdown(selectedInterior, interiorPrices.keys.toList(), (val) => setState(() => selectedInterior = val!)),
            _sectionHeader('Seat Type'),
            _dropdown(selectedSeats, ['Standard', 'Premium Leather', 'Alcantara Sport', 'Ventilated Seats'], (val) => setState(() => selectedSeats = val!)),
            _sectionHeader('Body Color'),
            _dropdown(selectedColor, ['Phantom Black', 'Crystal White', 'Royal Blue', 'Ferrari Red', 'Emerald Green', 'Midnight Purple'], (val) => setState(() => selectedColor = val!)),
            _sectionHeader('Wheels'),
            _dropdown(selectedWheels, ['19" Standard', '20" Alloy', '22" Carbon Fiber', '21" Sport'], (val) => setState(() => selectedWheels = val!)),
            _sectionHeader('Sunroof'),
            _dropdown(selectedSunroof, sunroofPrices.keys.toList(), (val) => setState(() => selectedSunroof = val!)),
            const Divider(height: 40),
            Text('Price Breakdown', style: Theme.of(context).textTheme.titleLarge),
            _priceRow('Base Price', basePrice),
            _priceRow('Engine Upgrade', enginePrice),
            _priceRow('Transmission', transmissionPrice),
            _priceRow('Interior Trim', interiorPrice),
            _priceRow('Sunroof', sunroofPrice),
            _priceRow('Tax (${(taxRate * 100).toInt()}%)', taxAmount, isBold: true),
            const Divider(),
            _priceRow('Total Price', totalPrice, isBold: true, color: Colors.green),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Buy Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _dropdown(String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _priceRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}

// 5. DELIVERY SCREEN
class DeliveryScreen extends StatefulWidget {
  final String brand, model, engine, seats, color, wheels;
  final double price, tax, total;

  const DeliveryScreen({
    super.key, required this.brand, required this.model, required this.engine,
    required this.seats, required this.color, required this.wheels,
    required this.price, required this.tax, required this.total,
  });

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  String selectedCountry = 'Pakistan';
  String selectedPaymentMethod = 'Credit/Debit Card';
  String? generatedCode;
  DateTime? estimatedDate;

  final List<String> countries = [
    'Pakistan', 'USA', 'UK', 'Germany', 'UAE', 'Canada', 'Japan', 'Australia',
    'France', 'Italy', 'Spain', 'Netherlands', 'Belgium', 'Switzerland', 'Austria',
    'Sweden', 'Norway', 'Denmark', 'Finland', 'Poland', 'Czech Republic', 'Portugal',
    'Greece', 'Turkey', 'Saudi Arabia', 'Qatar', 'Kuwait', 'Bahrain', 'Oman',
    'India', 'China', 'South Korea', 'Singapore', 'Malaysia', 'Thailand', 'Indonesia',
    'New Zealand', 'Brazil', 'Mexico', 'Argentina', 'South Africa'
  ];

  final List<String> paymentMethods = [
    'Credit/Debit Card',
    'Bank Transfer',
    'Cryptocurrency (Bitcoin/Ethereum)',
    'Cash on Delivery',
    'Financing (12-48 months)',
    'PayPal',
    'Apple Pay',
    'Google Pay',
  ];

  void _generateCode() {
    if (nameController.text.isEmpty || addressController.text.isEmpty ||
        emailController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all details')));
      return;
    }

    setState(() {
      generatedCode = (100000 + Random().nextInt(900000)).toString();
      estimatedDate = DateTime.now().add(const Duration(days: 7));
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 10),
            const Expanded(child: Text('Order Placed Successfully!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order code is:', style: TextStyle(fontSize: 14)),
            Text(generatedCode!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(height: 20),
            _infoRow(Icons.local_shipping, 'Delivery Date', _formatDate(estimatedDate!)),
            _infoRow(Icons.payment, 'Payment Method', selectedPaymentMethod),
            _infoRow(Icons.email, 'Email Updates', emailController.text),
            _infoRow(Icons.location_on, 'Delivery To', selectedCountry),
            const Divider(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, color: Colors.red, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Do NOT share this code with anyone.',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppState().addOrder(Order(
                brand: widget.brand,
                model: widget.model,
                engine: widget.engine,
                seats: widget.seats,
                color: widget.color,
                wheels: widget.wheels,
                price: widget.price,
                tax: widget.tax,
                total: widget.total,
                deliveryCode: generatedCode!,
                email: emailController.text,
                phone: phoneController.text,
                deliveryDate: estimatedDate!,
              ));
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            },
            child: const Text('Go Home'),
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Gmail / Email', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCountry,
              items: countries.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => selectedCountry = v!),
              decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedPaymentMethod,
              isExpanded: true,
              items: paymentMethods.map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              )).toList(),
              onChanged: (v) => setState(() => selectedPaymentMethod = v!),
              decoration: InputDecoration(
                labelText: 'Payment Method',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.payment, color: Colors.green),
                filled: true,
                fillColor: Colors.green.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _sumRow('Car', '${widget.brand} ${widget.model}'),
                    _sumRow('Price', '\$${widget.price.toStringAsFixed(2)}'),
                    _sumRow('Tax', '\$${widget.tax.toStringAsFixed(2)}'),
                    const Divider(),
                    _sumRow('Payable Total', '\$${widget.total.toStringAsFixed(2)}', isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _generateCode, child: const Text('Generate Code & Process Order')),
          ],
        ),
      ),
    );
  }

  Widget _sumRow(String l, String v, {bool isBold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(v, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal))]);
  }
}

// 6. MY ORDERS SCREEN
class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final orders = AppState().orders;
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final o = orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text('${o.brand} ${o.model}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Status: In Transit (Est: ${_formatDate(o.deliveryDate)})'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Engine: ${o.engine}'),
                      Text('Color: ${o.color}'),
                      Text('Total: \$${o.total.toStringAsFixed(2)}'),
                      const Divider(),
                      Text('Delivery Code: ${o.deliveryCode}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text('Contact: ${o.email} | ${o.phone}'),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// 7. PAYMENT METHOD SCREEN (Accessed from Drawer logic)
class PaymentScreenPlaceholder extends StatelessWidget {
  const PaymentScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.credit_card), title: Text('Credit / Debit Card')),
          ListTile(leading: Icon(Icons.account_balance), title: Text('Bank Transfer')),
          ListTile(leading: Icon(Icons.wallet), title: Text('Crypto (Bitcoin/Eth)')),
          ListTile(leading: Icon(Icons.payments), title: Text('Financing Plan')),
        ],
      ),
    );
  }
}

// 8. COMPARE SCREEN with Simulated AI
class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String brand1 = 'BMW', model1 = 'M4 Competition';
  String brand2 = 'Mercedes', model2 = 'AMG GT Black Series';
  bool isLoading = false;
  String aiResponse = "Select two cars, tell us your purpose, and press 'Get AI Recommendation' for personalized advice.";
  String selectedPurpose = 'Daily Commute';

  final List<String> purchasePurposes = [
    'Daily Commute',
    'Family Transportation',
    'Sports & Performance',
    'Luxury & Comfort',
    'Business & Professional',
    'Off-Road Adventure',
    'Track Racing',
    'Long Distance Travel',
    'City Driving',
    'Status Symbol',
  ];

  // Simulated AI comparison responses
  final Map<String, String> comparisonDatabase = {
    'BMW_Mercedes': 'The BMW offers exceptional handling and driver engagement with its precise steering, while Mercedes delivers raw power and luxury. BMW excels in everyday usability, Mercedes in track performance. Both are engineering marvels with distinct personalities.',
    'Tesla_Lamborghini': 'Tesla brings instant electric torque and cutting-edge technology with zero emissions. Lamborghini offers visceral V10/V12 experience and exotic styling. Tesla wins efficiency and tech, Lamborghini wins emotion and prestige.',
    'Bugatti_Pagani': 'Bugatti focuses on ultimate speed and engineering precision with quad-turbo W16 power. Pagani emphasizes artisanal craftsmanship and bespoke customization. Bugatti is the speed king, Pagani is rolling art.',
    'Audi_BMW': 'Audi brings Quattro AWD technology and refined interiors. BMW delivers the ultimate driving machine philosophy with rear-wheel bias. Audi for all-weather confidence, BMW for pure driving joy.',
  };

  Future<void> _compareWithAI() async {
    setState(() {
      isLoading = true;
      aiResponse = "🤖 AI analyzing your needs and comparing vehicles...";
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate personalized recommendation based on purpose
    String recommendation = _getPersonalizedRecommendation();

    setState(() {
      aiResponse = recommendation;
      isLoading = false;
    });
  }

  String _getPersonalizedRecommendation() {
    // Get base comparison
    String key1 = '${brand1}_$brand2';
    String key2 = '${brand2}_$brand1';

    String baseComparison;
    if (comparisonDatabase.containsKey(key1)) {
      baseComparison = comparisonDatabase[key1]!;
    } else if (comparisonDatabase.containsKey(key2)) {
      baseComparison = comparisonDatabase[key2]!;
    } else {
      baseComparison = 'The $brand1 $model1 and $brand2 $model2 represent different philosophies in automotive excellence. '
          'The $brand1 emphasizes ${_getBrandTrait(brand1)}, while $brand2 focuses on ${_getBrandTrait(brand2)}.';
    }

    // Add personalized recommendation based on purpose
    String purposeAdvice = _getPurposeBasedAdvice();
    String winner = _determineWinner();

    return '📊 **COMPARISON ANALYSIS**\n\n'
        '$baseComparison\n\n'
        '🎯 **FOR YOUR PURPOSE: $selectedPurpose**\n\n'
        '$purposeAdvice\n\n'
        '✅ **AI RECOMMENDATION**: $winner\n\n'
        '💡 This recommendation is based on your stated purpose and the strengths of each vehicle.';
  }

  String _getPurposeBasedAdvice() {
    switch (selectedPurpose) {
      case 'Daily Commute':
        return 'For daily commuting, you need reliability, fuel efficiency, and comfort. ${_evaluateForCommute()}';
      case 'Family Transportation':
        return 'Family needs prioritize safety, space, and comfort. ${_evaluateForFamily()}';
      case 'Sports & Performance':
        return 'Performance enthusiasts need raw power, handling, and acceleration. ${_evaluateForSports()}';
      case 'Luxury & Comfort':
        return 'Luxury buyers seek premium materials, advanced tech, and supreme comfort. ${_evaluateForLuxury()}';
      case 'Business & Professional':
        return 'Business use demands prestige, reliability, and professional image. ${_evaluateForBusiness()}';
      case 'Off-Road Adventure':
        return 'Off-road capability requires durability, ground clearance, and 4WD systems. ${_evaluateForOffRoad()}';
      case 'Track Racing':
        return 'Track performance needs aerodynamics, power-to-weight ratio, and precision. ${_evaluateForTrack()}';
      case 'Long Distance Travel':
        return 'Long trips require comfort, fuel range, and highway stability. ${_evaluateForLongDistance()}';
      case 'City Driving':
        return 'City driving benefits from compact size, maneuverability, and parking ease. ${_evaluateForCity()}';
      case 'Status Symbol':
        return 'Status seekers want exclusivity, brand prestige, and head-turning design. ${_evaluateForStatus()}';
      default:
        return 'Both vehicles offer unique advantages for your needs.';
    }
  }

  String _evaluateForCommute() {
    if (brand1 == 'Tesla' || brand2 == 'Tesla') {
      return 'Tesla excels with zero emissions, autopilot, and minimal maintenance costs.';
    }
    return '$brand1 offers better daily usability with ${_getBrandTrait(brand1)}.';
  }

  String _evaluateForFamily() {
    List<String> suvBrands = ['Mercedes', 'BMW', 'Audi', 'Cadillac', 'Ford'];
    if (suvBrands.contains(brand1)) return '$brand1 provides superior family-friendly features.';
    if (suvBrands.contains(brand2)) return '$brand2 provides superior family-friendly features.';
    return 'Consider the model with more seating capacity and safety features.';
  }

  String _evaluateForSports() {
    List<String> sportsBrands = ['Lamborghini', 'Ferrari', 'Bugatti', 'Pagani', 'BMW', 'Mustang'];
    if (sportsBrands.contains(brand1) && !sportsBrands.contains(brand2)) return '$brand1 dominates in pure performance.';
    if (sportsBrands.contains(brand2) && !sportsBrands.contains(brand1)) return '$brand2 dominates in pure performance.';
    return 'Both offer exceptional performance, but $brand1 has a slight edge in handling.';
  }

  String _evaluateForLuxury() {
    List<String> luxuryBrands = ['Mercedes', 'Bentley', 'Cadillac', 'Audi'];
    if (luxuryBrands.contains(brand1)) return '$brand1 sets the standard for luxury and refinement.';
    if (luxuryBrands.contains(brand2)) return '$brand2 sets the standard for luxury and refinement.';
    return 'Both brands offer premium experiences with distinct characters.';
  }

  String _evaluateForBusiness() {
    if (brand1 == 'Mercedes' || brand1 == 'BMW' || brand1 == 'Audi') {
      return '$brand1 projects the perfect professional image.';
    }
    return '$brand2 offers the prestige needed for business use.';
  }

  String _evaluateForOffRoad() {
    if (brand1 == 'Ford' || brand2 == 'Ford') {
      return 'Ford excels in off-road capability with proven durability.';
    }
    return 'Consider specialized off-road variants for best performance.';
  }

  String _evaluateForTrack() {
    List<String> trackBrands = ['Ferrari', 'Lamborghini', 'Bugatti', 'Pagani'];
    if (trackBrands.contains(brand1)) return '$brand1 is purpose-built for track dominance.';
    if (trackBrands.contains(brand2)) return '$brand2 is purpose-built for track dominance.';
    return 'Both offer track-capable performance with different approaches.';
  }

  String _evaluateForLongDistance() {
    if (brand1 == 'Mercedes' || brand1 == 'BMW') {
      return '$brand1 excels in highway comfort and long-range capability.';
    }
    return '$brand2 provides excellent touring comfort.';
  }

  String _evaluateForCity() {
    if (brand1 == 'Tesla') return 'Tesla is perfect for city use with instant torque and compact design.';
    if (brand2 == 'Tesla') return 'Tesla is perfect for city use with instant torque and compact design.';
    return 'Both can handle city driving, but smaller variants are recommended.';
  }

  String _evaluateForStatus() {
    List<String> prestigeBrands = ['Bugatti', 'Pagani', 'Ferrari', 'Lamborghini', 'Bentley'];
    if (prestigeBrands.contains(brand1) && !prestigeBrands.contains(brand2)) {
      return '$brand1 offers unmatched exclusivity and prestige.';
    }
    if (prestigeBrands.contains(brand2) && !prestigeBrands.contains(brand1)) {
      return '$brand2 offers unmatched exclusivity and prestige.';
    }
    return 'Both brands command respect and admiration.';
  }

  String _determineWinner() {
    // Simple logic to determine winner based on purpose
    switch (selectedPurpose) {
      case 'Daily Commute':
        if (brand1 == 'Tesla' || brand2 == 'Tesla') return 'Tesla is ideal for daily commuting';
        return '$brand1 $model1 is better suited for daily use';
      case 'Sports & Performance':
        List<String> sportsBrands = ['Lamborghini', 'Ferrari', 'Bugatti', 'Pagani', 'Mustang'];
        if (sportsBrands.contains(brand1)) return '$brand1 $model1 wins for pure performance';
        if (sportsBrands.contains(brand2)) return '$brand2 $model2 wins for pure performance';
        return '$brand1 $model1 offers better performance value';
      case 'Luxury & Comfort':
        if (brand1 == 'Bentley' || brand1 == 'Mercedes') return '$brand1 $model1 for ultimate luxury';
        if (brand2 == 'Bentley' || brand2 == 'Mercedes') return '$brand2 $model2 for ultimate luxury';
        return '$brand1 $model1 provides superior comfort';
      case 'Family Transportation':
        return '$brand1 $model1 offers better family-friendly features';
      default:
        return 'Both are excellent choices - choose based on personal preference';
    }
  }

  String _getBrandTrait(String brand) {
    final traits = {
      'BMW': 'driving dynamics and sporty handling',
      'Mercedes': 'luxury and cutting-edge technology',
      'Audi': 'quattro AWD and refined design',
      'Tesla': 'electric innovation and autopilot',
      'Lamborghini': 'exotic styling and V12 power',
      'Bugatti': 'ultimate speed and engineering',
      'Pagani': 'artisanal craftsmanship',
      'Cadillac': 'American luxury and V8 power',
    };
    return traits[brand] ?? 'performance and luxury';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Car Comparison')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _miniSelect(brand1, model1, (b, m) => setState(() {brand1 = b; model1 = m;}))),
                const SizedBox(width: 10),
                const Text('VS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: _miniSelect(brand2, model2, (b, m) => setState(() {brand2 = b; model2 = m;}))),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎯 Why are you purchasing this car?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedPurpose,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: purchasePurposes.map((purpose) {
                        return DropdownMenuItem(
                          value: purpose,
                          child: Text(purpose),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPurpose = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _compareWithAI,
              icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.psychology),
              label: Text(isLoading ? 'Analyzing...' : 'Get AI Recommendation'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Expert Analysis:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        Text(
                          aiResponse,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _miniSelect(String b, String m, Function(String, String) onSet) {
    return Column(
      children: [
        DropdownButton<String>(
          value: b,
          isExpanded: true,
          items: brandIcons.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) {
              onSet(val, carModels[val]![0]);
            }
          },
        ),
        DropdownButton<String>(
          value: m,
          isExpanded: true,
          items: carModels[b]!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) {
              onSet(b, val);
            }
          },
        ),
      ],
    );
  }
}

// 9. ABOUT SCREEN
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About WheelzHub')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars, size: 80, color: Colors.blueGrey),
            SizedBox(height: 20),
            Text(
              'This app is made by Umar Bisharat.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Version 1.0.0'),
          ],
        ),
      ),
    );
  }
}

// Helpers for Navigation logic gaps
class DeliveryScreenPlaceholder extends StatelessWidget {
  const DeliveryScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Info')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Go to Cars -> Select a Brand -> Select a Model -> Customize -> Buy Now to initiate the delivery process.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
