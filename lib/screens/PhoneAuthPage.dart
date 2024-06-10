import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PhoneAuthPage extends StatefulWidget {
  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
String? _verificationId;

/*Future<void> verifyPhoneNumber(String phoneNumber) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      // Auto-retrieve verification code
      await _auth.signInWithCredential(credential);
    },
    verificationFailed: (FirebaseAuthException e) {
      // Verification failed
    },
    codeSent: (String verificationId, int? resendToken) async {
      // Save the verification ID for future use
      String smsCode = ''; // Code input by the user
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      // Sign the user in with the credential
      await _auth.signInWithCredential(credential);
    },
    codeAutoRetrievalTimeout: (String verificationId) {},
    timeout: Duration(seconds: 60),
  );
}*/

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;

  void _sendOtp() async{
    setState(() {
      _isLoading = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        setState(() {
          _isLoading = false;
          _isOtpSent = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Phone number automatically verified and user signed in: ${_auth.currentUser?.uid}'),
        ));
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Phone number verification failed: ${e.message}'),
        ));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isLoading = false;
          _isOtpSent = true;
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: Duration(seconds: 60),
    );
  }

  void _verifyOtp() async{
    setState(() {
      _isLoading = true;
    });

    String smsCode = _otpController.text.trim();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    try {
      await _auth.signInWithCredential(credential);
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('OTP verified successfully!'),
      ));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to verify OTP: ${e.toString()}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Auth Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
              keyboardType: TextInputType.phone,
              
            ),
            
            SizedBox(height: 16),
            _isOtpSent
                ? TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'OTP',
                    ),
                    keyboardType: TextInputType.number,
                  )
                : Container(),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : _isOtpSent
                    ? ElevatedButton(
                        onPressed: _verifyOtp,
                        child: Text('Verify OTP'),
                      )
                    : ElevatedButton(
                        onPressed: _sendOtp,
                        child: Text('Send OTP'),
                      ),
          ],
        ),
      ),
    );
  }
}
