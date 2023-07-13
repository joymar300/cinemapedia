import 'package:cinemapedia/presentation/views/views.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';
  final int pageindex;
  const HomeScreen({super.key, required this.pageindex});
  final viewRoutes = const <Widget>[
    HomeView(),
    SizedBox(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: pageindex,
        children: viewRoutes,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: pageindex,
      ),
    );
  }
}
