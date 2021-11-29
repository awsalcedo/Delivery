import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  final String text;
  NoDataWidget({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 110),
            child: Image.asset('assets/img/no_items.png'),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 70), child: Text(text))
        ],
      ),
    );
  }
}
