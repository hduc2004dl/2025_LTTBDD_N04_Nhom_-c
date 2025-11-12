import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'login.dart';

// ==================== CART & LANGUAGE PROVIDER ====================
class CartItem {
  final String name, img, desc;
  final int price;
  int quantity;
  CartItem({required this.name, required this.img, required this.desc, required this.price, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;
  int get total => _items.fold(0, (sum, i) => sum + i.price * i.quantity);

  void add(CartItem item) {
    final existing = _items.where((i) => i.name == item.name).firstOrNull;
    if (existing != null) existing.quantity++; else _items.add(item);
    notifyListeners();
  }
  void increase(CartItem item) { item.quantity++; notifyListeners(); }
  void decrease(CartItem item) { if (item.quantity > 1) item.quantity--; else _items.remove(item); notifyListeners(); }
  void remove(CartItem item) { _items.remove(item); notifyListeners(); }
}

class LanguageProvider extends ChangeNotifier {
  String _lang = 'Tiếng Việt';
  String get lang => _lang;
  void setLang(String l) { _lang = l; notifyListeners(); }

  String t(String vi, String en, String ja) {
    switch (_lang) {
      case 'English': return en;
      case 'Japanese': return ja;
      default: return vi;
    }
  }
}

// ==================== MAIN APP ====================
void main() => runApp(MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => LanguageProvider()),
    ChangeNotifierProvider(create: (_) => CartProvider()),
  ],
  child: const MyApp(),
));

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  int _index = 2;
  bool _loggedIn = false;
  final _navKey = GlobalKey<NavigatorState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  void _login() => setState(() => _loggedIn = true);
  void _logout() => setState(() { _loggedIn = false; _index = 2; });

  void _onTabTapped(int i) {
    if (i == 1 && !_loggedIn) {
      _navKey.currentState!.push(MaterialPageRoute(builder: (_) => AuthScreen(onLogin: _login)));
    } else {
      setState(() => _index = i);
      _animationController.forward().then((_) => _animationController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<LanguageProvider>(context).t;

    return MaterialApp(
      navigatorKey: _navKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: IndexedStack(
          index: _index,
          children: [
            CartPage(onLogout: _logout),
            _loggedIn ? ProfilePage(onLogout: _logout) : LoginRedirectPage(onLoginPressed: () => _navKey.currentState!.push(MaterialPageRoute(builder: (_) => AuthScreen(onLogin: _login)))),
            const HomePage(),
            SettingsPage(),
            ProductListPage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -2))],
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SalomonBottomBar(
              currentIndex: _index,
              onTap: _onTabTapped,
              backgroundColor: Colors.white,
              items: [
                SalomonBottomBarItem(icon: const Icon(Icons.shopping_bag_outlined), title: Text(t("Giỏ", "Cart", "カート")), selectedColor: Colors.orange),
                SalomonBottomBarItem(icon: const Icon(Icons.person_outline), title: Text(t("Hồ sơ", "Profile", "プロフィール")), selectedColor: Colors.orange),
                SalomonBottomBarItem(icon: const Icon(Icons.home_outlined), title: Text(t("Home", "Home", "ホーム")), selectedColor: Colors.orange),
                SalomonBottomBarItem(icon: const Icon(Icons.settings_outlined), title: Text(t("Cài đặt", "Settings", "設定")), selectedColor: Colors.orange),
                SalomonBottomBarItem(icon: const Icon(Icons.phone_iphone), title: Text(t("Sản phẩm", "Products", "商品")), selectedColor: Colors.orange),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== HOME PAGE - SIÊU ĐẸP VỚI SEARCH + BANNER ====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<LanguageProvider>(context).t;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.orange, title: Text(t("iPhone Store", "iPhone Store", "iPhoneストア")), elevation: 0),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange,
            child: TextField(
              decoration: InputDecoration(
                hintText: t("Tìm kiếm sản phẩm...", "Search products...", "商品を検索..."),
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            height: 180,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: const DecorationImage(image: AssetImage('assets/imgs/banner.jpg'), fit: BoxFit.cover)),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Colors.black54, Colors.transparent])),
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(t("iPhone 17 Pro Max\nĐặt trước ngay!", "iPhone 17 Pro Max\nPre-order now!", "iPhone 17 Pro Max\n予約受付中！"),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text(t("Sản phẩm nổi bật", "Featured", "おすすめ商品"), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              children: [
                _productCard("iPhone 17 Pro Max", "45.990.000đ", "nav_iphone_17_ffxyyejezqm_large_2x.png"),
                _productCard("iPhone 17 Pro", "34.990.000đ", "nav_iphone_17pro_d60uog2c064i_large_2x.png"),
                _productCard("iPhone Air", "22.990.000đ", "nav_iphone_air_bbjj6j2c39efm_large_2x.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(String name, String price, String img) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.asset('assets/imgs/$img', height: 100, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(price, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ==================== PRODUCT LIST PAGE ====================
class ProductListPage extends StatelessWidget {
  ProductListPage({super.key});
  final List<Map<String, dynamic>> products = const [
    {"name": "iPhone 17 Pro Max", "price": 45990000, "img": "nav_iphone_17_ffxyyejezqm_large_2x.png", "desc": "Chip A19 Pro • 48MP Fusion"},
    {"name": "iPhone 17 Pro", "price": 34990000, "img": "nav_iphone_17pro_d60uog2c064i_large_2x.png", "desc": "Camera 48MP • Dynamic Island"},
    {"name": "iPhone Air", "price": 22990000, "img": "nav_iphone_air_bbjj6j2c39efm_large_2x.png", "desc": "USB-C • 48MP Main"},
  ];

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<LanguageProvider>(context).t;
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(t("Sản phẩm", "Products", "商品")), backgroundColor: Colors.orange),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (ctx, i) {
          final p = products[i];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Image.asset('assets/imgs/${p['img']}', width: 70, height: 70, fit: BoxFit.cover),
              title: Text(p['name']),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['desc']),
                Text("${p['price']}đ", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ]),
              trailing: ElevatedButton(
                onPressed: () {
                  cart.add(CartItem(name: p['name'], price: p['price'], img: p['img'], desc: p['desc']));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("Đã thêm ${p['name']}!", "Added ${p['name']}!","${p['name']}をカートに追加しました！"))));
                },
                child: Text(t("Thêm", "Add", "追加")),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== CART PAGE ====================
class CartPage extends StatelessWidget {
  final VoidCallback? onLogout;
  const CartPage({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<LanguageProvider>(context).t;
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) => Scaffold(
        appBar: AppBar(title: Text(t("Giỏ hàng", "Cart", "カート")), backgroundColor: Colors.orange),
        body: cart.items.isEmpty
            ? Center(child: Text(t("Giỏ hàng trống", "Cart is empty", "カートは空です")))
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (ctx, i) {
                  final item = cart.items[i];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: Image.asset('assets/imgs/${item.img}', width: 60, fit: BoxFit.cover),
                      title: Text(item.name),
                      subtitle: Text("${item.price}đ x ${item.quantity}"),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(onPressed: () => cart.decrease(item), icon: const Icon(Icons.remove_circle_outline)),
                        Text("${item.quantity}"),
                        IconButton(onPressed: () => cart.increase(item), icon: const Icon(Icons.add_circle_outline)),
                        IconButton(onPressed: () => cart.remove(item), icon: const Icon(Icons.delete, color: Colors.red)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.orange,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(t("Tổng tiền", "Total", "合計"), style: const TextStyle(fontSize: 20, color: Colors.white)),
                Text("${cart.total}đ", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PROFILE, LOGIN REDIRECT, SETTINGS ====================
class ProfilePage extends StatelessWidget {
  final VoidCallback? onLogout;
  const ProfilePage({super.key, this.onLogout});
  @override Widget build(BuildContext context) {
    final t = Provider.of<LanguageProvider>(context).t;
    return Scaffold(appBar: AppBar(title: Text(t("Hồ sơ", "Profile", "プロフィール")), backgroundColor: Colors.orange),
        body: Center(child: ElevatedButton(onPressed: onLogout, child: Text(t("Đăng xuất", "Logout", "ログアウト")))));
  }
}

class LoginRedirectPage extends StatelessWidget {
  final VoidCallback onLoginPressed;
  const LoginRedirectPage({super.key, required this.onLoginPressed});
  @override Widget build(BuildContext context) {
    final t = Provider.of<LanguageProvider>(context).t;
    return Scaffold(body: Center(child: ElevatedButton(onPressed: onLoginPressed, child: Text(t("Đi đến Đăng nhập", "Go to Login", "ログイン画面へ")))));
  }
}

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final List<String> languages = ['Tiếng Việt', 'English', 'Japanese'];

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<LanguageProvider>(context).t;
    final langProv = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(t("Cài đặt", "Settings", "設定")), backgroundColor: Colors.orange),
      body: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(16), child: Text("Ngôn ngữ / Language / 言語", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ...languages.map((lang) => RadioListTile<String>(
            title: Text(lang == 'Japanese' ? '日本語' : lang),
            value: lang,
            groupValue: langProv.lang,
            onChanged: (val) {
              langProv.setLang(val!);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("Đổi ngôn ngữ thành $lang", "Language changed to $lang", "$lang に変更しました"))));
            },
          )),
        ],
      ),
    );
  }

}
