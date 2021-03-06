import 'package:covinfo/authentication/presentation/screen/splash/splash_screen.dart';
import 'package:covinfo/constants.dart';
import 'package:covinfo/home/presentation/screen/allCountry/allCountry_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  static String id = "loading_screen";
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  var countryData;

  var indiaData;

  var newsData;

  getCountryData() async {
    http.Response response = await http.get(
        "https://api.apify.com/v2/key-value-stores/tVaYRsPHLjNdNBu7S/records/LATEST?disableRedirect=true");
    http.Response indiaResponse = await http.get(
        "https://api.apify.com/v2/key-value-stores/toDWvRj1JpTXiM8FF/records/LATEST?disableRedirect=true");
    http.Response newsResponse = await http.get(
        "https://newsapi.org/v2/everything?q=COVID&from=2021-05-26&sortBy=popularity&apiKey=bfc200c649eb4d9e9c1c2a5b71675d92&pageSize=40&page=2");
    if (response.statusCode == 200 &&
        indiaResponse.statusCode == 200 &&
        newsResponse.statusCode == 200) {
      String data = response.body;
      String iData = indiaResponse.body;
      String nData = newsResponse.body;
      countryData = jsonDecode(data);
      indiaData = jsonDecode(iData);
      newsData = jsonDecode(nData);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return AllCountryScreen(
          countryData: countryData,
          indiaData: indiaData,
          newsData: newsData,
        );
      }));
    } else {
      print(response.statusCode);
    }
  }

  getMail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email');
    if (email != null) {
      getCountryData();
    } else {
      Navigator.pushNamed(context, SplashScreen.id);
    }
  }

  @override
  void initState() {
    super.initState();
    getMail();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SpinKitDualRing(
            color: Colors.red,
            size: 100.0,
          ),
        ),
      ),
    );
  }
}
