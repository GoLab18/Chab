import 'package:chab/pages/chat_rooms_list_page.dart';
import 'package:flutter/material.dart';

import '../blocs/search_bloc/search_bloc.dart';
import '../components/app_bars/search_app_bar.dart';
import '../components/drawer/custom_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SearchAppBar(searchTarget: SearchTarget.chatRooms),
      drawer: CustomDrawer(),
      body: ChatRoomsListPage()
    );
  }
}
