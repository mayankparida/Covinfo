import 'package:covinfo/authentication/presentation/screen/signUp/widget/widget.dart';
import 'package:covinfo/constants.dart';
import 'package:covinfo/home/presentation/screen/allCountry/allCountry_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  static String id = "signUp_screen";

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String email;

  String password;

  final _auth = FirebaseAuth.instance;

  bool loadingSpinner = false;

  var countryData;

  var indiaData;

  getCountryData() async {
    http.Response response = await http.get(
        "https://api.apify.com/v2/key-value-stores/tVaYRsPHLjNdNBu7S/records/LATEST?disableRedirect=true");
    http.Response indiaResponse = await http.get(
        "https://api.apify.com/v2/key-value-stores/toDWvRj1JpTXiM8FF/records/LATEST?disableRedirect=true");
    if (response.statusCode == 200 && indiaResponse.statusCode == 200) {
      String data = response.body;
      String iData = indiaResponse.body;
      countryData = jsonDecode(data);
      indiaData = jsonDecode(iData);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AllCountryScreen(
          countryData: countryData,
          indiaData: indiaData,
        );
      }));
    } else {
      print(response.statusCode);
    }
  }

  storeEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", email);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        new TextEditingController().clear();
      },
      child: ModalProgressHUD(
        inAsyncCall: loadingSpinner,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Logo(),
                  SizedBox(
                    height: 30.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Email",
                      style: TextStyle(color: Colors.grey, fontSize: 15.0),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  EntryField(
                    onChanged: (value) {
                      email = value;
                    },
                    title: "Enter email",
                    colour: Colors.red,
                    obscure: false,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      style: TextStyle(color: Colors.grey, fontSize: 15.0),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  EntryField(
                    onChanged: (value) {
                      password = value;
                    },
                    title: "Enter Password",
                    colour: Colors.red,
                    obscure: true,
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Button(
                    title: "Sign Up",
                    color: Colors.red,
                    onPressed: () async {
                      setState(() {
                        loadingSpinner = true;
                      });
                      try {
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                        if (newUser != null) {
                          storeEmail();
                          getCountryData();
                        }
                        setState(() {
                          loadingSpinner = false;
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
