import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final iv = encrypt.IV.fromSecureRandom(16);
  final myEncrypter = encrypt.Encrypter(
    encrypt.AES(encrypt.Key.fromUtf8('12345678901234567890123456789012'),
        mode: encrypt.AESMode.cbc),
  );

  String hashPassword(String password) {
    return sha256.convert(password.codeUnits).toString();
  }

  String encryptedMessage(String message) {
    final encrypted = myEncrypter.encrypt(
      message,
      iv: iv,
    );

    return encrypted.base64;
  }

  String decryptedMessage(String encryptedString) {
    final myEncrypter2 = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromUtf8('12345678901234567890123456789011'),
          mode: encrypt.AESMode.cbc),
    );
    final encryptedString2 = base64.decode(encryptedString);
    final newValue = encrypt.Encrypted(encryptedString2);
    final ok = myEncrypter2.decryptBytes(newValue, iv: iv);
    print("============== here: ${base64.encode(ok)} =====");
    return myEncrypter2.decrypt64(
      encryptedString,
      iv: iv,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            const Text(
              'Please login to continue:',
            ),
            TextField(
              controller: userController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                print("user: ${userController.value.text}");
                print("password: ${passwordController.value.text}");
                print("==============");

                // Should we send this password to the server?
                final myHashPassword =
                    hashPassword(passwordController.value.text);
                print("hash password: $myHashPassword");
                print("==============");

                // is it secure yet?
                final dynamicSalt = userController.value.text.split("@")[0];
                final mySaltedHashPassword = hashPassword(
                    "${passwordController.value.text}:$dynamicSalt");
                print("Salted hash password: $mySaltedHashPassword");
                print("==============");

                final encryptedPassword =
                    encryptedMessage(passwordController.value.text);
                print("Encrypted password: $encryptedPassword");
                final decryptedPassword = decryptedMessage(encryptedPassword);
                print("Decrypted password: $decryptedPassword");
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
