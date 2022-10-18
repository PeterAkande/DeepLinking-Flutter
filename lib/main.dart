import 'package:deeplinking_flutter/link_details_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // iOS requires you run in release mode to test dynamic links ("flutter run --release").
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Deeplinking Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _simpleTagController =
      TextEditingController(); //To hold a simple tag to be passed

  String url = '';

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  initState() {
    super.initState();

    initDynamicLinks();
  }

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      print(dynamicLinkData.link.path);
      print(dynamicLinkData.link.queryParameters);
      print(dynamicLinkData.link.removeFragment());

      if (dynamicLinkData.link.pathSegments.isNotEmpty) {
        //Here, the queryparameter is a Map.

        String postTitle = dynamicLinkData.link.queryParameters['post'] ?? '';
        String postTag = dynamicLinkData.link.queryParameters['tag'] ?? '';
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  LinkDetailsScreen(postTitle: postTitle, postTag: postTag),
            ),
          ); // Push the new route with the parameters gotten
        });
      }
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  Future createDynamicString() async {
    //This function would be used to create a dynamic link
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      link: Uri.parse(
          'https://frenbox.com/share_fren/?post=${_postTitleController.text}&tag=${_simpleTagController.text}'),
      uriPrefix: 'https://pilad.page.link',
      androidParameters: const AndroidParameters(
          packageName: 'com.pilad.deeplinking_flutter', minimumVersion: 0),
    );
    Uri uri;

    final ShortDynamicLink shortLink =
        await dynamicLinks.buildShortLink(dynamicLinkParameters);
    uri = shortLink.shortUrl;

    url = 'https://pilad.page.link${uri.path}';

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Type a message to share to anyone',
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _postTitleController,
                decoration: const InputDecoration(hintText: 'Enter post title'),
              ),
              TextField(
                controller: _simpleTagController,
                decoration: const InputDecoration(hintText: 'Enter a Tag'),
                inputFormatters: [
                  //Prevent space between characters
                  FilteringTextInputFormatter.deny(RegExp(' '))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                      await createDynamicString().then((value) {
                        Navigator.of(context)
                            .pop(); //Disable the loading progress
                      });
                    },
                    child: Text(
                      'Create Link',
                      style: Theme.of(context).textTheme.headline3?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: url));
                    },
                    icon: const Icon(Icons.copy),
                    label: Text(
                      'Copy to Clipboard',
                      style: Theme.of(context).textTheme.headline3?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                url,
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
