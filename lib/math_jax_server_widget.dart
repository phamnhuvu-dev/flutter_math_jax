import 'package:flutter/material.dart';
import 'package:flutter_math_jax/server.dart';

class MathJaxServerWidget extends StatefulWidget {
  final Widget child;

  const MathJaxServerWidget({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateMathJaxServerWidget();
  }

  static MathJaxServerInheritedWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MathJaxServerInheritedWidget)
        as MathJaxServerInheritedWidget;
  }
}

class StateMathJaxServerWidget extends State<MathJaxServerWidget> {
  String baseUrl;
  Server server;

  @override
  Widget build(BuildContext context) {
    return MathJaxServerInheritedWidget(
      child: widget.child,
      baseUrl: baseUrl,
      server: server,
    );
  }

  @override
  void initState() {
    super.initState();
    _voidStartServer();
  }

  void _voidStartServer() {
    int port = 9450;
    server = Server(port: port);
    server.start();
    baseUrl = "http://localhost:$port/packages/flutter_math_jax/MathJax/index.html";
  }

  @override
  void dispose() {
    server.close();
    super.dispose();
  }
}

class MathJaxServerInheritedWidget extends InheritedWidget {
  final String baseUrl;
  final Server server;

  MathJaxServerInheritedWidget({
    Key key,
    Widget child,
    this.baseUrl,
    this.server,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(MathJaxServerInheritedWidget oldWidget) {
    return oldWidget != this;
  }
}
