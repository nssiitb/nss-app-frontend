import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/services/api_service.dart';

class VerifyOTP extends StatefulWidget {
  const VerifyOTP({super.key});

  @override
  State<VerifyOTP> createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  bool loading = false;
  late String roll;
  late String mode;
  late Map<String, dynamic> args;
  Timer? _timer;
  int secondsLeft = 300;
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        if (secondsLeft == 0) {
          timer.cancel();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP expired. Please request a new OTP."),
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.forgotPassword,
            (_) => false,
          );

          return;
        }

        setState(() {
          secondsLeft--;
        });
      },
    );
  }
  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    mode = args["mode"];
    roll = args["roll"];
  }

  Future<void> verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("${dotenv.env['BASE_URL']}/verify-otp"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({"roll": roll, "otp": otpController.text.trim()}),
      );

      final data=jsonDecode(response.body);

      if(!mounted) return;
      setState(()=>loading=false);

      if(response.statusCode==200 && data["status"]==200){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP verified successfully")),
        );
        if(mode == "reset"){
          Navigator.pushReplacementNamed(
            context,
            Routes.resetPassword,
            arguments: roll,
          );
        } else{
          final response = await ApiService.register({
            "roll": args["roll"],
            "name": args["name"],
            "mobile": args["mobile"],
            "email": args["email"],
            "password": args["password"],
            "fingerprint": args["fingerprint"],
          });

          final json = jsonDecode(response.body);

          if (json["status"]) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Registration successful"),
              ),
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.loginRoute,
              (_) => false,
            );
          }
        }
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Invalid OTP")),
        );
      }
    }catch(e){
      if(!mounted) return;
      setState(()=>loading=false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> resendOTP() async{
    final response = await ApiService.forgotPassword({
    "roll": roll,
    });

    if(!mounted) return;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent again")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to resend OTP")),
      );
    }
  }


  @override
  Widget build(BuildContext context){
    const bg=Color(0xFFF9F4FA);
    const card=Color(0xFFD7DDF3);
    const field=Color(0xFFC6D0EC);
    const primary=Color.fromARGB(255,0,75,112);

    return Scaffold(
      backgroundColor:bg,
      appBar:AppBar(
        backgroundColor: Colors.white,
        elevation:0,
      ),
      body:SafeArea(
        child:SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal:20,vertical:16),
          child:Form(
            key:_formKey,
            child:Column(
              children:[
                const SizedBox(height:10),
                const CircleAvatar(
                  radius:42,
                  backgroundColor:card,
                  child:Icon(Icons.mark_email_read_rounded,size:42,color:primary),
                ),
                const SizedBox(height:20),
                Text(
                  "OTP expires in ${secondsLeft ~/ 60}:${(secondsLeft % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Raleway",
                  ),
                ),
                const SizedBox(height:8),
                Text(
                  "Enter the OTP sent to\n$roll@iitb.ac.in",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize:18,
                    fontFamily:"Raleway",
                  ),
                ),
                const SizedBox(height:30),
                Container(
                  width:double.infinity,
                  padding:const EdgeInsets.all(22),
                  decoration:BoxDecoration(
                    color:card,
                    borderRadius:BorderRadius.circular(22),
                  ),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      const Text(
                        "OTP",
                        style:TextStyle(
                          fontSize:18,
                          fontWeight:FontWeight.w600,
                          fontFamily:"Raleway",
                        ),
                      ),
                      const SizedBox(height:14),
                      TextFormField(
                        controller:otpController,
                        keyboardType: TextInputType.number,
                        maxLength:6,
                        decoration:InputDecoration(
                          counterText:"",
                          filled:true,
                          fillColor:field,
                          hintText:"Enter the OTP",
                          prefixIcon:const Icon(Icons.password),
                          border:OutlineInputBorder(
                            borderRadius:BorderRadius.circular(12),
                            borderSide:BorderSide.none,
                          ),
                          enabledBorder:OutlineInputBorder(
                            borderRadius:BorderRadius.circular(12),
                            borderSide:BorderSide.none,
                          ),
                          focusedBorder:OutlineInputBorder(
                            borderRadius:BorderRadius.circular(12),
                            borderSide: const BorderSide(color:primary,width:2),
                          ),
                        ),
                        validator:(v){
                          if(v==null||v.trim().isEmpty){
                            return "Enter OTP";
                          }
                          if(v.trim().length!=6){
                            return "OTP must be 6 digits";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height:30),
                SizedBox(
                  width:double.infinity,
                  height:56,
                  child:ElevatedButton(
                    onPressed:loading?null:verifyOTP,
                    style:ElevatedButton.styleFrom(
                      backgroundColor:card,
                      foregroundColor:primary,
                      shape:RoundedRectangleBorder(
                        borderRadius:BorderRadius.circular(14),
                      ),
                    ),
                    child:loading
                      ? const SizedBox(
                          height:24,
                          width:24,
                          child:CircularProgressIndicator(strokeWidth:3),
                        )
                      : const Text(
                          "Verify OTP",
                          style:TextStyle(
                            fontSize:20,
                            fontWeight:FontWeight.bold,
                            fontFamily:"Raleway",
                          ),
                        ),
                  ),
                ),
                const SizedBox(height:10),
                TextButton(
                  onPressed: resendOTP,
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(
                      color:primary,
                      fontWeight:FontWeight.w600,
                      fontFamily:"Raleway",
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
