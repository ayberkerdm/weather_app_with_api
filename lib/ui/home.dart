// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:weather_app/models/city.dart';
// import 'package:weather_app/models/constants.dart';
// import 'package:http/http.dart' as http;

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   Constants myConstants = Constants();

//   // Seçilen şehirlerin listesi
//   List<City> selectedCities = City.getSelectedCities();

//   // Hava durumu bilgilerini tutmak için liste
//   List<Map<String, dynamic>> weatherDataList = [];

//   @override
//   void initState() {
//     super.initState();

//     // Seçilen her şehir için hava durumu bilgisini çek
//     for (var city in selectedCities) {
//       fetchWeatherData(city.city);
//     }
//   }

//   Future<void> fetchWeatherData(String city) async {
//     final apiKey = '6aba9033981bece8134088decc8ef79f';
//     final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         setState(() {
//           // Her şehrin hava durumu bilgilerini listeye ekle
//           weatherDataList.add({
//             'city': city,
//             'temperature': data['main']['temp'].toInt(),
//             'description': data['weather'][0]['description'],
//             'icon': data['weather'][0]['icon'],
//           });
//         });
//       } else {
//         print('Hata: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('API isteği sırasında hata oluştu: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Weather Information'),
//       ),
//       body: weatherDataList.isEmpty
//           ? const Center(child: CircularProgressIndicator()) // Eğer veri yüklenmediyse
//           : ListView.builder(
//               itemCount: weatherDataList.length,
//               itemBuilder: (context, index) {
//                 var weather = weatherDataList[index];
//                 return Card(
//                   child: ListTile(
//                     leading: Image.network(
//                       'http://openweathermap.org/img/wn/${weather['icon']}@2x.png',
//                       width: 50,
//                     ),
//                     title: Text(weather['city']),
//                     subtitle: Text(
//                       '${weather['temperature']}°C - ${weather['description']}',
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app2/models/city.dart';
import 'package:weather_app2/models/constants.dart';
import 'package:weather_app2/ui/welcome.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Constants myConstants = Constants();
  // Varsayılan seçili şehir
  List<City> selectedCities = City.getSelectedCities();
  String location = City.getSelectedCities().isNotEmpty
      ? City.getSelectedCities().first.city
      : '';
  List<Map<String, dynamic>> weatherDataList = [];
  String currentDate = DateTime.now().toString().substring(0, 10);

  @override
  void initState() {
    super.initState();
    // Başlangıçta seçili olan şehir için hava durumu bilgilerini çek
    fetchWeatherData(location);
  }

  Future<void> fetchWeatherData(String city) async {
    final apiKey = '6aba9033981bece8134088decc8ef79f';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          // Seçilen şehir için hava durumu bilgisini listeye ekle
          weatherDataList = [
            {
              'city': city,
              'temperature': data['main']['temp'].toInt(),
              'weatherStateName': data['weather'][0]['description'],
              'icon': data['weather'][0]['icon'],
              'humidity': data['main']['humidity'],
              'windSpeed': data['wind']['speed'].toInt(),
              'maxTemp': data['main']['temp_max'].toInt(),
            }
          ];
        });
      } else {
        print('Hata: ${response.statusCode}');
      }
    } catch (e) {
      print('API isteği sırasında hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (context) => const Welcome()));
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Weather',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/pin.png',
                width: 20,
              ),
              const SizedBox(
                width: 4,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: selectedCities.isNotEmpty &&
                          selectedCities.any((city) => city.city == location)
                      ? location
                      : null, // Eğer location listedeki şehirlerden biri değilse null yap
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: selectedCities.map((city) {
                    return DropdownMenuItem(
                      value: city.city,
                      child: Text(city.city),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      location = newValue!;
                      // Seçilen şehir için hava durumu bilgilerini çek
                      fetchWeatherData(location);
                    });
                  },
                ),
              ),
            ],
          )
        ],
      ),
      body: weatherDataList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                      ),
                    ),
                    Text(
                      currentDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 50),
                    weatherDataList.isEmpty
                        ? const SizedBox.shrink()
                        : Container(
                            width: size.width,
                            height: 200,
                            decoration: BoxDecoration(
                              color: myConstants.primaryColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      myConstants.primaryColor.withOpacity(.5),
                                  offset: const Offset(0, 25),
                                  blurRadius: 10,
                                  spreadRadius: -12,
                                )
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: -40,
                                  left: 10,
                                  child: Image.network(
                                    'http://openweathermap.org/img/wn/${weatherDataList[0]['icon']}@4x.png',
                                    width: 200,
                                    height: 200,
                                  ),
                                ),
                                Positioned(
                                  bottom: 30,
                                  left: 20,
                                  child: Text(
                                    weatherDataList[0]['weatherStateName'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  right: 20,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          weatherDataList[0]['temperature']
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 80,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        '°C',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          weatherItem(
                            text: 'Wind Speed',
                            value: weatherDataList[0]['windSpeed'],
                            unit: 'km/h',
                            imageUrl: 'assets/windspeed.png',
                          ),
                          weatherItem(
                            text: 'Humidity',
                            value: weatherDataList[0]['humidity'],
                            unit: '%',
                            imageUrl: 'assets/humidity.png',
                          ),
                          weatherItem(
                            text: 'Max Temp',
                            value: weatherDataList[0]['maxTemp'],
                            unit: '°C',
                            imageUrl: 'assets/max-temp.png',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget weatherItem(
      {required String text,
      required int value,
      required String unit,
      required String imageUrl}) {
    return Column(
      children: [
        Image.asset(imageUrl, width: 50),
        const SizedBox(height: 10),
        Text(
          '$value $unit',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
