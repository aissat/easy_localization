import 'package:flutter/material.dart';

class EmptyPreloaderWidget extends StatelessWidget {
  const EmptyPreloaderWidget();
  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}

class FutureErrorWidget extends StatelessWidget {
  const FutureErrorWidget();
  @override
  Widget build(BuildContext context) {
    return  Container(
          child: Align(
        alignment: Alignment.center,
        child: Text(
          'Error loading localization',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: Colors.red,
            fontSize: 18.0
          ),
        ),
      ),
    );
  }
}
