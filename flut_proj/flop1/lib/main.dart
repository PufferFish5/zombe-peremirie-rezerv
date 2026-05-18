import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}


class TravelDeal {
  final String title;
  final String price;
  final Color color;
  TravelDeal({required this.title, required this.price, required this.color});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});
  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<TravelDeal> deals = [
    TravelDeal(title: 'Mountains', price: '\$200', color: Colors.orangeAccent),
    TravelDeal(title: 'Sea Side', price: '\$500', color: Colors.blueAccent),
    TravelDeal(title: 'Forest', price: '\$150', color: Colors.greenAccent),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          //top menu
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF1A3981),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Where do you want to travel?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    //kvadratik
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.grid_view_rounded, color: Color(0xFF1A3981)),
                    ),
                    const SizedBox(width: 15),
                    //destination
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A80F5),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Select Destination', style: TextStyle(color: Colors.white)),
                            Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          ],
                        ),
                      ),
                    ),

                    //lupa
                    const SizedBox(width: 15),
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.search, color: Color(0xFF1A3981)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          //kartochki
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Best Deals",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: deals.length,
                        itemBuilder: (context, index) => _buildDealCard(deals[index]),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Popular Destinations",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    _buildPopularGrid(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

// Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
//       decoration: const BoxDecoration(
//         color: Color(0xFF1A3981),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: const Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Where do you want to travel?', 
//             style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
//           SizedBox(height: 25),
//         ],
//       ),
//     );
//   }

Widget _buildDealCard(TravelDeal deal) {
  return Container(
    width: 150,
    margin: const EdgeInsets.only(right: 15),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withAlpha(25),
          blurRadius: 10,
          spreadRadius: 5,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            //color: deal.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(Icons.terrain, color: deal.color, size: 40),
        ),
        Text(
          deal.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("More", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3981),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                deal.price,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildPopularGrid() {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 0.8,
    ),
    itemCount: 4,
    itemBuilder: (context, index) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  //color: Colors.blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.image, color: Colors.blue),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Destination Name", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4A80F5),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 2) {
          //eto counter
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage()));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
      ],
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
          _counter--;
      }
    });
  }
  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('4. Головні зміни, які потрібно зробити: a. Змінити текст у AppBar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Привіт, текст! Я вже вмію змінювати Миколаїв!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              'Ти натиснув кнопку стільки разів:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: '+',
                  backgroundColor: Colors.green[700],
                  child: const Icon(Icons.add),
                ),
                FloatingActionButton(
                  onPressed: _resetCounter,
                  tooltip: 'reset',
                  backgroundColor: Colors.yellow[700],
                  child: const Icon(Icons.restart_alt),
                ),
                FloatingActionButton(
                  onPressed: _decrementCounter,
                  tooltip: '-',
                  backgroundColor: Colors.red[700],
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}