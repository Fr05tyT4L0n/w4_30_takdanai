import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// Import Firebase Packages
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Firebase Stuff
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.white54),
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          // backgroundColor: Colors.black,
          foregroundColor: Colors.black,
          centerTitle: true,
        ),
      ),
      home: const MyHomePage(title: 'Products Management'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _snackNameCtrl = TextEditingController();
  final _snackCategoryCtrl = TextEditingController();
  final _snackPriceCtrl = TextEditingController();

  void addSnack() async {
    String _name = _snackNameCtrl.text;
    String _category = _snackCategoryCtrl.text;
    String _price = _snackPriceCtrl.text;

    // เช็กข้อมูลไม่ครบ
    if (_name.isEmpty || _category.isEmpty || _price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("กรุณากรอกข้อมูลให้ครบถ้วน."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("Debugging : $_name, $_category, $_price");

    try {
      await FirebaseFirestore.instance.collection("snacks").add({
        'name': _name,
        'category': _category,
        'price': _price,
      });

      _snackNameCtrl.clear();
      _snackCategoryCtrl.clear();
      _snackPriceCtrl.clear();
    } catch (e) {
      print("Bug Detected : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.new_label),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: _snackNameCtrl,
              ),

              SizedBox(height: 8),

              TextField(
                decoration: InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: _snackCategoryCtrl,
              ),

              SizedBox(height: 8),

              TextField(
                decoration: InputDecoration(
                  labelText: "Price",
                  prefixIcon: Icon(Icons.price_change),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: _snackPriceCtrl,
              ),

              SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () => addSnack(),
                  child: Text("Save", style: TextStyle(fontSize: 20)),
                ),
              ),

              SizedBox(height: 15),

              // ขยายให้เต็มหน้าจอ
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("snacks")
                      .snapshots(),
                  builder: (context, snapshot) {
                    // สถานะรอข้อมูล
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    // เช็ค error
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }

                    final docs = snapshot.data!.docs;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),

                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final snacks = docs[index];
                        // ข้อมูล
                        final s = snacks.data();

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SnackDetailPage(snack: s),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s["name"],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 6),

                                Text(
                                  "Category : ${s["category"]}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                SizedBox(height: 6),

                                Text(
                                  "Price : ${s["price"]} ฿",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
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
          ),
        ),
      ),
    );
  }
}

class SnackDetailPage extends StatelessWidget {
  final snack;

  const SnackDetailPage({super.key, required this.snack});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(snack["name"], style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Product", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox.expand(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    snack["name"],
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text("Category", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 5),
                  Text(
                    snack["category"],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(height: 15),

                  Text("Price", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 5),
                  Text(
                    "${snack["price"]} ฿",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
