import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var colorScheme = Theme.of(context).colorScheme;
    var delimiter = "\r\n\r\n";
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        child: RichText(
          text: TextSpan(
            style: textTheme.bodyText2,
            children: [
              TextSpan(children: [
                TextSpan(text: "项目地址: $delimiter"),
                TextSpan(
                  style: TextStyle(color: colorScheme.primary),
                  text: "    https://github.com/shynome/wenku8-flutter",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final url = 'https://github.com/shynome/wenku8-flutter';
                      final can = await canLaunch(url);
                      if (can) {
                        await launch(url);
                      }
                    },
                ),
              ]),
              TextSpan(text: delimiter),
              TextSpan(children: [
                TextSpan(text: "反馈问题: $delimiter"),
                TextSpan(
                  style: TextStyle(color: colorScheme.primary),
                  text: "    https://github.com/shynome/wenku8-flutter/issues",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final url =
                          'https://github.com/shynome/wenku8-flutter/issues';
                      final can = await canLaunch(url);
                      if (can) {
                        await launch(url);
                      }
                    },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
