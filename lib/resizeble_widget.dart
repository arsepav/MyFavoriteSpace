import 'package:flutter/material.dart';

class ResizableWidget extends StatefulWidget {
  @override
  _ResizableWidgetState createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  double _baseScaleFactor = 1.0;
  double _scaleFactor = 0.7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resizable Widget'),
      ),
      body: Center(
        child: GestureDetector(
          onScaleStart: (details) {
            _baseScaleFactor = _scaleFactor;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scaleFactor = _baseScaleFactor * details.scale;
            });
          },
          child: Container(
            width: 100.0 * _scaleFactor,
            height: 100.0 * _scaleFactor,
            color: Colors.blue,
            child: Center(
              child: Text(
                'Resize me',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
