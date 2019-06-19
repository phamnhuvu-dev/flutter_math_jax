import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:mime/mime.dart';

class Server {
  final List<String> contentHtmlType = ['text', 'html'];
  final String charset = 'utf-8';
  final String splitSymbol = '/';
  final String html = 'index.html';

  HttpServer _server;
  bool _isStarted = false;

  int _port;

  Server({int port = 1080}) {
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
    Completer completer = Completer();

    if (_isStarted) return completer.future;

    runZoned(() {
      HttpServer.bind('127.0.0.1', _port, shared: true).then((server) {
        print('Server running on http://localhost:' + _port.toString());

        this._server = server;

        server.listen((HttpRequest request) async {
          List<int> body = List();
          String path = request.requestedUri.path;
          path = (path.startsWith(splitSymbol)) ? path.substring(1) : path;
          path += (path.endsWith(splitSymbol)) ? html : '';

          try {
            body = (await rootBundle.load(path)).buffer.asUint8List();
          } catch (e) {
            print(e.toString());
            request.response.close();
            return;
          }

          List<String> contentType;
          String mimeType = lookupMimeType(
            request.requestedUri.path,
            headerBytes: body,
          );
          if (mimeType != null) {
            contentType = mimeType.split(splitSymbol);
          } else {
            contentType = contentHtmlType;
          }

          request.response.headers.contentType =
              ContentType(contentType[0], contentType[1], charset: charset);
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
