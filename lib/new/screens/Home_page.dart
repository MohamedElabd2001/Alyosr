import 'package:alyosr_online/new/screens/post.dart';
import 'package:alyosr_online/new/screens/News.dart';
import 'package:alyosr_online/new/screens/ta2set.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cars/car_list.dart';

class home_page extends StatefulWidget {
  @override
  _home_pageState createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  late List<Map<String, dynamic>> categories;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    fetchData();
  }

  Future<void> fetchData() async {
    final dio = Dio();

    try {
      final response = await dio
          .get('https://alyosr.online/wp-json/wp/v2/categories?parent=0');

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(response.data);
        setState(() {
          categories = data
              .where((category) => category['slug'] != 'uncategorized')
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const Center(
              child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child:
                      Image(image: AssetImage("assets/images/App Icon.png"))),
            ),
            ListTile(
              leading: const Icon(Icons.webhook),
              title: const Text(
                'website',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {
                _launchwebsite();
              },
            ),
            ListTile(
              leading: const Icon(Icons.facebook),
              title: const Text('Facebook '),
              onTap: () {
                _launchFacebook();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Instagram'),
              onTap: () {
                _launchInstagram();
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy and Policy'),
              onTap: () {
                _launchPrivacy();
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle),
              title: const Text('Terms of Use'),
              onTap: () {
                _launchTerms();
              },
            ),
            Column(
              children: [
                const SizedBox(
                  height: 200,
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset('assets/images/eg_bay.png'),
                ),
                const SizedBox(
                  height: 50,
                ),
                const Text('Copyright ©, 2023 EG Bay')
              ],
            )
            // Add more items as needed
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text('بوابة اليسر للخدمات الحكومية'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFBCCAD0),
              Color(0xFFE3E8EA),
            ],
          ),
        ),
        child:
            Column(
              children: [

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/banner.jpg'),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: isLoading
                      ? Center(
                          child: Container(
                              height: 50,
                              width: 50,
                              child: Lottie.asset('assets/lottie/laww.json')))
                      : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: categories.length + 3, // Increase by 1 for the new card
                    itemBuilder: (context, index) {
                      if (index == categories.length) {
                        // Assuming you want to add it as the first item
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 3,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Ta2setScreen()),
                                );
                              },
                              child: Center(
                                child: Animate(
                                  child: Text(
                                    'قسط معانا',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).animate().fade().scale(),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (index == categories.length + 1) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 3,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => NewsScreen()),
                                );
                              },
                              child: Center(
                                child: Animate(
                                  child: Text(
                                    'أخبار',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).animate().fade().scale(),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (index == categories.length + 2) {
                        // This is the new card
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 3,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CarsListScreen()),
                                );
                              },
                              child: Center(
                                child: Animate(
                                  child: Text(
                                    'قائمة السيارات',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).animate().fade().scale(),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return CategoryTile(category: categories[index]);
                      }
                    },
                  ),
                ),],
            ),

      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final Map<String, dynamic> category;

  CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: () {
            String categoryName = category['name'];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PostScreen(
                        categoryId: category['id'],
                        categoryName: categoryName)));
            // Handle category tap
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Animate(
                child: Text(
                  category['name'],
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ).animate().fade().scale(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final Uri facebookUrl = Uri.parse('https://www.facebook.com/alyosrservices');
final Uri instagramUrl = Uri.parse('https://instagram.com/alyosrservices');
final Uri websiteUrl = Uri.parse('https://www.alyosr.online');
final Uri privacyUrl = Uri.parse('https://alyosr.online/privacy-policy/');
final Uri termsUrl = Uri.parse('https://alyosr.online/privacy-policy/');
final Uri newsUrl = Uri.parse("https://news.alyosr.online/");

Future<void> _launchwebsite() async {
  if (await launchUrl(websiteUrl)) {
    // throw Exception('Could not launch $websiteUrl');
  }
}

Future<void> _newsURL() async {
  if (await launchUrl(newsUrl)) {
    // throw Exception('Could not launch $websiteUrl');
  }
}

Future<void> _launchFacebook() async {
  if (!await launchUrl(facebookUrl)) {
    throw Exception('Could not launch $facebookUrl');
  }
}

Future<void> _launchInstagram() async {
  if (!await launchUrl(instagramUrl)) {
    throw Exception('Could not launch $instagramUrl');
  }
}

Future<void> _launchPrivacy() async {
  if (!await launchUrl(privacyUrl)) {
    throw Exception('Could not launch $privacyUrl');
  }
}

Future<void> _launchTerms() async {
  if (!await launchUrl(termsUrl)) {
    throw Exception('Could not launch $termsUrl');
  }
}
