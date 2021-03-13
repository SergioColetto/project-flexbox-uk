import 'package:flutter/material.dart';
import 'package:happy_postcode_flutter/components/app_theme.dart';
import 'package:happy_postcode_flutter/components/centered_message.dart';
import 'package:happy_postcode_flutter/components/navigate_button.dart';
import 'package:happy_postcode_flutter/components/time_line_route_list.dart';
import 'package:happy_postcode_flutter/providers/address_provider.dart';
import 'package:happy_postcode_flutter/search/search_delegate.dart';
import 'package:provider/provider.dart';

import 'mapa_page.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, provider, child) => MaterialApp(
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.buildTheme().appBarTheme.color,
              bottom: TabBar(
                tabs: [
                  Tab(text: "LIST"),
                  Tab(text: "MAP"),
                  Tab(text: "SUMMARY"),
                ],
              ),
              title: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Center(
                      child: Text("Flex Box"),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        showSearch(context: context, delegate: DataSearch());
                      })
                ],
              ),
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      TimeLineRouteList(),
                      MapaPage(),
                      Container(
                        child: CenteredMessage(
                          'Construction',
                          icon: Icons.construction,
                        ),
                      ),
                    ],
                  ),
                ),
                provider.totalInRoute > 0 ? NavigateButton() : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
