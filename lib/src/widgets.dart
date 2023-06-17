import 'package:flutter/material.dart';

class FutureErrorWidget extends StatelessWidget {
  final String msg;
  const FutureErrorWidget({Key? key, this.msg = 'Loading ...'})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 64,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 20),
        const Text(
          'Easy Localization:',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: TextStyle(
              fontWeight: FontWeight.w700, color: Colors.red, fontSize: 25.0),
        ),
        const SizedBox(height: 10),
        Text(
          '"$msg"',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.red, fontSize: 14.0),
        ),
        const SizedBox(height: 30),
        // Center(
        //   child: CircularProgressIndicator()
        // ),
      ]),
    );
  }
}
