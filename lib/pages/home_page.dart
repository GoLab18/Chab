import 'package:flutter/material.dart';

import '../components/custom_app_bar.dart';
import '../components/drawer/custom_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Column()
    );
  }
}