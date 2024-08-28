import 'package:flutter/material.dart';

import '../components/search_app_bar.dart';
import '../components/drawer/custom_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SearchAppBar(),
      drawer: CustomDrawer(),
      body: Column()
    );
  }
}