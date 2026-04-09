import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

// ═══════════════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════════════

class User {
  int id;
  String name, email, password, avatar;
  double creditHours;
  DateTime joinedOn;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.creditHours,
    required this.joinedOn,
    this.avatar = '🧑',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'avatar': avatar,
    'creditHours': creditHours,
    'joinedOn': joinedOn.toIso8601String(),
  };

  factory User.fromMap(Map<String, dynamic> m) => User(
    id: m['id'],
    name: m['name'],
    email: m['email'],
    password: m['password'],
    avatar: m['avatar'] ?? '🧑',
    creditHours: m['creditHours'],
    joinedOn: DateTime.parse(m['joinedOn']),
  );
}

class Skill {
  int id, userId;
  String skillName, type, description;

  Skill({
    required this.id,
    required this.userId,
    required this.skillName,
    required this.type,
    this.description = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'skillName': skillName,
    'type': type,
    'description': description,
  };

  factory Skill.fromMap(Map<String, dynamic> m) => Skill(
    id: m['id'],
    userId: m['userId'],
    skillName: m['skillName'],
    type: m['type'],
    description: m['description'] ?? '',
  );
}

class Trade {
  int id, teacherId, learnerId, skillId;
  String teacherName, learnerName, skillName, date;
  double hours;

  Trade({
    required this.id,
    required this.teacherId,
    required this.learnerId,
    required this.skillId,
    required this.teacherName,
    required this.learnerName,
    required this.skillName,
    required this.hours,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'teacherId': teacherId,
    'learnerId': learnerId,
    'skillId': skillId,
    'teacherName': teacherName,
    'learnerName': learnerName,
    'skillName': skillName,
    'hours': hours,
    'date': date,
  };

  factory Trade.fromMap(Map<String, dynamic> m) => Trade(
    id: m['id'],
    teacherId: m['teacherId'],
    learnerId: m['learnerId'],
    skillId: m['skillId'],
    teacherName: m['teacherName'],
    learnerName: m['learnerName'],
    skillName: m['skillName'],
    hours: m['hours'],
    date: m['date'],
  );
}

class AppNotif {
  String title, message;
  IconData icon;
  Color color;
  DateTime time;
  bool isRead;

  AppNotif({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.time,
    this.isRead = false,
  });
}

// ═══════════════════════════════════════════════════════════
//  IN-MEMORY STATE
// ═══════════════════════════════════════════════════════════

List<User> users = [];
List<Skill> skills = [];
List<Trade> trades = [];
List<AppNotif> notifications = [];
User? loggedInUser;

// ═══════════════════════════════════════════════════════════
//  DATABASE HELPER
// ═══════════════════════════════════════════════════════════

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'chronotrade.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''CREATE TABLE users(
          id INTEGER PRIMARY KEY,
          name TEXT,
          email TEXT,
          password TEXT,
          avatar TEXT,
          creditHours REAL,
          joinedOn TEXT
        )''');
        await db.execute('''CREATE TABLE skills(
          id INTEGER PRIMARY KEY,
          userId INTEGER,
          skillName TEXT,
          type TEXT,
          description TEXT
        )''');
        await db.execute('''CREATE TABLE trades(
          id INTEGER PRIMARY KEY,
          teacherId INTEGER,
          learnerId INTEGER,
          skillId INTEGER,
          teacherName TEXT,
          learnerName TEXT,
          skillName TEXT,
          hours REAL,
          date TEXT
        )''');
      },
    );
  }

  // ── Users ────────────────────────────────────────────────
  static Future<void> insertUser(User u) async =>
      (await database).insert('users', u.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

  static Future<void> updateUser(User u) async =>
      (await database).update('users', u.toMap(),
          where: 'id = ?', whereArgs: [u.id]);

  static Future<List<User>> getUsers() async {
    final rows = await (await database).query('users');
    return rows.map(User.fromMap).toList();
  }

  // ── Skills ───────────────────────────────────────────────
  static Future<void> insertSkill(Skill s) async =>
      (await database).insert('skills', s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

  static Future<void> deleteSkill(int id) async =>
      (await database).delete('skills', where: 'id = ?', whereArgs: [id]);

  static Future<List<Skill>> getSkills() async {
    final rows = await (await database).query('skills');
    return rows.map(Skill.fromMap).toList();
  }

  // ── Trades ───────────────────────────────────────────────
  static Future<void> insertTrade(Trade t) async =>
      (await database).insert('trades', t.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

  static Future<void> deleteTrade(int id) async =>
      (await database).delete('trades', where: 'id = ?', whereArgs: [id]);

  static Future<List<Trade>> getTrades() async {
    final rows = await (await database).query('trades');
    return rows.map(Trade.fromMap).toList();
  }

  // ── Load everything into memory ──────────────────────────
  static Future<void> loadAll() async {
    users = await getUsers();
    skills = await getSkills();
    trades = await getTrades();
  }
}

// ═══════════════════════════════════════════════════════════
//  MAIN
// ═══════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.loadAll(); // Load persisted data before app starts
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const ChronotradeApp());
}

// ═══════════════════════════════════════════════════════════
//  LANGUAGE SYSTEM
// ═══════════════════════════════════════════════════════════

enum AppLang { english, urdu }

AppLang currentLang = AppLang.english;

String tr(String en, String ur) =>
    currentLang == AppLang.urdu ? ur : en;

// ═══════════════════════════════════════════════════════════
//  THEME SYSTEM
// ═══════════════════════════════════════════════════════════

enum AppTheme { dark, light, ocean, rose, forest, sunset }

AppTheme currentTheme = AppTheme.dark;

class ThemeConfig {
  final String name;
  final String nameUr;
  final Color primary;
  final Color secondary;
  final Color bg;
  final Color card;
  final Brightness brightness;
  final String emoji;

  const ThemeConfig({
    required this.name,
    required this.nameUr,
    required this.primary,
    required this.secondary,
    required this.bg,
    required this.card,
    required this.brightness,
    required this.emoji,
  });
}

const Map<AppTheme, ThemeConfig> themes = {
  AppTheme.dark: ThemeConfig(
    name: 'Dark', nameUr: 'سیاہ',
    primary: Color(0xFF00D4FF), secondary: Color(0xFF7C3AED),
    bg: Color(0xFF0A0E1A), card: Color(0xFF111827),
    brightness: Brightness.dark, emoji: '🌑',
  ),
  AppTheme.light: ThemeConfig(
    name: 'Light', nameUr: 'روشن',
    primary: Color(0xFF0066CC), secondary: Color(0xFF7C3AED),
    bg: Color(0xFFF0F4FF), card: Colors.white,
    brightness: Brightness.light, emoji: '☀️',
  ),
  AppTheme.ocean: ThemeConfig(
    name: 'Ocean', nameUr: 'سمندر',
    primary: Color(0xFF00B4D8), secondary: Color(0xFF0077B6),
    bg: Color(0xFF03045E), card: Color(0xFF023E8A),
    brightness: Brightness.dark, emoji: '🌊',
  ),
  AppTheme.rose: ThemeConfig(
    name: 'Rose', nameUr: 'گلابی',
    primary: Color(0xFFFF6B9D), secondary: Color(0xFFFF0080),
    bg: Color(0xFF1A0A12), card: Color(0xFF2D1020),
    brightness: Brightness.dark, emoji: '🌸',
  ),
  AppTheme.forest: ThemeConfig(
    name: 'Forest', nameUr: 'جنگل',
    primary: Color(0xFF52B788), secondary: Color(0xFF2D6A4F),
    bg: Color(0xFF081C15), card: Color(0xFF1B4332),
    brightness: Brightness.dark, emoji: '🌿',
  ),
  AppTheme.sunset: ThemeConfig(
    name: 'Sunset', nameUr: 'غروب',
    primary: Color(0xFFFF6B35), secondary: Color(0xFFFF006E),
    bg: Color(0xFF1A0A00), card: Color(0xFF2D1500),
    brightness: Brightness.dark, emoji: '🌅',
  ),
};

ThemeConfig get cfg => themes[currentTheme]!;

// ═══════════════════════════════════════════════════════════
//  AVATAR SYSTEM
// ═══════════════════════════════════════════════════════════

const List<String> avatarEmojis = [
  '🧑', '👩', '👨', '🧕', '👩‍💻', '👨‍💻',
  '👩‍🎨', '👨‍🎨', '👩‍🏫', '👨‍🏫', '🦸‍♀️', '🦸‍♂️',
  '🧙‍♀️', '🧙‍♂️', '👩‍🚀', '👨‍🚀', '🐱', '🦊',
  '🐼', '🦁', '🐸', '🤖', '👾', '🦄',
];

// ═══════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═══════════════════════════════════════════════════════════

InputDecoration ctDecor(String hint, bool dark, Color pri, {IconData? icon}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: dark ? Colors.white38 : Colors.black38),
      prefixIcon: icon != null
          ? Icon(icon, color: dark ? Colors.white38 : Colors.black38, size: 20)
          : null,
      filled: true,
      fillColor: dark
          ? Colors.white.withOpacity(.07)
          : Colors.black.withOpacity(.05),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: pri, width: 1.5)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );

Widget gBtn(String label, Color pri, VoidCallback? fn,
    {double h = 56, bool loading = false}) =>
    SizedBox(
      width: double.infinity,
      height: h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [pri, cfg.secondary]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: pri.withOpacity(.35),
                blurRadius: 18,
                offset: const Offset(0, 8))
          ],
        ),
        child: ElevatedButton(
          onPressed: fn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: loading
              ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
              : Text(label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      ),
    );

void pushNotif(
    String title, String msg, IconData icon, Color color) {
  notifications.insert(
      0,
      AppNotif(
          title: title,
          message: msg,
          icon: icon,
          color: color,
          time: DateTime.now()));
}

void snack(BuildContext ctx, String msg, Color color) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ));
}

// ═══════════════════════════════════════════════════════════
//  APP ROOT
// ═══════════════════════════════════════════════════════════

class ChronotradeApp extends StatefulWidget {
  const ChronotradeApp({super.key});
  static _AppState? of(BuildContext ctx) =>
      ctx.findAncestorStateOfType<_AppState>();
  @override
  State<ChronotradeApp> createState() => _AppState();
}

class _AppState extends State<ChronotradeApp> {
  void setTheme(AppTheme t) => setState(() => currentTheme = t);
  void setLang(AppLang l) => setState(() => currentLang = l);
  void rebuild() => setState(() {});

  ThemeData _buildTheme() {
    final c = cfg;
    return ThemeData(
      brightness: c.brightness,
      scaffoldBackgroundColor: c.bg,
      primaryColor: c.primary,
      colorScheme: ColorScheme(
        brightness: c.brightness,
        primary: c.primary,
        onPrimary: Colors.white,
        secondary: c.secondary,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: c.card,
        onSurface: c.brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
      ),
      cardColor: c.card,
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Chronotrade',
    debugShowCheckedModeBanner: false,
    theme: _buildTheme(),
    home: const SplashScreen(),
  );
}

// ═══════════════════════════════════════════════════════════
//  SPLASH
// ═══════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ac, _pulse;
  late Animation<double> _fade, _scale, _pa;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _ac,
            curve: const Interval(0, .6, curve: Curves.easeOut)));
    _scale = Tween<double>(begin: .4, end: 1).animate(
        CurvedAnimation(
            parent: _ac,
            curve:
            const Interval(0, .6, curve: Curves.elasticOut)));
    _pa = Tween<double>(begin: 1, end: 1.1).animate(
        CurvedAnimation(
            parent: _pulse, curve: Curves.easeInOut));
    _ac.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted)
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pri = cfg.primary;
    final dark = cfg.brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cfg.bg, cfg.card]),
        ),
        child: Center(
          child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _pa,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  colors: [pri, cfg.secondary]),
                              boxShadow: [
                                BoxShadow(
                                    color: pri.withOpacity(.4),
                                    blurRadius: 35,
                                    spreadRadius: 5)
                              ],
                            ),
                            child: const Icon(
                                Icons.swap_horiz_rounded,
                                size: 58,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text('CHRONOTRADE',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6,
                                color: dark
                                    ? Colors.white
                                    : Colors.black87)),
                        const SizedBox(height: 6),
                        Text(
                            tr('Skill Exchange Platform',
                                'مہارت تبادلہ پلیٹ فارم'),
                            style: TextStyle(
                                fontSize: 13,
                                letterSpacing: 2,
                                color: pri,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(
                            tr('Umar Bisharat',
                                'علینہ علی اور عمر بشارت'),
                            style: TextStyle(
                                fontSize: 11,
                                color: dark
                                    ? Colors.white38
                                    : Colors.black38,
                                letterSpacing: 1)),
                        const SizedBox(height: 55),
                        SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              backgroundColor: dark
                                  ? Colors.white12
                                  : Colors.black12,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(pri),
                            )),
                      ]))),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  LOGIN
// ═══════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _em = TextEditingController();
  final _pw = TextEditingController();
  bool _obs = true, _loading = false;
  late AnimationController _ac;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slide =
        Tween<Offset>(begin: const Offset(0, .3), end: Offset.zero)
            .animate(
            CurvedAnimation(parent: _ac, curve: Curves.easeOut));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    _em.dispose();
    _pw.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    final user = users.cast<User?>().firstWhere(
            (u) =>
        u!.email.toLowerCase() ==
            _em.text.trim().toLowerCase() &&
            u.password == _pw.text,
        orElse: () => null);
    setState(() => _loading = false);
    if (user != null) {
      loggedInUser = user;
      pushNotif(tr('Welcome back!', 'خوش آمدید!'), '${user.name}',
          Icons.waving_hand, Colors.orange);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => HomeScreen(me: user)));
    } else {
      snack(context,
          tr('❌ Wrong email or password', '❌ غلط ای میل یا پاس ورڈ'),
          Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cfg.bg, cfg.card])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: FadeTransition(
                opacity: _ac,
                child: SlideTransition(
                    position: _slide,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [pri, cfg.secondary]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: pri.withOpacity(.3),
                                    blurRadius: 20)
                              ],
                            ),
                            child: const Icon(
                                Icons.swap_horiz_rounded,
                                color: Colors.white,
                                size: 30),
                          ),
                          const SizedBox(height: 28),
                          Text(
                              tr('Welcome\nBack 👋',
                                  'خوش آمدید\nواپس 👋'),
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: dark
                                      ? Colors.white
                                      : Colors.black87,
                                  height: 1.2)),
                          const SizedBox(height: 6),
                          Text(
                              tr('Login to continue',
                                  'جاری رکھنے کے لیے لاگ ان کریں'),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: dark
                                      ? Colors.white54
                                      : Colors.black45)),
                          const SizedBox(height: 40),
                          _lbl(tr('Email', 'ای میل'), dark),
                          TextField(
                              controller: _em,
                              style: TextStyle(
                                  color: dark
                                      ? Colors.white
                                      : Colors.black87),
                              keyboardType: TextInputType.emailAddress,
                              decoration: ctDecor(
                                  'your@email.com', dark, pri,
                                  icon: Icons.email_outlined)),
                          const SizedBox(height: 14),
                          _lbl(tr('Password', 'پاس ورڈ'), dark),
                          TextField(
                              controller: _pw,
                              obscureText: _obs,
                              style: TextStyle(
                                  color: dark
                                      ? Colors.white
                                      : Colors.black87),
                              decoration: ctDecor(
                                  '••••••••', dark, pri,
                                  icon: Icons.lock_outline)
                                  .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                      _obs
                                          ? Icons.visibility_outlined
                                          : Icons
                                          .visibility_off_outlined,
                                      color: dark
                                          ? Colors.white38
                                          : Colors.black38),
                                  onPressed: () =>
                                      setState(() => _obs = !_obs),
                                ),
                              )),
                          const SizedBox(height: 28),
                          gBtn(tr('Login', 'لاگ ان'), pri,
                              _loading ? null : _login,
                              loading: _loading),
                          const SizedBox(height: 18),
                          Center(
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const RegisterScreen())),
                                child: Text.rich(TextSpan(
                                  text: tr("Don't have an account? ",
                                      "اکاؤنٹ نہیں ہے؟ "),
                                  style: TextStyle(
                                      color: dark
                                          ? Colors.white54
                                          : Colors.black45),
                                  children: [
                                    TextSpan(
                                        text: tr('Register', 'رجسٹر کریں'),
                                        style: TextStyle(
                                            color: pri,
                                            fontWeight: FontWeight.w700))
                                  ],
                                )),
                              )),
                          if (users.isEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(.1),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.orange
                                          .withOpacity(.3))),
                              child: Row(children: [
                                const Icon(Icons.info_outline,
                                    color: Colors.orange, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                        tr(
                                            'No accounts yet — register first!',
                                            'ابھی کوئی اکاؤنٹ نہیں — پہلے رجسٹر کریں!'),
                                        style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 13))),
                              ]),
                            ),
                          ],
                        ]))),
          ),
        ),
      ),
    );
  }

  Widget _lbl(String t, bool dark) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(t,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: dark ? Colors.white70 : Colors.black54)),
  );
}

// ═══════════════════════════════════════════════════════════
//  REGISTER
// ═══════════════════════════════════════════════════════════

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegState();
}

class _RegState extends State<RegisterScreen> {
  final _nc = TextEditingController();
  final _ec = TextEditingController();
  final _pc = TextEditingController();
  bool _obs = true;
  String _selectedAvatar = '🧑';

  void _pickAvatar() {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;
    showModalBottomSheet(
      context: context,
      backgroundColor:
      dark ? const Color(0xFF111827) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.3),
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(tr('Choose Avatar', 'اوتار منتخب کریں'),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: dark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8),
            itemCount: avatarEmojis.length,
            itemBuilder: (_, i) {
              final em = avatarEmojis[i];
              final sel = em == _selectedAvatar;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedAvatar = em);
                  Navigator.pop(ctx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel
                        ? pri.withOpacity(.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                        sel ? pri : Colors.transparent,
                        width: 2),
                  ),
                  child: Center(
                      child: Text(em,
                          style:
                          const TextStyle(fontSize: 26))),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  void _register() async {
    if (_nc.text.trim().isEmpty ||
        _ec.text.trim().isEmpty ||
        _pc.text.isEmpty) {
      snack(context,
          tr('⚠️ Please fill all fields', '⚠️ تمام خانے پُر کریں'),
          Colors.orange);
      return;
    }
    if (users.any((u) =>
    u.email.toLowerCase() ==
        _ec.text.trim().toLowerCase())) {
      snack(
          context,
          tr('❌ Email already registered',
              '❌ ای میل پہلے سے رجسٹرڈ ہے'),
          Colors.red);
      return;
    }
    final u = User(
      id: users.isEmpty ? 1 : users.last.id + 1,
      name: _nc.text.trim(),
      email: _ec.text.trim(),
      password: _pc.text,
      creditHours: 5.0,
      joinedOn: DateTime.now(),
      avatar: _selectedAvatar,
    );
    users.add(u);
    await DBHelper.insertUser(u); // ← SAVE TO DB
    pushNotif(
        tr('New Member 🎉', 'نیا رکن 🎉'), u.name, Icons.person_add, Colors.green);
    snack(
        context,
        tr('✅ Registered! You got 5 free credits 🎁',
            '✅ رجسٹرڈ! آپ کو 5 مفت کریڈٹ ملے 🎁'),
        Colors.green);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: dark ? Colors.white : Colors.black87),
            onPressed: () => Navigator.pop(context)),
        title: Text(tr('Create Account', 'اکاؤنٹ بنائیں'),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : Colors.black87)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.green.withOpacity(.3))),
            child: Row(children: [
              const Icon(Icons.card_giftcard,
                  color: Colors.green, size: 22),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      tr(
                          '🎁 Register and get 5 FREE credit hours!',
                          '🎁 رجسٹر کریں اور 5 مفت کریڈٹ گھنٹے پائیں!'),
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600))),
            ]),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickAvatar,
            child: Column(children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    pri.withOpacity(.3),
                    cfg.secondary.withOpacity(.3)
                  ]),
                  border: Border.all(color: pri, width: 2.5),
                ),
                child: Center(
                    child: Text(_selectedAvatar,
                        style:
                        const TextStyle(fontSize: 44))),
              ),
              const SizedBox(height: 8),
              Text(
                  tr('Tap to choose avatar',
                      'اوتار منتخب کرنے کے لیے ٹیپ کریں'),
                  style: TextStyle(
                      color: pri,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 20),
          _lbl(tr('Full Name', 'پورا نام'), dark),
          TextField(
              controller: _nc,
              style: TextStyle(
                  color: dark ? Colors.white : Colors.black87),
              textCapitalization: TextCapitalization.words,
              decoration: ctDecor(
                  tr('Umar Bisharat', 'علینہ علی'), dark, pri,
                  icon: Icons.person_outline)),
          const SizedBox(height: 14),
          _lbl(tr('Email', 'ای میل'), dark),
          TextField(
              controller: _ec,
              style: TextStyle(
                  color: dark ? Colors.white : Colors.black87),
              keyboardType: TextInputType.emailAddress,
              decoration: ctDecor('umar_bisharat@email.com', dark, pri,
                  icon: Icons.email_outlined)),
          const SizedBox(height: 14),
          _lbl(tr('Password', 'پاس ورڈ'), dark),
          TextField(
              controller: _pc,
              obscureText: _obs,
              style: TextStyle(
                  color: dark ? Colors.white : Colors.black87),
              decoration: ctDecor('••••••••', dark, pri,
                  icon: Icons.lock_outline)
                  .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                      _obs
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: dark
                          ? Colors.white38
                          : Colors.black38),
                  onPressed: () =>
                      setState(() => _obs = !_obs),
                ),
              )),
          const SizedBox(height: 30),
          gBtn(tr('Create Account', 'اکاؤنٹ بنائیں'), pri,
              _register),
        ]),
      ),
    );
  }

  Widget _lbl(String t, bool dark) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Align(
        alignment: Alignment.centerLeft,
        child: Text(t,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                dark ? Colors.white70 : Colors.black54))),
  );
}

// ═══════════════════════════════════════════════════════════
//  HOME
// ═══════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  final User me;
  const HomeScreen({super.key, required this.me});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int _idx = 0;
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;
    final unread =
        notifications.where((n) => !n.isRead).length;

    final pages = [
      DashboardTab(me: widget.me, refresh: _refresh),
      SkillsTab(me: widget.me, refresh: _refresh),
      TradesTab(me: widget.me, refresh: _refresh),
      UsersTab(me: widget.me),
      NotifTab(onOpen: _refresh),
      SettingsTab(me: widget.me, onUpdate: _refresh),
      const AboutTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cfg.card,
        elevation: 0,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                gradient:
                LinearGradient(colors: [pri, cfg.secondary]),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.swap_horiz_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text('Chronotrade',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: dark ? Colors.white : Colors.black87)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => setState(() => _idx = 5),
              child: CircleAvatar(
                backgroundColor: pri.withOpacity(.2),
                radius: 18,
                child: Text(widget.me.avatar,
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout_outlined,
                color: dark ? Colors.white70 : Colors.black54),
            onPressed: () {
              loggedInUser = null;
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: IndexedStack(index: _idx, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: cfg.card,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5))
            ]),
        child: SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _nb(0, Icons.dashboard_outlined, Icons.dashboard,
                        tr('Home', 'ہوم'), dark, pri),
                    _nb(1, Icons.psychology_outlined, Icons.psychology,
                        tr('Skills', 'مہارت'), dark, pri),
                    _nb(2, Icons.handshake_outlined, Icons.handshake,
                        tr('Trades', 'تجارت'), dark, pri),
                    _nb(3, Icons.group_outlined, Icons.group,
                        tr('Users', 'صارفین'), dark, pri),
                    _nbBadge(
                        4,
                        Icons.notifications_outlined,
                        Icons.notifications,
                        tr('Alerts', 'اطلاع'),
                        dark,
                        pri,
                        unread),
                    _nb(5, Icons.settings_outlined, Icons.settings,
                        tr('Settings', 'سیٹنگ'), dark, pri),
                    _nb(6, Icons.info_outline, Icons.info,
                        tr('About', 'بارے'), dark, pri),
                  ]),
            )),
      ),
    );
  }

  Widget _nb(int i, IconData ic, IconData aic, String lbl,
      bool dark, Color pri) {
    final sel = _idx == i;
    return GestureDetector(
      onTap: () => setState(() => _idx = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
            color: sel ? pri.withOpacity(.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(sel ? aic : ic,
              color: sel
                  ? pri
                  : (dark ? Colors.white38 : Colors.black38),
              size: 20),
          const SizedBox(height: 2),
          Text(lbl,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: sel
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: sel
                      ? pri
                      : (dark
                      ? Colors.white38
                      : Colors.black38))),
        ]),
      ),
    );
  }

  Widget _nbBadge(int i, IconData ic, IconData aic, String lbl,
      bool dark, Color pri, int count) {
    final sel = _idx == i;
    return GestureDetector(
      onTap: () => setState(() => _idx = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
            color: sel ? pri.withOpacity(.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(children: [
            Icon(sel ? aic : ic,
                color: sel
                    ? pri
                    : (dark ? Colors.white38 : Colors.black38),
                size: 20),
            if (count > 0)
              Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle))),
          ]),
          const SizedBox(height: 2),
          Text(lbl,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: sel
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: sel
                      ? pri
                      : (dark
                      ? Colors.white38
                      : Colors.black38))),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SETTINGS TAB
// ═══════════════════════════════════════════════════════════

class SettingsTab extends StatefulWidget {
  final User me;
  final VoidCallback onUpdate;
  const SettingsTab(
      {super.key, required this.me, required this.onUpdate});
  @override
  State<SettingsTab> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsTab> {
  void _pickAvatar() {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;
    showModalBottomSheet(
      context: context,
      backgroundColor: cfg.card,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.3),
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(tr('Choose Your Avatar', 'اپنا اوتار منتخب کریں'),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: dark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10),
            itemCount: avatarEmojis.length,
            itemBuilder: (_, i) {
              final em = avatarEmojis[i];
              final sel = em == widget.me.avatar;
              return GestureDetector(
                onTap: () async {
                  setState(() => widget.me.avatar = em);
                  await DBHelper.updateUser(widget.me); // ← SAVE
                  widget.onUpdate();
                  Navigator.pop(ctx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel
                        ? pri.withOpacity(.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel
                            ? pri
                            : Colors.grey.withOpacity(.2),
                        width: 2),
                  ),
                  child: Center(
                      child: Text(em,
                          style:
                          const TextStyle(fontSize: 26))),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;
    final app = ChronotradeApp.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr('Settings', 'سیٹنگز'),
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: dark ? Colors.white : Colors.black87)),
        const SizedBox(height: 20),
        _sectionTitle(tr('👤 Your Profile', '👤 آپ کا پروفائل'), dark),
        _card(
            dark,
            Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [
                            pri.withOpacity(.3),
                            cfg.secondary.withOpacity(.3)
                          ]),
                          border:
                          Border.all(color: pri, width: 2.5)),
                      child: Center(
                          child: Text(widget.me.avatar,
                              style:
                              const TextStyle(fontSize: 36))),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: pri, shape: BoxShape.circle),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 12),
                        )),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(widget.me.name,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: dark
                                      ? Colors.white
                                      : Colors.black87)),
                          Text(widget.me.email,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: dark
                                      ? Colors.white54
                                      : Colors.black45)),
                          Text(
                              '${widget.me.creditHours.toStringAsFixed(1)} ${tr('credits', 'کریڈٹ')}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: pri,
                                  fontWeight: FontWeight.w700)),
                        ])),
              ]),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickAvatar,
                icon: const Text('😊',
                    style: TextStyle(fontSize: 16)),
                label: Text(
                    tr('Change Avatar', 'اوتار تبدیل کریں'),
                    style: TextStyle(
                        color: pri, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: pri),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
            ])),
        const SizedBox(height: 20),
        _sectionTitle(tr('🌐 Language', '🌐 زبان'), dark),
        _card(
            dark,
            Column(children: [
              _langTile(tr('English', 'انگریزی'), '🇺🇸',
                  AppLang.english, dark, pri, app),
              const Divider(height: 1),
              _langTile('اردو', '🇵🇰', AppLang.urdu, dark, pri, app),
            ])),
        const SizedBox(height: 20),
        _sectionTitle(tr('🎨 Theme', '🎨 تھیم'), dark),
        _card(
            dark,
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: themes.entries.map((e) {
                final t = e.key;
                final tc = e.value;
                final sel = currentTheme == t;
                return GestureDetector(
                  onTap: () {
                    app?.setTheme(t);
                    setState(() {});
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel
                          ? tc.primary.withOpacity(.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: sel
                              ? tc.primary
                              : Colors.grey.withOpacity(.3),
                          width: sel ? 2 : 1),
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tc.emoji,
                              style:
                              const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                    currentLang == AppLang.urdu
                                        ? tc.nameUr
                                        : tc.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: sel
                                            ? tc.primary
                                            : (dark
                                            ? Colors.white70
                                            : Colors.black54))),
                                Row(children: [
                                  Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(
                                          right: 3),
                                      decoration: BoxDecoration(
                                          color: tc.primary,
                                          shape: BoxShape.circle)),
                                  Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: tc.secondary,
                                          shape: BoxShape.circle)),
                                ]),
                              ]),
                          if (sel) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.check_circle,
                                color: tc.primary, size: 16)
                          ],
                        ]),
                  ),
                );
              }).toList(),
            )),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _langTile(String name, String flag, AppLang lang,
      bool dark, Color pri, _AppState? app) {
    final sel = currentLang == lang;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: dark ? Colors.white : Colors.black87)),
      trailing:
      sel ? Icon(Icons.check_circle, color: pri) : null,
      onTap: () {
        app?.setLang(lang);
        setState(() {});
      },
    );
  }

  Widget _sectionTitle(String t, bool dark) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: dark ? Colors.white : Colors.black87)),
  );

  Widget _card(bool dark, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: cfg.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12)
        ]),
    child: child,
  );
}

// ═══════════════════════════════════════════════════════════
//  DASHBOARD TAB
// ═══════════════════════════════════════════════════════════

class DashboardTab extends StatelessWidget {
  final User me;
  final VoidCallback refresh;
  const DashboardTab(
      {super.key, required this.me, required this.refresh});

  @override
  Widget build(BuildContext context) {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;
    final mySkills =
    skills.where((s) => s.userId == me.id).toList();
    final myTrades = trades
        .where(
            (t) => t.teacherId == me.id || t.learnerId == me.id)
        .toList();
    final earned = myTrades
        .where((t) => t.teacherId == me.id)
        .fold(0.0, (s, t) => s + t.hours);
    final spent = myTrades
        .where((t) => t.learnerId == me.id)
        .fold(0.0, (s, t) => s + t.hours);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [pri, cfg.secondary]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: pri.withOpacity(.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10))
            ],
          ),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('Credit Balance', 'کریڈٹ بیلنس'),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(tr('ACTIVE', 'فعال'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700))),
                ]),
            const SizedBox(height: 8),
            Text(
                '${me.creditHours.toStringAsFixed(1)} ${tr('hrs', 'گھنٹے')}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Text(me.avatar,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(me.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          Text(me.email,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 11)),
                        ]),
                  ]),
                  const Icon(Icons.swap_horiz_rounded,
                      color: Colors.white60, size: 28),
                ]),
          ]),
        ),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
              child: _mini(
                  '${earned.toStringAsFixed(1)}h',
                  tr('Earned', 'کمایا'),
                  Icons.arrow_downward,
                  Colors.green,
                  dark)),
          const SizedBox(width: 10),
          Expanded(
              child: _mini(
                  '${spent.toStringAsFixed(1)}h',
                  tr('Spent', 'خرچ'),
                  Icons.arrow_upward,
                  Colors.red,
                  dark)),
          const SizedBox(width: 10),
          Expanded(
              child: _mini(
                  '${mySkills.length}',
                  tr('Skills', 'مہارت'),
                  Icons.psychology_outlined,
                  pri,
                  dark)),
          const SizedBox(width: 10),
          Expanded(
              child: _mini(
                  '${myTrades.length}',
                  tr('Trades', 'تجارت'),
                  Icons.handshake_outlined,
                  Colors.orange,
                  dark)),
        ]),
        const SizedBox(height: 22),
        Text(
            '🏆 ${tr('Leaderboard', 'لیڈر بورڈ')}',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: dark ? Colors.white : Colors.black87)),
        const SizedBox(height: 10),
        if (users.isEmpty)
          _empty(tr('No users yet', 'ابھی کوئی صارف نہیں'), dark)
        else
          ...() {
            final sorted = List<User>.from(users)
              ..sort(
                      (a, b) => b.creditHours.compareTo(a.creditHours));
            return sorted
                .take(3)
                .toList()
                .asMap()
                .entries
                .map((e) {
              final medals = ['🥇', '🥈', '🥉'];
              final u = e.value;
              final isMe = u.id == me.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cfg.card,
                  borderRadius: BorderRadius.circular(14),
                  border: isMe
                      ? Border.all(color: pri, width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8)
                  ],
                ),
                child: Row(children: [
                  Text(medals[e.key],
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(u.avatar,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          u.name +
                              (isMe
                                  ? ' (${tr('You', 'آپ')})'
                                  : ''),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: dark
                                  ? Colors.white
                                  : Colors.black87))),
                  Text(
                      '${u.creditHours.toStringAsFixed(1)} ${tr('hrs', 'گھنٹے')}',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: pri)),
                ]),
              );
            });
          }(),
        if (myTrades.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(tr('Recent Trades', 'حالیہ تجارت'),
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: dark ? Colors.white : Colors.black87)),
          const SizedBox(height: 10),
          ...myTrades.take(4).map((t) {
            final isTeacher = t.teacherId == me.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: cfg.card,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8)
                  ]),
              child: Row(children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: isTeacher
                            ? Colors.green.withOpacity(.15)
                            : Colors.red.withOpacity(.15),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                        isTeacher
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: isTeacher
                            ? Colors.green
                            : Colors.red,
                        size: 18)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(t.skillName,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: dark
                                      ? Colors.white
                                      : Colors.black87)),
                          Text(
                              isTeacher
                                  ? '${tr('Taught', 'پڑھایا')} ${t.learnerName}'
                                  : '${tr('Learned from', 'سیکھا')} ${t.teacherName}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: dark
                                      ? Colors.white54
                                      : Colors.black45)),
                        ])),
                Text(
                    '${isTeacher ? '+' : '-'}${t.hours}h',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isTeacher
                            ? Colors.green
                            : Colors.red)),
              ]),
            );
          }),
        ],
      ]),
    );
  }

  Widget _mini(
      String v, String lbl, IconData ic, Color c, bool dark) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: cfg.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 10)
            ]),
        child: Column(children: [
          Icon(ic, color: c, size: 20),
          const SizedBox(height: 6),
          Text(v,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: dark ? Colors.white : Colors.black87)),
          Text(lbl,
              style: TextStyle(
                  fontSize: 10,
                  color:
                  dark ? Colors.white38 : Colors.black38)),
        ]),
      );

  Widget _empty(String t, bool dark) => Center(
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(t,
              style: TextStyle(
                  color: dark
                      ? Colors.white38
                      : Colors.black38))));
}

// ═══════════════════════════════════════════════════════════
//  SKILLS TAB
// ═══════════════════════════════════════════════════════════

class SkillsTab extends StatefulWidget {
  final User me;
  final VoidCallback refresh;
  const SkillsTab(
      {super.key, required this.me, required this.refresh});
  @override
  State<SkillsTab> createState() => _SkillsState();
}

class _SkillsState extends State<SkillsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _add() {
    final nc = TextEditingController();
    final dc = TextEditingController();
    String type = 'offer';
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cfg.card,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) =>
          StatefulBuilder(builder: (ctx, ss) => Padding(
            padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom:
                MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color:
                              Colors.grey.withOpacity(.3),
                              borderRadius:
                              BorderRadius.circular(2)))),
                  const SizedBox(height: 18),
                  Text(
                      tr('Add New Skill',
                          'نئی مہارت شامل کریں'),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: dark
                              ? Colors.white
                              : Colors.black87)),
                  const SizedBox(height: 18),
                  TextField(
                      controller: nc,
                      style: TextStyle(
                          color: dark
                              ? Colors.white
                              : Colors.black87),
                      textCapitalization:
                      TextCapitalization.words,
                      decoration: ctDecor(
                          tr('e.g. Java, Cooking',
                              'مثلاً جاوا، کھانا بنانا'),
                          dark,
                          pri,
                          icon:
                          Icons.psychology_outlined)),
                  const SizedBox(height: 12),
                  TextField(
                      controller: dc,
                      style: TextStyle(
                          color: dark
                              ? Colors.white
                              : Colors.black87),
                      decoration: ctDecor(
                          tr('Description (optional)',
                              'تفصیل (اختیاری)'),
                          dark,
                          pri,
                          icon:
                          Icons.description_outlined)),
                  const SizedBox(height: 14),
                  Row(
                      children: ['offer', 'wanted']
                          .map((t) {
                        final sel = type == t;
                        return Expanded(
                            child: GestureDetector(
                              onTap: () => ss(() => type = t),
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(
                                    right: t == 'offer' ? 6 : 0,
                                    left: t == 'wanted' ? 6 : 0),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                decoration: BoxDecoration(
                                    color: sel
                                        ? pri
                                        : pri.withOpacity(.1),
                                    borderRadius:
                                    BorderRadius.circular(12)),
                                child: Text(
                                  t == 'offer'
                                      ? tr('🎓 Offering',
                                      '🎓 پیش کرنا')
                                      : tr('📚 Wanted',
                                      '📚 مطلوب'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: sel
                                          ? Colors.white
                                          : pri,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                ),
                              ),
                            ));
                      }).toList()),
                  const SizedBox(height: 20),
                  gBtn(tr('Add Skill', 'مہارت شامل کریں'),
                      pri, () async {
                        if (nc.text.trim().isNotEmpty) {
                          final newSkill = Skill(
                              id: skills.isEmpty
                                  ? 1
                                  : skills.last.id + 1,
                              userId: widget.me.id,
                              skillName: nc.text.trim(),
                              type: type,
                              description: dc.text.trim());
                          setState(() =>
                              skills.add(newSkill));
                          await DBHelper.insertSkill(
                              newSkill); // ← SAVE
                          pushNotif(
                              tr('Skill Added',
                                  'مہارت شامل ہوئی'),
                              nc.text.trim(),
                              Icons.psychology,
                              Colors.blue);
                          widget.refresh();
                          Navigator.pop(ctx);
                        }
                      }, h: 52),
                ]),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;
    final offered = skills
        .where((s) =>
    s.type == 'offer' &&
        s.skillName
            .toLowerCase()
            .contains(_q.toLowerCase()))
        .toList();
    final wanted = skills
        .where((s) =>
    s.type == 'wanted' &&
        s.skillName
            .toLowerCase()
            .contains(_q.toLowerCase()))
        .toList();

    return Column(children: [
      Padding(
          padding:
          const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('Skills', 'مہارتیں'),
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: dark
                            ? Colors.white
                            : Colors.black87)),
                ElevatedButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add,
                      size: 18, color: Colors.white),
                  label: Text(tr('Add', 'شامل'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: pri,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10)),
                ),
              ])),
      Padding(
          padding:
          const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: TextField(
              onChanged: (v) =>
                  setState(() => _q = v),
              style: TextStyle(
                  color: dark
                      ? Colors.white
                      : Colors.black87),
              decoration: ctDecor(
                  tr('Search skills...',
                      'مہارتیں تلاش کریں...'),
                  dark,
                  pri,
                  icon: Icons.search))),
      const SizedBox(height: 10),
      TabBar(
        controller: _tab,
        labelColor: pri,
        unselectedLabelColor:
        dark ? Colors.white38 : Colors.black38,
        indicatorColor: pri,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: [
          Tab(
              text:
              '🎓 ${tr('Offering', 'پیش کرنا')} (${offered.length})'),
          Tab(
              text:
              '📚 ${tr('Wanted', 'مطلوب')} (${wanted.length})'),
        ],
      ),
      Expanded(
          child: TabBarView(controller: _tab, children: [
            _list(offered, dark, pri),
            _list(wanted, dark, pri)
          ])),
    ]);
  }

  Widget _list(List<Skill> list, bool dark, Color pri) {
    if (list.isEmpty)
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology_outlined,
                    size: 48,
                    color: dark
                        ? Colors.white24
                        : Colors.black12),
                const SizedBox(height: 12),
                Text(tr('No skills found', 'کوئی مہارت نہیں ملی'),
                    style: TextStyle(
                        color: dark
                            ? Colors.white38
                            : Colors.black38)),
              ]));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final s = list[i];
        final owner = users
            .cast<User?>()
            .firstWhere((u) => u!.id == s.userId,
            orElse: () => null);
        final mine = s.userId == widget.me.id;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: cfg.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10)
              ]),
          child: Row(children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      pri.withOpacity(.7),
                      cfg.secondary.withOpacity(.7)
                    ]),
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Text(
                        s.skillName[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18)))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(s.skillName,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: dark
                                  ? Colors.white
                                  : Colors.black87)),
                      if (s.description.isNotEmpty)
                        Text(s.description,
                            style: TextStyle(
                                fontSize: 12,
                                color: dark
                                    ? Colors.white54
                                    : Colors.black45),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      Row(children: [
                        Text(owner?.avatar ?? '🧑',
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                            '${tr('by', 'از')} ${owner?.name ?? '?'}',
                            style: TextStyle(
                                fontSize: 11,
                                color: pri,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ])),
            if (mine)
              GestureDetector(
                onTap: () async {
                  setState(() => skills.remove(s));
                  await DBHelper.deleteSkill(s.id); // ← DELETE
                  widget.refresh();
                },
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(.1),
                        borderRadius:
                        BorderRadius.circular(10)),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18)),
              ),
          ]),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TRADES TAB
// ═══════════════════════════════════════════════════════════

class TradesTab extends StatefulWidget {
  final User me;
  final VoidCallback refresh;
  const TradesTab(
      {super.key, required this.me, required this.refresh});
  @override
  State<TradesTab> createState() => _TradesState();
}

class _TradesState extends State<TradesTab> {
  void _record() {
    User? teacher;
    User? learner;
    Skill? selSkill;
    double hours = 1.0;
    final hCtrl = TextEditingController(text: '1.0');
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cfg.card,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) =>
          StatefulBuilder(builder: (ctx, ss) {
            final teacherSkills = teacher == null
                ? <Skill>[]
                : skills
                .where((s) =>
            s.userId == teacher!.id &&
                s.type == 'offer')
                .toList();
            final learners = teacher == null
                ? users
                : users
                .where((u) => u.id != teacher!.id)
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom:
                  MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                    color:
                                    Colors.grey.withOpacity(.3),
                                    borderRadius:
                                    BorderRadius.circular(2)))),
                        const SizedBox(height: 18),
                        Text(
                            tr('Record Trade',
                                'تجارت ریکارڈ کریں'),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: dark
                                    ? Colors.white
                                    : Colors.black87)),
                        const SizedBox(height: 20),
                        _step(
                            tr('1. Who is Teaching?',
                                '۱. کون پڑھا رہا ہے؟'),
                            dark),
                        DropdownButtonFormField<int>(
                          value: teacher?.id,
                          dropdownColor: cfg.card,
                          style: TextStyle(
                              color: dark
                                  ? Colors.white
                                  : Colors.black87),
                          decoration: ctDecor(
                              tr('Select teacher',
                                  'استاد منتخب کریں'),
                              dark,
                              pri,
                              icon: Icons.school_outlined),
                          items: users
                              .map((u) => DropdownMenuItem(
                              value: u.id,
                              child: Row(children: [
                                Text(u.avatar,
                                    style: const TextStyle(
                                        fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(u.name)
                              ])))
                              .toList(),
                          onChanged: (v) => ss(() {
                            teacher = users
                                .firstWhere((u) => u.id == v!);
                            selSkill = null;
                            if (learner?.id == teacher?.id)
                              learner = null;
                          }),
                        ),
                        const SizedBox(height: 16),
                        _step(
                            tr('2. Which Skill?',
                                '۲. کون سی مہارت؟'),
                            dark),
                        if (teacher == null)
                          _info(
                              tr('👆 Select teacher first',
                                  '👆 پہلے استاد منتخب کریں'),
                              Colors.orange,
                              dark)
                        else if (teacherSkills.isEmpty)
                          _info(
                              tr(
                                  '⚠️ ${teacher!.name} has no offering skills yet',
                                  '⚠️ ${teacher!.name} کی ابھی کوئی مہارت نہیں'),
                              Colors.red,
                              dark)
                        else
                          DropdownButtonFormField<int>(
                            value: selSkill?.id,
                            dropdownColor: cfg.card,
                            style: TextStyle(
                                color: dark
                                    ? Colors.white
                                    : Colors.black87),
                            decoration: ctDecor(
                                tr('Select skill',
                                    'مہارت منتخب کریں'),
                                dark,
                                pri,
                                icon: Icons.psychology_outlined),
                            items: teacherSkills
                                .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.skillName)))
                                .toList(),
                            onChanged: (v) => ss(() => selSkill =
                                teacherSkills
                                    .firstWhere((s) => s.id == v!)),
                          ),
                        const SizedBox(height: 16),
                        _step(
                            tr('3. Who is Learning?',
                                '۳. کون سیکھ رہا ہے؟'),
                            dark),
                        DropdownButtonFormField<int>(
                          value: learner?.id,
                          dropdownColor: cfg.card,
                          style: TextStyle(
                              color: dark
                                  ? Colors.white
                                  : Colors.black87),
                          decoration: ctDecor(
                              tr('Select learner',
                                  'سیکھنے والا منتخب کریں'),
                              dark,
                              pri,
                              icon: Icons.person_outline),
                          items: learners
                              .map((u) => DropdownMenuItem(
                              value: u.id,
                              child: Row(children: [
                                Text(u.avatar,
                                    style: const TextStyle(
                                        fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(u.name)
                              ])))
                              .toList(),
                          onChanged: (v) => ss(() => learner =
                              learners
                                  .firstWhere((u) => u.id == v!)),
                        ),
                        const SizedBox(height: 16),
                        _step(
                            tr('4. How Many Hours?',
                                '۴. کتنے گھنٹے؟'),
                            dark),
                        TextField(
                            controller: hCtrl,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (v) =>
                            hours = double.tryParse(v) ?? 1.0,
                            style: TextStyle(
                                color: dark
                                    ? Colors.white
                                    : Colors.black87),
                            decoration: ctDecor('1.5', dark, pri,
                                icon: Icons.timer_outlined)),
                        const SizedBox(height: 24),
                        gBtn(
                            tr('Record Trade',
                                'تجارت ریکارڈ کریں'),
                            pri, () async {
                          if (teacher == null ||
                              learner == null ||
                              selSkill == null) {
                            snack(
                                ctx,
                                tr('⚠️ Complete all steps',
                                    '⚠️ تمام مراحل مکمل کریں'),
                                Colors.orange);
                            return;
                          }
                          final newTrade = Trade(
                              id: trades.isEmpty
                                  ? 1
                                  : trades.last.id + 1,
                              teacherId: teacher!.id,
                              learnerId: learner!.id,
                              skillId: selSkill!.id,
                              teacherName: teacher!.name,
                              learnerName: learner!.name,
                              skillName: selSkill!.skillName,
                              hours: hours,
                              date: DateTime.now()
                                  .toString()
                                  .substring(0, 10));
                          setState(() {
                            trades.add(newTrade);
                            teacher!.creditHours += hours;
                            learner!.creditHours -= hours;
                          });
                          await DBHelper.insertTrade(
                              newTrade); // ← SAVE TRADE
                          await DBHelper.updateUser(
                              teacher!); // ← SAVE CREDITS
                          await DBHelper.updateUser(learner!);
                          pushNotif(
                              tr('Trade Done! 🤝',
                                  'تجارت مکمل! 🤝'),
                              '${teacher!.name} → ${learner!.name}',
                              Icons.handshake,
                              Colors.teal);
                          widget.refresh();
                          Navigator.pop(ctx);
                          snack(
                              context,
                              tr(
                                  '✅ ${teacher!.name} earned ${hours}h!',
                                  '✅ ${teacher!.name} نے ${hours}گھنٹے کمائے!'),
                              Colors.green);
                        }, h: 52),
                      ])),
            );
          }),
    );
  }

  void _delete(Trade t) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cfg.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text(
              tr('Delete Trade?', 'تجارت حذف کریں؟'),
              style: const TextStyle(
                  fontWeight: FontWeight.w800)),
          content: Text(tr('Credits will be reversed.',
              'کریڈٹ واپس کر دیے جائیں گے۔')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(tr('Cancel', 'منسوخ'))),
            ElevatedButton(
              onPressed: () async {
                final teacherUser = users
                    .cast<User?>()
                    .firstWhere(
                        (u) => u!.id == t.teacherId,
                    orElse: () => null);
                final learnerUser = users
                    .cast<User?>()
                    .firstWhere(
                        (u) => u!.id == t.learnerId,
                    orElse: () => null);
                setState(() {
                  teacherUser?.creditHours -= t.hours;
                  learnerUser?.creditHours += t.hours;
                  trades.remove(t);
                });
                await DBHelper.deleteTrade(
                    t.id); // ← DELETE
                if (teacherUser != null)
                  await DBHelper.updateUser(
                      teacherUser); // ← UPDATE CREDITS
                if (learnerUser != null)
                  await DBHelper.updateUser(learnerUser);
                widget.refresh();
                Navigator.pop(ctx);
                snack(
                    context,
                    tr('🗑️ Trade deleted',
                        '🗑️ تجارت حذف ہوئی'),
                    Colors.orange);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12))),
              child: Text(tr('Delete', 'حذف'),
                  style: const TextStyle(
                      color: Colors.white)),
            ),
          ],
        ));
  }

  Widget _step(String t, bool dark) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color:
              dark ? Colors.white54 : Colors.black45)));

  Widget _info(String msg, Color c, bool dark) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: c.withOpacity(.08),
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: c.withOpacity(.25))),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: c, size: 16),
            const SizedBox(width: 8),
            Expanded(
                child: Text(msg,
                    style:
                    TextStyle(color: c, fontSize: 13))),
          ]));

  @override
  Widget build(BuildContext context) {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;

    return Column(children: [
      Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('Trades', 'تجارت'),
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: dark
                            ? Colors.white
                            : Colors.black87)),
                ElevatedButton.icon(
                  onPressed: _record,
                  icon: const Icon(Icons.add,
                      size: 18, color: Colors.white),
                  label: Text(tr('Record', 'ریکارڈ'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: pri,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10)),
                ),
              ])),
      Expanded(
          child: trades.isEmpty
              ? Center(
              child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(Icons.handshake_outlined,
                        size: 56,
                        color: dark
                            ? Colors.white24
                            : Colors.black12),
                    const SizedBox(height: 14),
                    Text(
                        tr('No trades yet',
                            'ابھی کوئی تجارت نہیں'),
                        style: TextStyle(
                            fontSize: 16,
                            color: dark
                                ? Colors.white38
                                : Colors.black38)),
                  ]))
              : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              itemCount: trades.length,
              itemBuilder: (_, i) {
                final t = trades[i];
                return Container(
                  margin:
                  const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: cfg.card,
                      borderRadius:
                      BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black
                                .withOpacity(.05),
                            blurRadius: 10)
                      ]),
                  child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(t.skillName,
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.w700,
                                          fontSize: 15,
                                          color: dark
                                              ? Colors.white
                                              : Colors
                                              .black87))),
                              Container(
                                  padding: const EdgeInsets
                                      .symmetric(
                                      horizontal: 10,
                                      vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.green
                                          .withOpacity(.15),
                                      borderRadius:
                                      BorderRadius
                                          .circular(20)),
                                  child: Text('${t.hours}h',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight:
                                          FontWeight.w700,
                                          fontSize: 13))),
                              const SizedBox(width: 6),
                              GestureDetector(
                                  onTap: () => _delete(t),
                                  child: Container(
                                      padding:
                                      const EdgeInsets.all(
                                          6),
                                      decoration: BoxDecoration(
                                          color: Colors.red
                                              .withOpacity(.1),
                                          borderRadius:
                                          BorderRadius
                                              .circular(8)),
                                      child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 18))),
                            ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.school_outlined,
                              size: 13,
                              color: dark
                                  ? Colors.white54
                                  : Colors.black45),
                          const SizedBox(width: 4),
                          Text(t.teacherName,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: dark
                                      ? Colors.white70
                                      : Colors.black54)),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward,
                              size: 13,
                              color: dark
                                  ? Colors.white38
                                  : Colors.black38),
                          const SizedBox(width: 8),
                          Icon(Icons.person_outline,
                              size: 13,
                              color: dark
                                  ? Colors.white54
                                  : Colors.black45),
                          const SizedBox(width: 4),
                          Text(t.learnerName,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: dark
                                      ? Colors.white70
                                      : Colors.black54)),
                          const Spacer(),
                          Text(t.date,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: dark
                                      ? Colors.white38
                                      : Colors.black38)),
                        ]),
                      ]),
                );
              })),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════
//  USERS TAB
// ═══════════════════════════════════════════════════════════

class UsersTab extends StatelessWidget {
  final User me;
  const UsersTab({super.key, required this.me});

  @override
  Widget build(BuildContext context) {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;
    final colors = [
      const Color(0xFF00D4FF),
      const Color(0xFF7C3AED),
      Colors.orange,
      Colors.green,
      Colors.pink,
      Colors.teal
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                  '${tr('All Users', 'تمام صارفین')} (${users.length})',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color:
                      dark ? Colors.white : Colors.black87))),
          Expanded(
              child: users.isEmpty
                  ? Center(
                  child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined,
                            size: 56,
                            color: dark
                                ? Colors.white24
                                : Colors.black12),
                        const SizedBox(height: 14),
                        Text(
                            tr('No users yet',
                                'ابھی کوئی صارف نہیں'),
                            style: TextStyle(
                                color: dark
                                    ? Colors.white38
                                    : Colors.black38)),
                      ]))
                  : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final u = users[i];
                    final isMe = u.id == me.id;
                    final c = colors[i % colors.length];
                    final uSkills = skills
                        .where((s) => s.userId == u.id)
                        .length;
                    final uTrades = trades
                        .where((t) =>
                    t.teacherId == u.id ||
                        t.learnerId == u.id)
                        .length;

                    return Container(
                      margin:
                      const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: cfg.card,
                          borderRadius:
                          BorderRadius.circular(16),
                          border: isMe
                              ? Border.all(
                              color: pri, width: 1.5)
                              : null,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black
                                    .withOpacity(.05),
                                blurRadius: 10)
                          ]),
                      child: Column(children: [
                        Row(children: [
                          Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                  color: c.withOpacity(.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                      c.withOpacity(.4),
                                      width: 2)),
                              child: Center(
                                  child: Text(u.avatar,
                                      style: const TextStyle(
                                          fontSize: 26)))),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Row(children: [
                                      Flexible(
                                          child: Text(u.name,
                                              style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.w700,
                                                  fontSize: 15,
                                                  color: dark
                                                      ? Colors.white
                                                      : Colors
                                                      .black87))),
                                      if (isMe) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 8,
                                                vertical: 2),
                                            decoration: BoxDecoration(
                                                color: pri
                                                    .withOpacity(.15),
                                                borderRadius:
                                                BorderRadius
                                                    .circular(20)),
                                            child: Text(
                                                tr('You', 'آپ'),
                                                style: TextStyle(
                                                    color: pri,
                                                    fontSize: 11,
                                                    fontWeight:
                                                    FontWeight
                                                        .w700)))
                                      ],
                                    ]),
                                    Text(u.email,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: dark
                                                ? Colors.white54
                                                : Colors.black45)),
                                  ])),
                          Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.end,
                              children: [
                                Text(
                                    u.creditHours
                                        .toStringAsFixed(1),
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight:
                                        FontWeight.w900,
                                        color: c)),
                                Text(tr('credits', 'کریڈٹ'),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: dark
                                            ? Colors.white38
                                            : Colors.black38)),
                              ]),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          _chip(
                              '$uSkills ${tr('skills', 'مہارت')}',
                              Icons.psychology_outlined,
                              c,
                              dark),
                          const SizedBox(width: 8),
                          _chip(
                              '$uTrades ${tr('trades', 'تجارت')}',
                              Icons.handshake_outlined,
                              Colors.teal,
                              dark),
                        ]),
                      ]),
                    );
                  })),
        ]);
  }

  Widget _chip(
      String lbl, IconData ic, Color c, bool dark) =>
      Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: c.withOpacity(.1),
              borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(ic, size: 11, color: c),
            const SizedBox(width: 4),
            Text(lbl,
                style: TextStyle(
                    fontSize: 11,
                    color: c,
                    fontWeight: FontWeight.w600)),
          ]));
}

// ═══════════════════════════════════════════════════════════
//  NOTIFICATIONS TAB
// ═══════════════════════════════════════════════════════════

class NotifTab extends StatefulWidget {
  final VoidCallback onOpen;
  const NotifTab({super.key, required this.onOpen});
  @override
  State<NotifTab> createState() => _NotifState();
}

class _NotifState extends State<NotifTab> {
  @override
  void initState() {
    super.initState();
    for (var n in notifications) n.isRead = true;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onOpen());
  }

  @override
  Widget build(BuildContext context) {
    final dark = cfg.brightness == Brightness.dark;

    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr('Notifications', 'اطلاعات'),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: dark
                                ? Colors.white
                                : Colors.black87)),
                    if (notifications.isNotEmpty)
                      TextButton(
                          onPressed: () =>
                              setState(() => notifications.clear()),
                          child: Text(
                              tr('Clear All', 'سب صاف کریں'),
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600))),
                  ])),
          Expanded(
              child: notifications.isEmpty
                  ? Center(
                  child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none_outlined,
                            size: 56,
                            color: dark
                                ? Colors.white24
                                : Colors.black12),
                        const SizedBox(height: 14),
                        Text(
                            tr('No notifications yet',
                                'ابھی کوئی اطلاع نہیں'),
                            style: TextStyle(
                                color: dark
                                    ? Colors.white38
                                    : Colors.black38)),
                      ]))
                  : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  itemCount: notifications.length,
                  itemBuilder: (_, i) {
                    final n = notifications[i];
                    return Container(
                      margin:
                      const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: cfg.card,
                          borderRadius:
                          BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black
                                    .withOpacity(.05),
                                blurRadius: 8)
                          ]),
                      child: Row(children: [
                        Container(
                            padding:
                            const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color:
                                n.color.withOpacity(.15),
                                borderRadius:
                                BorderRadius.circular(12)),
                            child: Icon(n.icon,
                                color: n.color, size: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(n.title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: dark
                                              ? Colors.white
                                              : Colors.black87)),
                                  Text(n.message,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: dark
                                              ? Colors.white54
                                              : Colors.black45)),
                                  Text(
                                      '${n.time.hour}:${n.time.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: dark
                                              ? Colors.white38
                                              : Colors.black38)),
                                ])),
                      ]),
                    );
                  })),
        ]);
  }
}

// ═══════════════════════════════════════════════════════════
//  ABOUT TAB
// ═══════════════════════════════════════════════════════════

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = cfg.brightness == Brightness.dark;
    final pri = cfg.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 10),
        Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                LinearGradient(colors: [pri, cfg.secondary]),
                boxShadow: [
                  BoxShadow(
                      color: pri.withOpacity(.4),
                      blurRadius: 25,
                      spreadRadius: 4)
                ]),
            child: const Icon(Icons.swap_horiz_rounded,
                size: 50, color: Colors.white)),
        const SizedBox(height: 18),
        Text('CHRONOTRADE',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: dark ? Colors.white : Colors.black87)),
        const SizedBox(height: 4),
        Text(tr('Skill Exchange Platform', 'مہارت تبادلہ پلیٹ فارم'),
            style:
            TextStyle(fontSize: 13, letterSpacing: 2, color: pri)),
        Text('Version 1.0.0',
            style: TextStyle(
                fontSize: 12,
                color:
                dark ? Colors.white38 : Colors.black38)),
        const SizedBox(height: 28),
        _card(
            dark,
            Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sec(tr('📖 About', '📖 بارے میں'), dark),
                  const SizedBox(height: 10),
                  Text(
                      tr(
                          'Chronotrade is a time-based skill exchange platform.\n\n• Teach a skill → Earn credit hours\n• Learn a skill → Spend credit hours\n\nEvery person\'s time is equally valued.',
                          'کرونوٹریڈ ایک وقت پر مبنی مہارت تبادلہ پلیٹ فارم ہے۔\n\n• مہارت سکھائیں → کریڈٹ گھنٹے کمائیں\n• مہارت سیکھیں → کریڈٹ گھنٹے خرچ کریں'),
                      style: TextStyle(
                          fontSize: 14,
                          color: dark
                              ? Colors.white70
                              : Colors.black54,
                          height: 1.6)),
                ])),
        const SizedBox(height: 14),
        _card(
            dark,
            Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sec(
                      tr('👨‍💻 Developed By', '👨‍💻 تیار کردہ'), dark),


                  const SizedBox(height: 12),
                  _dev(
                      'Umar Bisharat',
                      tr('Co-Developer & Backend',
                          'شریک ڈویلپر اور بیک اینڈ'),
                      '👨‍💻',
                      const Color(0xFF00D4FF),
                      dark),
                ])),
        const SizedBox(height: 14),
        _card(
            dark,
            Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sec(tr('✨ Features', '✨ خصوصیات'), dark),
                  const SizedBox(height: 12),
                  ...[
                    ['🔐', tr('Secure Login & Register', 'محفوظ لاگ ان اور رجسٹریشن')],
                    ['💳', tr('Credit Hour System', 'کریڈٹ گھنٹہ نظام')],
                    ['🧠', tr('Skill Marketplace', 'مہارت بازار')],
                    ['🤝', tr('Smart Trade Recording', 'ذہین تجارت ریکارڈنگ')],
                    ['🗑️', tr('Delete Trades', 'تجارت حذف کریں')],
                    ['🏆', tr('Leaderboard', 'لیڈر بورڈ')],
                    ['🌐', tr('Urdu + English', 'اردو + انگریزی')],
                    ['🎨', tr('6 Custom Themes', '6 اپنی مرضی کے تھیم')],
                    ['📷', tr('Avatar Selection', 'اوتار انتخاب')],
                    ['🔔', tr('Notifications', 'اطلاعات')],
                    ['🎁', tr('Bonus Credits on Register', 'رجسٹریشن پر بونس کریڈٹ')],
                    ['💾', tr('Persistent Storage (SQLite)', 'مستقل ذخیرہ (SQLite)')],
                  ].map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Text(f[0],
                          style:
                          const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(f[1],
                              style: TextStyle(
                                  fontSize: 13,
                                  color: dark
                                      ? Colors.white70
                                      : Colors.black54))),
                    ]),
                  )),
                ])),
        const SizedBox(height: 14),
        _card(
            dark,
            Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sec(tr('🛠️ Tech Stack', '🛠️ ٹیکنالوجی'), dark),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _chip2('Flutter', Colors.blue),
                    _chip2('Dart', Colors.indigo),
                    _chip2('SQLite', Colors.green),
                    _chip2('sqflite', Colors.teal),
                    _chip2('Material 3', pri),
                  ]),
                ])),
        const SizedBox(height: 14),
        _card(
            dark,
            Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: pri.withOpacity(.15),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.school_outlined,
                      color: pri, size: 26)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                            tr(
                                'Mehran University of Engineering & Technology',
                                'مہران یونیورسٹی آف انجینئرنگ اینڈ ٹیکنالوجی'),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: dark
                                    ? Colors.white
                                    : Colors.black87)),
                        Text(
                            tr('Jamshoro, Sindh, Pakistan',
                                'جامشورو، سندھ، پاکستان'),
                            style: TextStyle(
                                fontSize: 12,
                                color: dark
                                    ? Colors.white54
                                    : Colors.black45)),
                        Text(tr('Software Engineering', 'سافٹ ویئر انجینئرنگ'),
                            style: TextStyle(
                                fontSize: 12,
                                color: pri,
                                fontWeight: FontWeight.w600)),
                      ])),
            ])),
        const SizedBox(height: 28),
        Text(
            tr('Made with ❤️ in Pakistan',
                'پاکستان میں ❤️ کے ساتھ بنایا گیا'),
            style: TextStyle(
                fontSize: 13,
                color:
                dark ? Colors.white38 : Colors.black38)),
        const SizedBox(height: 4),
        Text('© 2025 Umar Bisharat',
            style: TextStyle(
                fontSize: 12,
                color:
                dark ? Colors.white24 : Colors.black26)),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _card(bool dark, Widget child) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cfg.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 12)
          ]),
      child: child);

  Widget _sec(String t, bool dark) => Text(t,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: dark ? Colors.white : Colors.black87));

  Widget _dev(String name, String role, String emoji, Color c,
      bool dark) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: c.withOpacity(.2),
                borderRadius: BorderRadius.circular(14)),
            child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 24)))),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: dark ? Colors.white : Colors.black87)),
                  Text(role,
                      style: TextStyle(
                          fontSize: 12,
                          color: dark ? Colors.white54 : Colors.black45,
                          height: 1.5)),
                ])),
      ]);

  Widget _chip2(String lbl, Color c) => Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: c.withOpacity(.15),
          borderRadius: BorderRadius.circular(20)),
      child: Text(lbl,
          style: TextStyle(
              color: c,
              fontWeight: FontWeight.w700,
              fontSize: 12)));
}
