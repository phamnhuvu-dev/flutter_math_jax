import 'dart:async';
import 'dart:io';
import 'package:mime/mime.dart';


import 'package:flutter/services.dart';

class Server {

  HttpServer _server;
  bool _isStarted = false;

  int _port;

  Server({int port = 18080}) {
    this._port = port;
  }

  Future<void> close() async {
    if (this._server != null) {
      await this._server.close(force: true);
      print('Server running on http://localhost:$_port closed');
      this._server = null;
    }
    _isStarted = false;
  }

  Future<void> start() async {
    if (this._server != null) {
      throw Exception('Server already started on http://localhost:$_port');
    }
    var completer = new Completer();

    if (_isStarted) return completer.future;

    runZoned(() {
      HttpServer.bind('127.0.0.1', _port, shared: true).then((server) {
        print('Server running on http://localhost:' + _port.toString());

        this._server = server;

        server.listen((HttpRequest request) async {
          var body = List<int>();
          var path = request.requestedUri.path;
          path = (path.startsWith('/')) ? path.substring(1) : path;
          path += (path.endsWith('/')) ? 'index.html' : '';

          try {
            body = (await rootBundle.load(path)).buffer.asUint8List();
          } catch (e) {
            print(e.toString());
            request.response.close();
            return;
          }
          var contentType = ['text', 'html'];
          var mimeType = lookupMimeType(
            request.requestedUri.path,
            headerBytes: body,
          );
          if (mimeType != null) {
            contentType = mimeType.split('/');
          }

          request.response.headers.contentType =
          new ContentType(contentType[0], contentType[1], charset: 'utf-8');
          request.response.add(body);
          request.response.close();
        });

        completer.complete();
        _isStarted = true;
      });
    }, onError: (e, stackTrace) {
      _isStarted = false;
      print('Error: $e $stackTrace');
    });

    return completer.future;
  }
}
