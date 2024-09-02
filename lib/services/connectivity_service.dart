import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Checks if there is an active internet connection.
/// Returns true if connected to the internet, false otherwise.
Future<bool> hasInternetConnection() async {
  // Check the current connectivity status
  var connectivityResult = await Connectivity().checkConnectivity();

  // If the device is connected to a network (WiFi, mobile, or Ethernet)
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi ||
      connectivityResult == ConnectivityResult.ethernet) {
    try {
      // Attempt to lookup a well-known domain to verify internet access
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('Internet is available.');
        return true; // Internet access confirmed
      }
    } on SocketException catch (_) {
      print('No internet connection.');
    }
  } else {
    print('No network connection.');
  }

  return false;
}
