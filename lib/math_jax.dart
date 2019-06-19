import 'package:flutter/material.dart';
import 'package:flutter_math_jax/math_jax_server_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MathJax extends StatefulWidget {
  final Color backgroundColor;
  final String teXHTML;

  const MathJax({Key key, this.teXHTML, this.backgroundColor})
      : super(key: key);

  @override
  State<MathJax> createState() => _StateMathJax();
}

class _StateMathJax extends State<MathJax> {
  WebViewController controller;
  double opacity = 0.0;
  double height = 1.0;

  MathJaxServerInheritedWidget mathJaxServer;

  @override
  Widget build(BuildContext context) {
    if (mathJaxServer == null) {
      mathJaxServer = MathJaxServerWidget.of(context);
    }
    int time1 = DateTime.now().millisecondsSinceEpoch;
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        height: height,
        child: IgnorePointer(
          child: WebView(
            key: widget.key,
            initialUrl:
                "${mathJaxServer.baseUrl}?data=${Uri.encodeComponent(widget.teXHTML)}",
            onWebViewCreated: (WebViewController controller) {
              this.controller = controller;
              _changeBodyBackgroundColor();
            },
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: Set.of(
              <JavascriptChannel>[
                JavascriptChannel(
                  name: 'onFinished',
                  onMessageReceived: (JavascriptMessage message) {
                    print(DateTime.now().millisecondsSinceEpoch - time1);
                    Future.delayed(Duration(milliseconds: 500), () {
                      setState(
                        () {
                          height = (double.parse(message.message) + 2) + 15;
                          opacity = 1.0;
                        },
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeBodyBackgroundColor() {
    controller.evaluateJavascript('''
      document.body.style.background = "#${widget.backgroundColor.value.toRadixString(16).substring(2)}"
    ''');
  }

  @override
  void didUpdateWidget(MathJax oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backgroundColor != widget.backgroundColor) {
      _changeBodyBackgroundColor();
    }
  }
}
