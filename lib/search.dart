import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'book/book.dart' as book;
import 'home.dart';

class SearchForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchFormState();
  }
}

class _FormData {
  String bid;
}

class SearchFormState extends State<SearchForm> {
  final _formKey = GlobalKey<FormState>();
  _FormData form = _FormData();

  void submit() {
    if (!this._formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    Navigator.pushNamed(
      context,
      "/book",
      arguments: book.ScreenArguments(bid: this.form.bid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    // autofocus: true,
                    onSaved: (String value) {
                      this.form.bid = value;
                    },
                    keyboardType: TextInputType.number,
                    validator: (String value) {
                      if (value == "") {
                        return "不能为空";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "书籍编号 *",
                      helperText:
                          "如: https://www.wenku8.net/book/1861.htm 中的 1861",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        this.submit();
                      },
                      child: Text("提交"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }
}

class SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return HomePageWrapper(
      title: Text("search"),
      index: 0,
      body: SearchForm(),
    );
  }
}
