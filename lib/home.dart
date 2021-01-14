import 'package:flutter/material.dart';
import './search.dart';
import './records/records.dart';

class _TabItem {
  String name;
  String route;
  ScreenArguments args;
  _TabItem(this.name, this.route);
}

var tabs = [
  _TabItem("搜索", "/home"),
  _TabItem("历史记录", "/home"),
];

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class ScreenArguments {
  String tab;
  ScreenArguments({this.tab});
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  int lastIndex;
  int nowIndex;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: tabs.length, vsync: this);
    _controller.addListener(() => _onTabChange());
  }

  _onTabChange() {
    setState(() {
      nowIndex = _controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings?.arguments;
    var index = int.tryParse(args?.tab ?? "0") ?? 0;
    if (lastIndex != index) {
      nowIndex = index;
      _controller.animateTo(nowIndex);
      setState(() {
        lastIndex = index;
        nowIndex = index;
      });
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tabs[nowIndex].name),
          bottom: TabBar(
            controller: _controller,
            tabs: tabs.map((e) => Tab(text: e.name)).toList(),
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: [
            SearchForm(),
            RecordsRender(),
          ],
        ),
      ),
    );
  }
}

class HomePageWrapper extends StatelessWidget {
  final Widget body;
  final Widget title;
  final int index;
  HomePageWrapper({
    this.body,
    this.title,
    this.index,
  });
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: index,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tabs[index].name),
          bottom: TabBar(
            onTap: (index) {
              if (this.index == index) {
                return;
              }
              Navigator.pushReplacementNamed(
                context,
                tabs[index].route,
                arguments: ScreenArguments(tab: index.toString()),
              );
            },
            tabs: tabs.map((e) => Tab(text: e.name)).toList(),
          ),
        ),
        body: body,
      ),
    );
  }
}
