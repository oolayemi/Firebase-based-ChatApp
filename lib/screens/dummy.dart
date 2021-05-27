import 'package:flutter/material.dart';

class Dummy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: SingleChildScrollView(
        child: Container(
          width: dSize.width,
          height: dSize.height,
          child: Column(
            children: [
              SizedBox(
                height: dSize.height * 0.1,
              ),
              Flexible(child: UpSection()),
              Flexible(
                child: Container(
                  height: dSize.height * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: AuthForm(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool _isCheck = false;
  bool _isPasswordVisible = false;
  final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
  @override
  Widget build(BuildContext context) {
    final dSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    return Form(
      child: Container(
        width: dSize.width,
        height: dSize.height * 0.55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Access Code',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    Flexible(
                      child: TextFormField(
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          hintText: 'bit.ly/acc.ss/code',
                          hintStyle: TextStyle(
                            color: Colors.blue,
                          ),
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: dSize.height * 0.001),
            Flexible(
              child: CheckboxListTile(
                  title: Text('Save Details'),
                  value: _isCheck,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      _isCheck = value;
                    });
                  }),
            ),
            Flexible(
              child: SizedBox(
                height: dSize.height * 0.07,
              ),
            ),
            Flexible(
              child: orientation == Orientation.portrait
                  ? Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 24.0, right: 24.0),
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              },
                              child: Padding(
                                padding: orientation == Orientation.landscape
                                    ? EdgeInsets.all(2.0)
                                    : EdgeInsets.all(20.0),
                                child: Text(
                                  'Login',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: dSize.width * 0.5,
                        margin: EdgeInsets.only(left: 24.0, right: 24.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Padding(
                            padding: orientation == Orientation.landscape
                                ? EdgeInsets.all(2.0)
                                : EdgeInsets.all(20.0),
                            child: Text(
                              'Login',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class UpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dSize = MediaQuery.of(context).size;
    return Container(
      height: dSize.height * 0.5,
      child: Column(
        children: [
          Flexible(child: SizedBox(height: dSize.height * 0.1)),
          Flexible(
            flex: 2,
            child: Container(
              child: Center(
                child: FlutterLogo(
                  size: 120,
                ),
              ),
            ),
          ),
          Flexible(child: SizedBox(height: dSize.height * 0.1)),
          Flexible(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Text(
                  'Welcome back! Login into Dashboard!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
