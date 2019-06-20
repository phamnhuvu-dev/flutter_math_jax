import 'package:flutter/material.dart';
import 'package:flutter_math_jax/math_jax_server_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MathJax extends StatefulWidget {
  final String teXHTML;
  final VoidCallback onFinished;

  const MathJax({
    Key key,
    this.teXHTML,
    this.onFinished,
  }) : super(key: key);

  @override
  State<MathJax> createState() => _StateMathJax();
}

class _StateMathJax extends State<MathJax> {
  double height = 1.0;

  MathJaxServerInheritedWidget mathJaxServer;

  @override
  Widget build(BuildContext context) {
    if (mathJaxServer == null) {
      mathJaxServer = MathJaxServerWidget.of(context);
    }
    print('render webview');
    int time1 = DateTime.now().millisecondsSinceEpoch;
    return IgnorePointer(
      child: SizedBox(
        width: double.maxFinite,
        height: height,
        child: WebView(
          key: widget.key,
          initialUrl:
              "${mathJaxServer.baseUrl}?data=${Uri.encodeComponent(widget.teXHTML)}",
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: Set.of(
            <JavascriptChannel>[
              JavascriptChannel(
                name: 'onFinished',
                onMessageReceived: (JavascriptMessage message) {
                  print(
                      'Time ${DateTime.now().millisecondsSinceEpoch - time1}');
                  setState(() {
                    widget.onFinished();
                    height = double.parse(message.message) * 1.1;
                  });

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
