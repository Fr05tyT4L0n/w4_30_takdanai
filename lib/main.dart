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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Home Page'),
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

    // Check if data is empty
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
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Name"),
              controller: _snackNameCtrl,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Category"),
              controller: _snackCategoryCtrl,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Price"),
              controller: _snackPriceCtrl,
            ),

            ElevatedButton(onPressed: () => addSnack(), child: Text("Save")),

            // ขยายให้เต็มหน้าจอ
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("snacks")
                    .snapshots(),
                builder: (context, snapshot) {
                  // สถานะรอข้อมูลเป็นยังไง
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final docs = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final snacks = docs[index];
                      final s = snacks.data();

                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SnackDetailPage(snack: s),
                            ),
                          );
                        },
                        child: Card(child: Text(s["name"])),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
        body: Column(
            children: [
              Text(snack["name"]),
              Text(snack["category"]),
              Text(snack["price"]),
            ]
        )
    );
  }
}
