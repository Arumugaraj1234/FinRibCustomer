import 'package:finandrib/screens/splash_screen.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataServices>(
      create: (_) {
        return DataServices();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fin & Rib',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(brightness: Brightness.light),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
