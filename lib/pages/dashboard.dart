import 'package:flutter/material.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        title: Text('DashBoard'),
        centerTitle: true,
        backgroundColor: Colors.black26,
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Welcome to your finance!',
              style: TextStyle(fontSize: 22),
            ),
            Text(
              'Here your data appears...',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop();
              },
              child: Text('Back'),
            )
          ],
        ),
      ),
    );
  }
}
//charan