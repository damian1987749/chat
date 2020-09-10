import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';

String heroUrl;

void main() {
  runApp(MaterialApp(
    title: 'Named Routes Demo',
    // Start the app with the "/" named route. In this case, the app starts
    // on the FirstScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => FirstScreen(),
      '/register': (context) => RegisterScreen(),
      '/addPhoto': (context) => AddPhotoScreen(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/user': (context) => UserScreen(),
      '/privateChat': (context) => PrivateChat(),
      '/pickImage': (context) => PickImage(),
    },
  ));
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(
              heroUrl,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class AddPhotoScreen extends StatefulWidget {
  @override
  _AddPhotoScreenState createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  File _image;
  String _uploadedFileURL = '';
  String currentUser = 'null';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: DecoratedBox(
            position: DecorationPosition.background,
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                  image: AssetImage('Images/Login.jpg'), fit: BoxFit.cover),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: 100,
                    width: 100,
                    child: _image != null ? Image.file(_image) : null),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FloatingActionButton(
                    heroTag: 'btn1',
                    child: _image != null
                        ? Icon(Icons.keyboard_arrow_right)
                        : Icon(Icons.image),
                    backgroundColor: Colors.green,
                    elevation: 5,
                    tooltip: 'Register',
                    onPressed: () {
                      if (_image == null) {
                        chooseFile();
                      } else {
                        uploadPhoto();
                      }
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FloatingActionButton(
                    heroTag: 'btn2',
                    child: _image != null ? Icon(Icons.cancel) : null,
                    backgroundColor: Colors.red,
                    elevation: 5,
                    tooltip: 'Register',
                    onPressed: () {
                      _clearImage();
                    },
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void _checkUser() async {
    FirebaseUser fbuser = await _auth.currentUser();

    if (fbuser != null) {
      setState(() {
        currentUser = fbuser.email;
      });
    }
  }

  void _clearImage() async {
    setState(() {
      _image = null;
      _uploadedFileURL = '';
    });
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(
            source: ImageSource.gallery,
            maxHeight: 1080,
            maxWidth: 1920,
            imageQuality: 40)
        .then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  void uploadPhoto() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(currentUser + '.jpg');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final myController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _success;
  String _userEmail = '';
  int _counter = 0;
  final myEmailController = TextEditingController();
  final myPasswordController = TextEditingController();
  bool _bool;
  final ImagePicker _picker = ImagePicker();
  File _image;
  bool _uploading = false;

  String _uploadedFileURL = '';
  String currentUser = 'null';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myEmailController.dispose();
    myPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: DecoratedBox(
          position: DecorationPosition.background,
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
                image: AssetImage('Images/Login.jpg'), fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image != null
                    ? GestureDetector(
                        onLongPress: chooseFile,
                        child: Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(bottom: 24),
                          child: CircleAvatar(
                            backgroundImage: new FileImage(File(_image.path)),
                            radius: 200.0,
                          ),
                        ),
                      )
                    : Container(),
                Text(
                  'Register new account',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 24, left: 32, right: 32),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            color: Colors.grey[400],
                            child: TextField(
                              decoration:
                                  InputDecoration(hintText: '   Email address'),
                              controller: myEmailController,
                            ),
                          )),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 24, left: 32, right: 32),
                      // color: Colors.grey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          color: Colors.grey[400],
                          child: TextField(
                            decoration:
                                InputDecoration(hintText: '   Password'),
                            controller: myPasswordController,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        floatingActionButton: _uploading == true
            ? CircularProgressIndicator()
            : FloatingActionButton(
                onPressed:
                    _image != null ? _signUpWithEmailAndPassword : chooseFile,
                tooltip: 'Register',
                child: _image != null
                    ? Icon(Icons.arrow_right)
                    : Icon(Icons.image),
              ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(
            source: ImageSource.gallery,
            maxHeight: 1080,
            maxWidth: 1920,
            imageQuality: 40)
        .then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  void uploadPhoto() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(_userEmail + '.jpg');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
    Toast.show('the account has been created, you can log in now!', context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    new Timer(new Duration(milliseconds: 1000), () {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    });
  }

  void _signUpWithEmailAndPassword() async {
    setState(() {
      _uploading = true;
    });

    final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
      email: myEmailController.text,
      password: myPasswordController.text,
    ))
        .user;
    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
      });
      uploadPhoto();
    } else {
      _success = false;
    }
  }
}

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final myController = TextEditingController();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _success;
  String _userEmail = '';
  String user2 = 'null';
  // var random = new Random();
  // int min = 220;
  // int max = 255;

  @override
  void initState() {
    super.initState();
    /*


    _fcm.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("onResume: $message");
        String userToGoTo=(message['notification']['body']);
        setState(() {
          user2=userToGoTo;
        });
        _privateEmail();


      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Navigator.pushNamed(context,'/privateChat');
      },
    );

     */

    _checkBool();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: DecoratedBox(
            position: DecorationPosition.background,
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                  image: AssetImage('Images/Login.jpg'), fit: BoxFit.cover),
            ),
            child: Container(
                margin: EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      // crossAxisAlignment: CrossAxisAlignment.end,

                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          child: FloatingActionButton(
                            heroTag: 'btn1',
                            child: Icon(Icons.add),
                            backgroundColor: Colors.blue,
                            elevation: 5,
                            tooltip: 'register',
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                                left: 50, right: 50, bottom: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0)),
                              child: TextField(
                                textAlign: TextAlign.center,
                                decoration: new InputDecoration.collapsed(
                                    fillColor: Colors.grey[400],
                                    filled: true,
                                    hintText: 'Enter login'),
                                style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.blue,
                                ),
                                controller: _emailController,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 50, right: 50, bottom: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0)),
                              child: TextField(
                                textAlign: TextAlign.center,
                                decoration: new InputDecoration.collapsed(
                                    fillColor: Colors.grey[400],
                                    filled: true,
                                    hintText: 'Enter password'),
                                style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.blue,
                                ),
                                controller: _passwordController,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _success == null
                                  ? ''
                                  : (_success
                                      ? 'Successfully signed in ' + _userEmail
                                      : 'Sign in failed'),
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ))),
        floatingActionButton: FloatingActionButton(
          heroTag: 'btn2',
          child: Icon(Icons.keyboard_arrow_right),
          backgroundColor: Colors.green,
          elevation: 5,
          tooltip: 'Log in',
          onPressed: () {
            _signInWithEmailAndPassword();
          },
        ),
      ),
    );
  }

  void _signInWithEmailAndPassword() async {
    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;
    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
      });
      _save();
    } else {
      _success = false;
    }
  }

  _checkBool() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool booll = preferences.getBool('bool');
    if (booll == true) {
      Navigator.pushNamedAndRemoveUntil(context, '/user', (route) => false);
    } else {
      _subscribeToNotifications();
    }
  }

  Future _save() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String user = _emailController.text;
    // int randomIntBlue = min + random.nextInt(max - min);
    // int randomIntGreen = min + random.nextInt(max - min);
    // int randomIntRed = min + random.nextInt(max - min);

    preferences.setString('user', user);
    // preferences.setInt('colorBlue', randomIntBlue);
    //  preferences.setInt('colorRed', randomIntRed);
    //  preferences.setInt('colorGreen', randomIntGreen);
    preferences.setBool('bool', true);

    Navigator.pushNamedAndRemoveUntil(
        context, '/user', (Route<dynamic> route) => false);
  }

  void _subscribeToNotifications() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('notifications', false);
  }
}

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final myController = TextEditingController();
  final databaseReference = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUser = 'null';
  ScrollController _scrollController = new ScrollController();
  Stream<QuerySnapshot> mainStream;
  Stream<QuerySnapshot> userStream;
  String user2 = 'null';
  int newMessageCount = 0;
  bool isSwitched = false;

  bool _imageIcon = false;
  File _image;
  String _uploadedFileURL = '';
  bool _uploading = false;

  String _itemID;

  String _userAvatar;

  @override
  void initState() {
    super.initState();

    //databaseReference.settings(persistenceEnabled: false);

    mainStream = Firestore.instance
        .collection('messages')
        .orderBy('dateUtc', descending: true)
        .limit(100)
        .snapshots();
    userStream = Firestore.instance.collection('users').snapshots();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _checkUser();
    /* _fcm.configure(

      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },


      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        Navigator.pushNamed(context,'/privateChat');
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Navigator.pushNamed(context, '/privateChat');
      },


    );

     */
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  showAlertDelete(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("no"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("yes"),
      onPressed: () {
        _deleteUser();
      },
    );

    // set up the AlertDialog
    AlertDialog alertDialog = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Are you sure you want to delete this profile?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("no"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _itemID = null;
        });
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Yes"),
      onPressed: () {
        _removeFromDbNew();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Are you sure you want to delete this message?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: const Text('Chat'),
          automaticallyImplyLeading: true,
          actions: <Widget>[
            //removed because no point. useful on desktop
            /*   Container(
              padding: EdgeInsets.only(right: 20),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                       // Navigator.pop(context);
                      },
                      child: Icon(Icons.chevron_left)),
                ],
              ),
            ),
          */
            Padding(
                padding: EdgeInsets.only(right: 30.0, top: 10, bottom: 5),
                child: Row(
                  children: <Widget>[
                    Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                          isSwitched == true
                              ? Toast.show("Notifications on", context,
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.TOP)
                              : Toast.show('Notifications off', context,
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.TOP);
                          isSwitched == true
                              ? _fcm.subscribeToTopic('notifications')
                              : _fcm.unsubscribeFromTopic('notifications');
                          isSwitched == true
                              ? _subscribeToNotifications()
                              : _unsubscribeFromNotifications();
                        });
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,
                    ),
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            _removeBool();
                          },
                          child: Icon(
                            Icons.exit_to_app,
                          ),
                        ),
                        Text('log-out')
                      ],
                    )
                  ],
                )),
          ],
        ),
        drawer: Drawer(
            child: Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            // Important: Remove any padding from the ListView.
            //padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 50),
                child: Text(
                  'Logged in as $currentUser',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onLongPress: _pickImage,
                child: Container(
                    margin: EdgeInsets.only(top: 48),
                    height: 160,
                    width: 160,
                    child: _userAvatar != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(_userAvatar),
                            radius: 90,
                          )
                        : CircleAvatar(
                            backgroundImage: AssetImage('Login.jpg'))),
              ),
              Center(
                child: Container(
                    margin: EdgeInsets.only(top: 48),
                    child: GestureDetector(
                        onTap: () {
                          showAlertDelete(context);
                        },
                        child: Text(
                          'Delete profile',
                          style: TextStyle(fontSize: 20),
                        ))),
              ),
            ],
          ),
        )),
        body: DecoratedBox(
          position: DecorationPosition.background,
          decoration: BoxDecoration(
            color: Colors.grey,
          ),
          child: Container(
            padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
            child: Column(
              children: <Widget>[
                Container(
                  height: 100,
                  width: double.infinity,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: userStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text("Loading..");
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          final user =
                              snapshot.data.documents[index]['user'].toString();
                          final String photoUrl =
                              snapshot.data.documents[index]['photoUrl'];
                          final int newMessage =
                              snapshot.data.documents[index]['newMessage'];

                          return Stack(
                            children: <Widget>[
                              user != currentUser
                                  ? SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.white70, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        elevation: 6,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              user2 = user;
                                            });
                                            _setSharedPreferences();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PrivateChat(),
                                                settings: RouteSettings(
                                                  arguments: user,
                                                ),
                                              ),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: photoUrl,
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeInDuration: const Duration(
                                                  milliseconds: 300),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : new Container(),
                              currentUser != user && newMessage != 0
                                  ? new Positioned(
                                      bottom: 0.0,
                                      right: 8.0,
                                      child: new Card(
                                        color: Colors.white,
                                        child: Text(
                                          newMessage.toString(),
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lightBlue),
                                        ),
                                      ))
                                  : new Container(),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: mainStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text("Loading..");
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          final int reversedIndex =
                              snapshot.data.documents.length - 1 - index;
                          final message = snapshot
                              .data.documents[index]['message']
                              .toString();
                          final timestamp =
                              snapshot.data.documents[index]['date'].toString();
                          final user =
                              snapshot.data.documents[index]['user'].toString();
                          String userFormatted =
                              user.substring(0, user.indexOf('@'));
                          final itemID =
                              snapshot.data.documents[index].documentID;
                          final list = snapshot.data.documents;
                          final String photoUrl =
                              snapshot.data.documents[index]['photoUrl'];
                          final String downloadUrl =
                              snapshot.data.documents[index]['downloadUrl'];
                          return Dismissible(
                            onDismissed: (direction) {
                              if (user == currentUser) {
                                setState(() {
                                  _itemID = itemID;
                                });
                                // removeFromDb(itemID);
                                showAlertDialog(context);
                              } else {
                                setState(() {
                                  mainStream = Firestore.instance
                                      .collection('messages')
                                      .orderBy('dateUtc', descending: true)
                                      .limit(100)
                                      .snapshots();

                                  userStream = Firestore.instance
                                      .collection('users')
                                      .snapshots();
                                });
                                Toast.show("You cannot do it", context,
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.BOTTOM);
                              }
                            },
                            child: Card(
                              elevation: 5,
                              margin: EdgeInsets.all(6),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: downloadUrl == ""
                                  ? ListTile(
                                      title: SelectableText(message),
                                      subtitle: Text(userFormatted),
                                      trailing: Text(timestamp),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100.0)),
                                        child: CachedNetworkImage(
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                          imageUrl: photoUrl,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 300),
                                          fadeInDuration:
                                              const Duration(milliseconds: 300),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      child: Hero(
                                        tag: 'imageHero',
                                        child: CachedNetworkImage(
                                          //height: 250,
                                          fit: BoxFit.cover,
                                          imageUrl: downloadUrl,
                                          placeholder: (context, url) =>
                                              LinearProgressIndicator(),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 300),
                                          fadeInDuration:
                                              const Duration(milliseconds: 300),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          heroUrl = downloadUrl;
                                        });
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (_) {
                                          return DetailScreen();
                                        }));
                                      },
                                    ),
                            ),
                            key: UniqueKey(),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onDoubleTap: _changeIcon,
                        child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                                bottomLeft: Radius.circular(20.0)),
                            child: TextField(
                              textAlign: TextAlign.center,
                              decoration: new InputDecoration.collapsed(
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  hintText: _image == null
                                      ? 'add message'
                                      : 'image loaded'),
                              style: TextStyle(
                                fontSize: 26,
                                color: Colors.black,
                              ),
                              controller: myController,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _uploading == false
                        ? Column(
                            children: <Widget>[
                              _imageIcon == false || _image != null
                                  ? FloatingActionButton(
                                      heroTag: 'btn2',
                                      backgroundColor: Colors.green,
                                      child: Icon(Icons.send),
                                      elevation: 5,
                                      tooltip: 'Search',
                                      onPressed: () {
                                        _scrollController.animateTo(
                                          0.0,
                                          curve: Curves.easeOut,
                                          duration:
                                              const Duration(milliseconds: 300),
                                        );
                                        if (_image != null) {
                                          setState(() {
                                            _uploading = true;
                                          });
                                          _uploadAndSave();
                                          // _clearImage();

                                        } else {
                                          if (myController.text != '') {
                                            _saveToFB();
                                            myController.clear();
                                          }
                                        }
                                      },
                                    )
                                  : FloatingActionButton(
                                      heroTag: 'btn1',
                                      backgroundColor: Colors.green,
                                      child: Icon(Icons.image),
                                      elevation: 5,
                                      tooltip: 'Search',
                                      onPressed: () {
                                        chooseFile();
                                        // Navigator.pushNamed(context, '/pickImage');
                                      },
                                    )
                            ],
                          )
                        : CircularProgressIndicator(),
                  ],
                ),
              ],
            ),
          ),
        ),

        //floatingActionButton:
      ),
    );
  }

  _removeBool() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('bool');
    String uid = currentUser;
    String fcmToken = await _fcm.getToken();
    await databaseReference
        .collection('users')
        .document(uid)
        .collection('tokens')
        .document(fcmToken)
        .delete();
    await _auth.signOut().whenComplete(() =>
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false));
  }

  _uploadAndSave() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chatPhotos/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
      _saveToFB();
    });
  }

  _saveToFB() async {
    String message = myController.text;

    //SharedPreferences preferences = await SharedPreferences.getInstance();
    //String user = preferences.getString('user').toString();
    // int colorBlue = preferences.getInt('colorBlue');
    // int colorRed = preferences.getInt('colorRed');
    //  int colorGreen = preferences.getInt('colorGreen');

    final ref = FirebaseStorage.instance.ref().child(currentUser + '.jpg');
    var downloadUrl = await ref.getDownloadURL();
    String photoUrl = downloadUrl.toString();
    DateTime now = DateTime.now();
    String dateUtc = now.toUtc().toString();
    String date = now.toString();
    String Date = DateFormat('kk:mm - dd-MM-yyyy').format(now);
    await databaseReference.collection('messages').document(date).setData({
      'message': message,
      'date': Date,
      'dateUtc': dateUtc,
      'user': currentUser,
      // 'colorBlue': colorBlue,
      //  'colorRed': colorRed,
      //  'colorGreen': colorGreen,
      'photoUrl': photoUrl,
      'downloadUrl': _uploadedFileURL
    });
    _clearImage();
  }

  void removeFromDb(itemID) async {
    Firestore.instance.collection('messages').document(itemID).delete();
  }

  void _checkUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    FirebaseUser fbuser = await _auth.currentUser();
    bool notifications = preferences.getBool('notifications');
    setState(() {
      isSwitched = notifications;
    });

    if (fbuser != null) {
      setState(() {
        currentUser = fbuser.email;
      });
    }
    // String user = preferences.getString('user').toString();
    //  setState(() {
    //    currentUser = user;
    //  });

    _saveDeviceToken();

    final ref = FirebaseStorage.instance.ref().child(currentUser + '.jpg');
    var downloadUrl = await ref.getDownloadURL();
    String photoUrl = downloadUrl.toString();
    setState(() {
      _userAvatar = photoUrl;
    });
    new Timer(new Duration(milliseconds: 1000), () async {
      await databaseReference
          .collection('users')
          .document(currentUser)
          .setData({
        'user': currentUser,
        'photoUrl': photoUrl,
        'newMessage': 0,
      });
    });
  }

  _saveDeviceToken() async {
    // Get the current user
    String uid = currentUser;
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      var tokens = databaseReference
          .collection('users')
          .document(uid)
          .collection('tokens')
          .document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
      });
    }
  }

  _setSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('user2', user2);
  }

  _subscribeToNotifications() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('notifications', true);
  }

  _unsubscribeFromNotifications() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('notifications', false);
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(
            source: ImageSource.gallery,
            maxHeight: 1080,
            maxWidth: 1920,
            imageQuality: 40)
        .then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  void _changeIcon() {
    if (_imageIcon == false) {
      setState(() {
        _imageIcon = true;
        Toast.show('You can add image now', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
      });
    } else {
      setState(() {
        _imageIcon = false;
      });
    }
  }

  void _clearImage() async {
    setState(() {
      _image = null;
      _imageIcon = false;
      _uploadedFileURL = '';
      _uploading = false;
    });
  }

  void _removeFromDbNew() async {
    Firestore.instance.collection('messages').document(_itemID).delete();
    setState(() {
      _itemID = null;
    });
  }

  void _pickImage() async {
    await ImagePicker.pickImage(
            source: ImageSource.gallery,
            maxHeight: 1080,
            maxWidth: 1920,
            imageQuality: 40)
        .then((image) {
      setState(() {
        _image = image;
      });
    }).whenComplete(() => _uploadAvatar());
  }

  _uploadAvatar() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(currentUser + '.jpg');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;

    storageReference.getDownloadURL().then((fileURL) {});
    setState(() {
      _image = null;
      _imageIcon = false;
      _uploadedFileURL = '';
      _uploading = false;
    });
    Toast.show('Profile picture changed', context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    _removeBool();
  }

  void _deleteUser() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(currentUser + '.jpg');

    storageReference.delete();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    user.delete();
    await databaseReference.collection('users').document(currentUser).delete();

    Toast.show('Profile picture changed', context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}

class PrivateChat extends StatefulWidget {
  @override
  _PrivateChatState createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChat> {
  final databaseReference = Firestore.instance;
  String currentUser = 'null';
  String user2 = 'null';
  final myController = TextEditingController();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  ScrollController _scrollController = new ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<QuerySnapshot> privStream;
  int messageCount = 0;
  bool isSwitched = false;
  String _itemID;

  File _image;
  String _uploadedFileURL = '';
  bool _imageIcon = false;

  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _checkUser();
    _removeNewMessage();
    _getNewMessageCount();

    /*

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Navigator.pushNamed(context, '/privateChat');
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Navigator.pushNamed(context,'/privateChat');
      },


    );

     */
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("no"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _itemID = null;
        });
      },
    );
    Widget continueButton = FlatButton(
      child: Text("yes"),
      onPressed: () {
        _removeFromDbNew();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Are you sure you want to delete this message?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final String userClicked = ModalRoute.of(context).settings.arguments;

    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: const Text('Chat'),
          automaticallyImplyLeading: true,
          actions: <Widget>[
            //removed because no point. useful on desktop
            /*   Container(
              padding: EdgeInsets.only(right: 20),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                       // Navigator.pop(context);
                      },
                      child: Icon(Icons.chevron_left)),
                ],
              ),
            ),
          */
            Padding(
                padding: EdgeInsets.only(right: 30.0, top: 10, bottom: 5),
                child: Row(
                  children: <Widget>[
                    Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                          isSwitched == true
                              ? Toast.show("Notifications on", context,
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.TOP)
                              : Toast.show('Notifications off', context,
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.TOP);
                        });
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,
                    ),
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            // _removeBool();
                          },
                          child: Icon(
                            Icons.exit_to_app,
                          ),
                        ),
                        Text('log-out')
                      ],
                    )
                  ],
                )),
          ],
        ),
        body: DecoratedBox(
          position: DecorationPosition.background,
          decoration: BoxDecoration(
            color: Colors.grey,
          ),
          child: Container(
            padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: privStream = Firestore.instance
                        .collection('privateChats')
                        .document('users')
                        .collection(currentUser)
                        .document(userClicked)
                        .collection('messages')
                        .orderBy('dateUtc', descending: true)
                        .limit(100)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text("Loading..");
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          final int reversedIndex =
                              snapshot.data.documents.length - 1 - index;
                          final message = snapshot
                              .data.documents[index]['message']
                              .toString();
                          final timestamp =
                              snapshot.data.documents[index]['date'].toString();
                          final user =
                              snapshot.data.documents[index]['user'].toString();
                          String userFormatted =
                              user.substring(0, user.indexOf('@'));
                          final itemID =
                              snapshot.data.documents[index].documentID;
                          final list = snapshot.data.documents;
                          final String photoUrl =
                              snapshot.data.documents[index]['photoUrl'];
                          final String downloadUrl =
                              snapshot.data.documents[index]['downloadUrl'];
                          // final int colorBlue = snapshot
                          //    .data.documents[reversedIndex]['colorBlue'];
                          // final int colorRed = snapshot
                          //    .data.documents[reversedIndex]['colorRed'];
                          // final int colorGreen = snapshot
                          //     .data.documents[reversedIndex]['colorGreen'];
                          return Dismissible(
                            onDismissed: (direction) {
                              if (user == currentUser) {
                                setState(() {
                                  _itemID = itemID;
                                });
                                // removeFromDb(itemID);
                                showAlertDialog(context);
                              } else {
                                Toast.show("You cannot do it", context,
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.BOTTOM);
                                setState(() {
                                  privStream = Firestore.instance
                                      .collection('privateChats')
                                      .document('users')
                                      .collection(currentUser)
                                      .document(userClicked)
                                      .collection('messages')
                                      .orderBy('dateUtc', descending: true)
                                      .limit(100)
                                      .snapshots();
                                });
                              }
                            },
                            child: Card(
                              elevation: 5,
                              margin: EdgeInsets.all(6),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: downloadUrl == ""
                                  ? ListTile(
                                      title: Text(message),
                                      subtitle: Text(userFormatted),
                                      trailing: Text(timestamp),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100.0)),
                                        child: CachedNetworkImage(
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                          imageUrl: photoUrl,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 300),
                                          fadeInDuration:
                                              const Duration(milliseconds: 300),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      child: Hero(
                                        tag: 'imageHero',
                                        child: CachedNetworkImage(
                                          //height: 250,
                                          fit: BoxFit.cover,
                                          imageUrl: downloadUrl,
                                          placeholder: (context, url) =>
                                              LinearProgressIndicator(),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 300),
                                          fadeInDuration:
                                              const Duration(milliseconds: 300),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          heroUrl = downloadUrl;
                                        });
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (_) {
                                          return DetailScreen();
                                        }));
                                      },
                                    ),
                            ),
                            key: UniqueKey(),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onDoubleTap: _changeIcon,
                        child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                                bottomLeft: Radius.circular(20.0)),
                            child: TextField(
                              textAlign: TextAlign.center,
                              decoration: new InputDecoration.collapsed(
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  hintText: _image == null
                                      ? 'add message'
                                      : 'image loaded'),
                              style: TextStyle(
                                fontSize: 26,
                                color: Colors.black,
                              ),
                              controller: myController,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _uploading == false
                        ? Column(
                            children: <Widget>[
                              _imageIcon == false || _image != null
                                  ? FloatingActionButton(
                                      heroTag: 'btn2',
                                      backgroundColor: Colors.green,
                                      child: Icon(Icons.send),
                                      elevation: 5,
                                      tooltip: 'Search',
                                      onPressed: () {
                                        _scrollController.animateTo(
                                          0.0,
                                          curve: Curves.easeOut,
                                          duration:
                                              const Duration(milliseconds: 300),
                                        );
                                        if (_image != null) {
                                          setState(() {
                                            _uploading = true;
                                          });
                                          _uploadAndSave();
                                          _incrementNewMessage();
                                          // _clearImage();

                                        } else {
                                          if (myController.text != '') {
                                            _saveToFB();
                                            _incrementNewMessage();
                                            myController.clear();
                                          }
                                        }
                                      },
                                    )
                                  : FloatingActionButton(
                                      heroTag: 'btn1',
                                      backgroundColor: Colors.green,
                                      child: Icon(Icons.image),
                                      elevation: 5,
                                      tooltip: 'Search',
                                      onPressed: () {
                                        chooseFile();
                                        // Navigator.pushNamed(context, '/pickImage');
                                      },
                                    )
                            ],
                          )
                        : CircularProgressIndicator(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeIcon() {
    if (_imageIcon == false) {
      setState(() {
        _imageIcon = true;
        Toast.show('You can add image now', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
      });
    } else {
      setState(() {
        _imageIcon = false;
      });
    }
  }

  void _checkUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String user = preferences.getString('user2').toString();
    FirebaseUser fbuser = await _auth.currentUser();
    setState(() {
      user2 = user;
    });

    if (fbuser != null) {
      setState(() {
        currentUser = fbuser.email;
      });
    }
  }

  _uploadAndSave() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chatPhotos/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
      _saveToFB();
    });
  }

  _saveToDB() async {
    String message = myController.text;

    //SharedPreferences preferences = await SharedPreferences.getInstance();
    //String user = preferences.getString('user').toString();
    // int colorBlue = preferences.getInt('colorBlue');
    // int colorRed = preferences.getInt('colorRed');
    //  int colorGreen = preferences.getInt('colorGreen');

    final ref = FirebaseStorage.instance.ref().child(currentUser + '.jpg');
    var downloadUrl = await ref.getDownloadURL();
    String photoUrl = downloadUrl.toString();
    DateTime now = DateTime.now();
    String dateUtc = now.toUtc().toString();
    String date = now.toString();
    String Date = DateFormat('kk:mm - dd-MM-yyyy').format(now);
    await databaseReference.collection('messages').document(date).setData({
      'message': message,
      'date': Date,
      'dateUtc': dateUtc,
      'user': currentUser,
      // 'colorBlue': colorBlue,
      //  'colorRed': colorRed,
      //  'colorGreen': colorGreen,
      'photoUrl': photoUrl,
      'downloadUrl': _uploadedFileURL
    });
    _clearImage();
  }

  void _clearImage() async {
    setState(() {
      _image = null;
      _imageIcon = false;
      _uploadedFileURL = '';
      _uploading = false;
    });
  }

  void removeFromDb(itemID) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //String user2 = ModalRoute.of(context).settings.arguments;
    String user2 = preferences.getString('user2');
    await databaseReference
        .collection('privateChats')
        .document('users')
        .collection(currentUser)
        .document(user2)
        .collection('messages')
        .document(itemID)
        .delete();
    await databaseReference
        .collection('privateChats')
        .document('users')
        .collection(user2)
        .document(currentUser)
        .collection('messages')
        .document(itemID)
        .delete();
  }

  _saveToFB() async {
    String message = myController.text;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    //String user = ModalRoute.of(context).settings.arguments;
    String user = preferences.getString('user2');
    final ref = FirebaseStorage.instance.ref().child(currentUser + '.jpg');
    var downloadUrl = await ref.getDownloadURL();
    String photoUrl = downloadUrl.toString();
    //  int colorBlue = preferences.getInt('colorBlue');
    //  int colorRed = preferences.getInt('colorRed');
    //  int colorGreen = preferences.getInt('colorGreen');
    DateTime now = DateTime.now();
    String date = now.toString();
    String dateUtc = now.toUtc().toString();
    String Date = DateFormat('kk:mm - yyyy-MM-dd').format(now);

    await databaseReference
        .collection('privateChats')
        .document('users')
        .collection(currentUser)
        .document(user)
        .collection('messages')
        .document(date)
        .setData({
      'message': message,
      'date': Date,
      'dateUtc': dateUtc,
      'user': currentUser,
      'photoUrl': photoUrl,
      'downloadUrl': _uploadedFileURL
      //  'colorBlue': colorBlue,
      //  'colorRed': colorRed,
      //  'colorGreen': colorGreen
    });
    await databaseReference
        .collection('privateChats')
        .document('users')
        .collection(user)
        .document(currentUser)
        .collection('messages')
        .document(date)
        .setData({
      'message': message,
      'date': Date,
      'dateUtc': dateUtc,
      'user': currentUser,
      'photoUrl': photoUrl,
      'downloadUrl': _uploadedFileURL
      // 'colorBlue': colorBlue,
      //  'colorRed': colorRed,
      //  'colorGreen': colorGreen
    });
    await databaseReference.collection('fcmMessage').document(date).setData({
      'message': message,
      'recipient': user,
      'user': currentUser,
      'photoUrl': photoUrl,
    });
    await databaseReference
        .collection('users')
        .document(currentUser)
        .updateData({'newMessage': messageCount});

    _clearImage();
  }

  void _removeNewMessage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String user = preferences.getString('user2').toString();
    await databaseReference
        .collection('users')
        .document(user)
        .updateData({'newMessage': 0});
  }

  void _getNewMessageCount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String user = preferences.getString('user2').toString();
    await databaseReference
        .collection('users')
        .document(user)
        .get()
        .then((DocumentSnapshot ds) {
      setState(() {
        messageCount = ds.data['newMessage'];
      });
    });
  }

  void _removeFromDbNew() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //String user2 = ModalRoute.of(context).settings.arguments;
    String user2 = preferences.getString('user2');
    await databaseReference
        .collection('privateChats')
        .document('users')
        .collection(currentUser)
        .document(user2)
        .collection('messages')
        .document(_itemID)
        .delete();
    await databaseReference
        .collection('privateChats')
        .document('users')
        .collection(user2)
        .document(currentUser)
        .collection('messages')
        .document(_itemID)
        .delete();
    setState(() {
      _itemID = null;
    });
  }

  void _incrementNewMessage() {
    messageCount++;
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(
            source: ImageSource.gallery,
            maxHeight: 1080,
            maxWidth: 1920,
            imageQuality: 40)
        .then((image) {
      setState(() {
        _image = image;
      });
    });
  }
}

class PickImage extends StatefulWidget {
  @override
  _PickImageState createState() => new _PickImageState();
}

class _PickImageState extends State<PickImage> {
  File _image;
  String _uploadedFileURL;
  final myController = TextEditingController();
  final databaseReference = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUser = 'null';
  ScrollController _scrollController = new ScrollController();
  Stream<QuerySnapshot> mainStream;
  Stream<QuerySnapshot> userStream;
  String user2 = 'null';
  int newMessageCount = 0;
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return new MaterialApp(
      home: new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: const Text('Chat'),
        ),
        body: DecoratedBox(
          position: DecorationPosition.background,
          decoration: BoxDecoration(
            color: Colors.grey,
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                Text('Selected Image'),
                _image != null
                    ? Image.asset(
                        _image.path,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(height: 150),
                _image == null
                    ? RaisedButton(
                        child: Text('Choose File'),
                        onPressed: chooseFile,
                        color: Colors.cyan,
                      )
                    : Container(),
                _image != null
                    ? RaisedButton(
                        child: Text('Upload File'),
                        onPressed: uploadFile,
                        color: Colors.cyan,
                      )
                    : Container(),
                _image != null
                    ? RaisedButton(
                        child: Text('Clear Selection'),
                        onPressed: clearSelection(),
                      )
                    : Container(),
                Text('Uploaded Image'),
                _uploadedFileURL != null
                    ? Image.network(
                        _uploadedFileURL,
                        height: 150,
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  Future uploadFile() async {
    final ref = FirebaseStorage.instance.ref().child(currentUser + '.jpg');
    var downloadUrl = await ref.getDownloadURL();
    String photoUrl = downloadUrl.toString();
    DateTime now = DateTime.now();
    String dateUtc = now.toUtc().toString();
    String date = now.toString();
    String Date = DateFormat('kk:mm - dd-MM-yyyy').format(now);
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chatPhotos/${Path.basename(_image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
      _saveToFB();
    });
  }

  _saveToFB() async {
    //SharedPreferences preferences = await SharedPreferences.getInstance();
    //String user = preferences.getString('user').toString();
    // int colorBlue = preferences.getInt('colorBlue');
    // int colorRed = preferences.getInt('colorRed');
    //  int colorGreen = preferences.getInt('colorGreen');

    final ref = FirebaseStorage.instance.ref().child(currentUser + '.jpg');
    var downloadUrl = await ref.getDownloadURL();
    String photoUrl = downloadUrl.toString();
    DateTime now = DateTime.now();
    String dateUtc = now.toUtc().toString();
    String date = now.toString();
    String Date = DateFormat('kk:mm - dd-MM-yyyy').format(now);
    await databaseReference.collection('messages').document(date).setData({
      'message': '',
      'date': Date,
      'dateUtc': dateUtc,
      'user': currentUser,
      // 'colorBlue': colorBlue,
      //  'colorRed': colorRed,
      //  'colorGreen': colorGreen,
      'photoUrl': photoUrl,
      'downloadUrl': _uploadedFileURL
    });
  }

  void _checkUser() async {
    FirebaseUser fbuser = await _auth.currentUser();

    if (fbuser != null) {
      setState(() {
        currentUser = fbuser.email;
      });
    }
  }

  clearSelection() {}
}
