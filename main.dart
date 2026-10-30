
import 'package:flutter/material.dart';

void main() {
  runApp(const CoffeeShopApp());
}

const coffeeBrown = Color(0xFF6F4E37);
const cream = Color(0xFFFAF5EF);

class CoffeeShopApp extends StatelessWidget {
  const CoffeeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brew Haven Coffee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: coffeeBrown),
        scaffoldBackgroundColor: cream,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class Coffee {
  final String name;
  final String description;
  final double price;
  final String emoji;

  const Coffee(this.name, this.description, this.price, this.emoji);
}

const menu = [
  Coffee('Americano', 'Rich espresso with water', 90, '☕'),
  Coffee('Cappuccino', 'Espresso with creamy milk foam', 120, '🥛'),
  Coffee('Cafe Latte', 'Smooth espresso and steamed milk', 130, '🤎'),
  Coffee('Iced Coffee', 'Chilled coffee, served over ice', 110, '🧋'),
];

class Purchase {
  final String product;
  final double amount;
  final String payment;
  final String date;

  Purchase(this.product, this.amount, this.payment)
      : date = DateTime.now().toString().substring(0, 16);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  String? error;

  void login() {
    if (username.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => error = 'Please enter your username and password.');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ShopPage(customer: username.text.trim()),
      ),
    );
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('☕', style: TextStyle(fontSize: 76)),
                const SizedBox(height: 12),
                const Text(
                  'BREW HAVEN',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: coffeeBrown,
                    letterSpacing: 2,
                  ),
                ),
                const Text('Your daily cup of happiness'),
                const SizedBox(height: 32),
                TextField(
                  controller: username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: password,
                  obscureText: true,
                  onSubmitted: (_) => login(),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: coffeeBrown,
                    ),
                    onPressed: login,
                    child: const Text('LOG IN'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Demo app: enter any username and password.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShopPage extends StatefulWidget {
  final String customer;

  const ShopPage({super.key, required this.customer});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int tab = 0;
  Coffee? selectedCoffee;
  String paymentMethod = 'Cash on Pickup';
  final List<Purchase> history = [];

  void notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void order(Coffee coffee) {
    setState(() {
      selectedCoffee = coffee;
      paymentMethod = 'Cash on Pickup';
      tab = 2;
    });
  }

  void pay() {
    final coffee = selectedCoffee;
    if (coffee == null) return;

    setState(() {
      history.insert(
        0,
        Purchase(coffee.name, coffee.price, paymentMethod),
      );
      selectedCoffee = null;
      tab = 3;
    });

    notify('Payment received! Your order has been recorded.');
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      menuPage(),
      historyPage(),
      checkoutPage(),
      historyPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: coffeeBrown,
        foregroundColor: Colors.white,
        title: const Text('☕ Brew Haven'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: pages[tab],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab == 2 ? 0 : tab == 3 ? 1 : tab,
        onDestinationSelected: (index) {
          setState(() {
            tab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.coffee_outlined),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget menuPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${widget.customer}! 👋',
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text('What would you like to drink today?'),
        const SizedBox(height: 20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 560 ? 2 : 1;

              return GridView.builder(
                itemCount: menu.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: columns == 2 ? 1.45 : 2.0,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final coffee = menu[index];

                  return Card(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(coffee.emoji,
                              style: const TextStyle(fontSize: 42)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coffee.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  coffee.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₱${coffee.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: coffeeBrown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FilledButton.tonal(
                                  onPressed: () => order(coffee),
                                  child: const Text('Order'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget checkoutPage() {
    final coffee = selectedCoffee;

    if (coffee == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 60),
            const Text('No product selected.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() => tab = 0),
              child: const Text('Browse coffee menu'),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        const Text(
          'Checkout',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.white,
          child: ListTile(
            leading: Text(coffee.emoji, style: const TextStyle(fontSize: 35)),
            title: Text(coffee.name),
            subtitle: Text(coffee.description),
            trailing: Text('₱${coffee.price.toStringAsFixed(2)}'),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Choose payment method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        RadioGroup<String>(
          groupValue: paymentMethod,
          onChanged: (value) {
            if (value != null) {
              setState(() => paymentMethod = value);
            }
          },
          child: const Column(
            children: [
              RadioListTile<String>(
                value: 'Cash on Pickup',
                title: Text('Cash on Pickup'),
                secondary: Icon(Icons.payments_outlined),
              ),
              RadioListTile<String>(
                value: 'GCash (Demo)',
                title: Text('GCash (Demo)'),
                subtitle: Text('Simulated payment only'),
                secondary: Icon(Icons.phone_android),
              ),
              RadioListTile<String>(
                value: 'Card (Demo)',
                title: Text('Credit / Debit Card (Demo)'),
                subtitle: Text('Simulated payment only'),
                secondary: Icon(Icons.credit_card),
              ),
            ],
          ),
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontSize: 20)),
            Text(
              '₱${coffee.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: coffeeBrown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: coffeeBrown,
            padding: const EdgeInsets.all(16),
          ),
          onPressed: pay,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Confirm order and payment'),
        ),
        TextButton(
          onPressed: () => setState(() => tab = 0),
          child: const Text('Back to menu'),
        ),
      ],
    );
  }

  Widget historyPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Purchase History',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Your previous orders and payment details.'),
        const SizedBox(height: 20),
        Expanded(
          child: history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long, size: 60),
                      SizedBox(height: 12),
                      Text('No purchases yet.'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final purchase = history[index];

                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.coffee),
                        ),
                        title: Text(purchase.product),
                        subtitle: Text(
                          '${purchase.date}\n${purchase.payment} • Payment received',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          '₱${purchase.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: coffeeBrown,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
