import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Keycloak Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _token = '';

  Future<void> _authenticate() async {
    try {
      // Configure the Keycloak details
      const clientId = 'push-messenger';
      const clientSecret = 'eca09a20-27db-4141-8976-33886e3eecf8';
      const redirectUri = 'com.example.stldemo://callback';
      const issuer = 'http://192.168.250.209:8070/auth/realms/Push';

      // Construct the authorization URL
      const authUrl =
          '$issuer/protocol/openid-connect/auth?client_id=$clientId&redirect_uri=$redirectUri&response_type=code&scope=openid';

      // Launch the browser for user authentication
      final result = await FlutterWebAuth.authenticate(
        url: authUrl,
        callbackUrlScheme: 'com.example.stldemo',
      );

      // Extract the authorization code from the redirect URI
      final code = Uri.parse(result).queryParameters['code'];

      // Exchange the authorization code for an access token
      final tokenResponse = await http.post(
        Uri.parse('$issuer/protocol/openid-connect/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      final tokenData = json.decode(tokenResponse.body);
      final token = tokenData['access_token'];

      setState(() {
        _token = token ?? '';
      });

      if (_token.isNotEmpty) {
        final decodedToken = JwtDecoder.decode(_token);
        print('Token: $_token');
        print('Decoded Token: $decodedToken');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _token = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Keycloak Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _authenticate,
          child: Text('Login with Keycloak'),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Keycloak Demo',
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   Future<void> _authenticate() async {
//     final clientId = 'push-messenger';
//     final clientSecret = 'your-client-secret';
//     final redirectUri = 'com.example.stldemo://callback';
//     final issuer = 'http://192.168.250.209:8070/auth/realms/Push';

//     final authUrl =
//         '$issuer/protocol/openid-connect/auth?client_id=$clientId&redirect_uri=$redirectUri&response_type=code&scope=openid';

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebViewScreen(
//           authUrl: authUrl,
//           redirectUri: redirectUri,
//           clientId: clientId,
//           clientSecret: clientSecret,
//           issuer: issuer,
//           onTokenReceived: (token) {
//             if (token.isNotEmpty) {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => HomePage()),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Keycloak Demo'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _authenticate,
//           child: Text('Login with Keycloak'),
//         ),
//       ),
//     );
//   }
// }

// class WebViewScreen extends StatefulWidget {
//   final String authUrl;
//   final String redirectUri;
//   final String clientId;
//   final String clientSecret;
//   final String issuer;
//   final Function(String) onTokenReceived;

//   WebViewScreen({
//     required this.authUrl,
//     required this.redirectUri,
//     required this.clientId,
//     required this.clientSecret,
//     required this.issuer,
//     required this.onTokenReceived,
//   });

//   @override
//   _WebViewScreenState createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     if (Platform.isAndroid) {
//       WebView.platform = SurfaceAndroidWebView();
//     }
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (String url) async {
//             if (url.startsWith(widget.redirectUri)) {
//               final code = Uri.parse(url).queryParameters['code'];

//               final tokenResponse = await http.post(
//                 Uri.parse('${widget.issuer}/protocol/openid-connect/token'),
//                 headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//                 body: {
//                   'grant_type': 'authorization_code',
//                   'code': code,
//                   'redirect_uri': widget.redirectUri,
//                   'client_id': widget.clientId,
//                   'client_secret': widget.clientSecret,
//                 },
//               );

//               final tokenData = json.decode(tokenResponse.body);
//               final token = tokenData['access_token'];

//               widget.onTokenReceived(token);
//             }
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.authUrl));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("Login"),
//       ),
//       body: WebViewWidget(
//         controller: _controller,
//       ),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home Page'),
//       ),
//       body: Center(
//         child: Text('Welcome to the Home Page!'),
//       ),
//     );
//   }
// }

