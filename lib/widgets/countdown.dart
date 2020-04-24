import 'package:flutter/cupertino.dart';

class Countdown extends StatefulWidget {
  final int seconds;
  Countdown({Key key, this.seconds}) : super(key: key);

  @override
  _Countdown createState() => _Countdown();
}

class _Countdown extends State<Countdown> {
  String message = "";
  @override
  void initState() {
    tick();
  }

  tick() async {
    for (var s = 0; s < widget.seconds; s++) {
      if (!this.mounted) return;
      setState(() {
        message = "Waiting ${widget.seconds - s}...";
      });
      await new Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      message = "Starting...";
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
