import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../email_sender.dart';

class CarsListScreen extends StatefulWidget {
  @override
  _CarsListScreenState createState() => _CarsListScreenState();
}

class _CarsListScreenState extends State<CarsListScreen> {
  final String apiUrl = 'https://alyosr.online/car/wp-json/wp/v2/pixad-autos';
  final String mediaUrl = 'https://alyosr.online/car/wp-json/wp/v2/media';

  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsIm5hbWUiOiJhaG1lZEtoYWxpbCIsImlhdCI6MTcxMTM5ODE2MiwiZXhwIjoxODY5MDc4MTYyfQ.xDP-WuECpF-0jy5cCax8JNBaNvS2gYeT_-vrVO7nP9M';

  List<Car> cars = [];

  Future<void> fetchCars() async {
    final response = await Dio().get(
      apiUrl,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = response.data;
      setState(() {
        cars = responseData.map((data) => Car.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load cars');
    }
  }

  Future<void>? _fetchCarsFuture;

  @override
  void initState() {
    super.initState();
    _fetchCarsFuture = fetchCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('قائمة السيارات'),
      ),
      body: FutureBuilder<void>(
        future: _fetchCarsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailsScreen(
                          car: cars[index],
                          token: token,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String?>(
                          future: fetchCarImage(cars[index].id, token),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError ||
                                snapshot.data == null) {
                              return Text('Error: Image not found');
                            } else {
                              return Image.network(snapshot.data!);
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            cars[index].title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<String?> fetchCarImage(int carId, String token) async {
    try {
      final String mediaUrl =
          'https://alyosr.online/car/wp-json/wp/v2/media?parent=$carId';
      final response = await Dio().get(
        mediaUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        if (responseData.isNotEmpty) {
          return responseData.first['source_url'];
        }
      }
    } catch (e) {
      print('Error fetching car image: $e');
    }
    return null;
  }
}

class Car {
  final int id;
  final String title;
  final String description;

  Car({required this.id, required this.title, required this.description});

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      title: json['title']['rendered'] ?? '',
      description: json['content']['rendered'] ?? '', // Fetching description
    );
  }
}

class CarDetailsScreen extends StatefulWidget {
  final Car car;
  final String token;

  const CarDetailsScreen({Key? key, required this.car, required this.token})
      : super(key: key);

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  late Future<Map<String, dynamic>> _carDetailsFuture;
  Future<String?>? _carImageFuture;

  @override
  void initState() {
    super.initState();
    _carDetailsFuture = fetchCarDetails();
    _carImageFuture = fetchCarImage(widget.car.id, widget.token);
  }

  Future<Map<String, dynamic>> fetchCarDetails() async {
    final String apiUrl =
        'https://alyosr.online/car/wp-json/wp/v2/pixad-autos/${widget.car.id}';
    try {
      final response = await Dio().get(
        apiUrl,
        options: Options(
          headers: {'Authorization': 'Bearer ${widget.token}'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load car details');
      }
    } catch (e) {
      print('Error fetching car details: $e');
      throw Exception('Failed to load car details');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل السيارة'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.car.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
              ),
              FutureBuilder<String?>(
                future: fetchCarImage(widget.car.id, widget.token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return Text('No Image');
                  } else {
                    return Image.network(snapshot.data!);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _stripHtmlTags(widget.car.description),
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>>(
                future: _carDetailsFuture,
                builder: (context, snapshot) {
                  String getCarDetailsAsString(
                      Map<String, dynamic> carDetails) {
                    List<String> detailsList = [
                      if (carDetails['_auto_make'] != null &&
                          carDetails['_auto_make'].isNotEmpty)
                        'Make: ${carDetails['_auto_make']}',
                      if (carDetails['_auto_version'] != null &&
                          carDetails['_auto_version'].isNotEmpty)
                        'Version: ${carDetails['_auto_version']}',
                      if (carDetails['_auto_year'] != null &&
                          carDetails['_auto_year'].isNotEmpty)
                        'Year: ${carDetails['_auto_year']}',
                      if (carDetails['_auto_transmission'] != null &&
                          carDetails['_auto_transmission'].isNotEmpty)
                        'Transmission: ${carDetails['_auto_transmission']}',
                      if (carDetails['_auto_doors'] != null &&
                          carDetails['_auto_doors'].isNotEmpty)
                        'Doors: ${carDetails['_auto_doors']}',
                      if (carDetails['_auto_fuel'] != null &&
                          carDetails['_auto_fuel'].isNotEmpty)
                        'Fuel: ${carDetails['_auto_fuel']}',
                      if (carDetails['_auto_condition'] != null &&
                          carDetails['_auto_condition'].isNotEmpty)
                        'Condition: ${carDetails['_auto_condition']}',
                      if (carDetails['_auto_purpose'] != null &&
                          carDetails['_auto_purpose'].isNotEmpty)
                        'Purpose: ${carDetails['_auto_purpose']}',
                      if (carDetails['_auto_drive'] != null &&
                          carDetails['_auto_drive'].isNotEmpty)
                        'Drive: ${carDetails['_auto_drive']}',
                      if (carDetails['_auto_color'] != null &&
                          carDetails['_auto_color'].isNotEmpty)
                        'Color: ${carDetails['_auto_color']}',
                      if (carDetails['_auto_color_int'] != null &&
                          carDetails['_auto_color_int'].isNotEmpty)
                        'Interior Color: ${carDetails['_auto_color_int']}',
                      // Continue with other details...
                      if (carDetails['_auto_stock_status'] != null &&
                          carDetails['_auto_stock_status'].isNotEmpty)
                        'Stock Status: ${carDetails['_auto_stock_status']}',
                      if (carDetails['_auto_warranty'] != null &&
                          carDetails['_auto_warranty'].isNotEmpty)
                        'Warranty: ${carDetails['_auto_warranty']}',
                      if (carDetails['_auto_mileage'] != null &&
                          carDetails['_auto_mileage'].isNotEmpty)
                        'Mileage: ${carDetails['_auto_mileage']}',
                      if (carDetails['_auto_vin'] != null &&
                          carDetails['_auto_vin'].isNotEmpty)
                        'VIN: ${carDetails['_auto_vin']}',
                      if (carDetails['_auto_engine'] != null &&
                          carDetails['_auto_engine'].isNotEmpty)
                        'Engine: ${carDetails['_auto_engine']}',
                      if (carDetails['_auto_horsepower'] != null &&
                          carDetails['_auto_horsepower'].isNotEmpty)
                        'Horsepower: ${carDetails['_auto_horsepower']}',
                      if (carDetails['_auto_seats'] != null &&
                          carDetails['_auto_seats'].isNotEmpty)
                        'Seats: ${carDetails['_auto_seats']}',
                    ];

                    return detailsList.join('\n');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final carDetails = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetail('Make', carDetails['_auto_make']),
                        _buildDetail('Version', carDetails['_auto_version']),
                        _buildDetail('Year', carDetails['_auto_year']),
                        _buildDetail(
                            'Transmission', carDetails['_auto_transmission']),
                        _buildDetail('Doors', carDetails['_auto_doors']),
                        _buildDetail('Fuel', carDetails['_auto_fuel']),
                        _buildDetail(
                            'Condition', carDetails['_auto_condition']),
                        _buildDetail('Purpose', carDetails['_auto_purpose']),
                        _buildDetail('Drive', carDetails['_auto_drive']),
                        _buildDetail('Color', carDetails['_auto_color']),
                        _buildDetail(
                            'Interior Color', carDetails['_auto_color_int']),
                        //_buildDetail('Price', carDetails['_auto_price']),
                        //_buildDetail(
                        //'Sale Price', carDetails['_auto_sale_price']),
                        _buildDetail(
                            'Stock Status', carDetails['_auto_stock_status']),
                        //_buildDetail(
                        //'Price Type', carDetails['_auto_price_type']),
                        _buildDetail('Warranty', carDetails['_auto_warranty']),
                        _buildDetail('Mileage', carDetails['_auto_mileage']),
                        _buildDetail('VIN', carDetails['_auto_vin']),
                        _buildDetail('Engine', carDetails['_auto_engine']),
                        _buildDetail(
                            'Horsepower', carDetails['_auto_horsepower']),
                        _buildDetail('Seats', carDetails['_auto_seats']),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              final DateTimeRange? dateRange =
                                  await showDateRangePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(
                                    2100), // Adjust last date as needed
                              );

                              if (dateRange != null) {
                                String formattedPickupDate = dateRange.start
                                    .toString(); // Format date as needed
                                String formattedDropOffDate = dateRange.end
                                    .toString(); // Format date as needed

                                // Example of sending dates to EmailSender
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EmailSender(
                                      serviceName: widget.car.title,
                                      carDetails:
                                          getCarDetailsAsString(carDetails),
                                      pickupDate: formattedPickupDate,
                                      dropOffDate: formattedDropOffDate,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text("احجز عربيتك"),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String? value) {
    if (value != null && value.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  String _stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  Future<String?> fetchCarImage(int carId, String token) async {
    try {
      final String mediaUrl =
          'https://alyosr.online/car/wp-json/wp/v2/media?parent=$carId';
      final response = await Dio().get(
        mediaUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        if (responseData.isNotEmpty) {
          return responseData.first['source_url'];
        }
      }
    } catch (e) {
      print('Error fetching car image: $e');
    }
    return null;
  }
}
