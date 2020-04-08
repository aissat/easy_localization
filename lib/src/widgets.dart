import 'package:flutter/material.dart';

class EmptyPreloaderWidget extends StatelessWidget {
  const EmptyPreloaderWidget();
  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}

class FutureErrorWidget extends StatelessWidget {
  final String msg;
  const FutureErrorWidget({this.msg = 'Loading ...'});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 64,
          textDirection: TextDirection.ltr,
        ),
        SizedBox(height: 20),
        Text(
          'Easy Localization:',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: TextStyle(
              fontWeight: FontWeight.w700, color: Colors.red, fontSize: 25.0),
        ),
        SizedBox(height: 10),
        Text(
          '"$msg"',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.red, fontSize: 14.0),
        ),
        SizedBox(height: 30),
        // Center(
        //   child: CircularProgressIndicator()
        // ),
      ]),
    );
  }
}
