import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walletapp/Creators%20Screen/creators_home.dart';
import 'package:walletapp/Users%20Screen/Home/home_page.dart';
import 'package:walletapp/auth/creators/creators_login.dart';
import 'package:walletapp/auth/users/Signup.dart';
import 'package:walletapp/controllers/auth_controller.dart';
import 'package:walletapp/utils/snackbar.dart';


class UsersLoginScreen extends StatefulWidget {

  const UsersLoginScreen({Key? key}) : super(key: key);

  @override
  State<UsersLoginScreen> createState() => _UsersLoginScreen();
}

class _UsersLoginScreen extends State<UsersLoginScreen> {
  late String _enterEmail;
  late String _enterPassword;

  final AuthController _controller = AuthController();
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  bool _wait = false;
  bool _obscureText = true;


  @override
  Widget build(BuildContext context) {
    signUp()async{
      setState(() {
        _wait = true;
      });
      if(_globalKey.currentState!.validate()){
        String res = await _controller.loginCreatorsOrUsers(
            _enterEmail,
            _enterPassword
         );
        setState(() {
          _wait = false;
        });
        if(res != 'success'){
          return snack(context, res);
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
            return HomePage();
          }));
        }
        setState(() {
          _wait = false;
        });
      }else{
        setState(() {
          _wait = false;
        });
      }
    }
    return Form(
      key: _globalKey,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding:  EdgeInsets.all(MediaQuery.of(context).padding.top),
                child: SvgPicture.asset('assets/images/Logo.svg'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Sign In To Your Account',
                      style: GoogleFonts.epilogue(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: PhysicalModel(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  elevation: 10,
                  shadowColor: Colors.grey.shade200,
                  child: TextFormField(
                    validator: (v){
                      if(v!.isEmpty){
                        return 'Please Enter Email';
                      }else{
                        return null;
                      }
                    },
                    onChanged: (value){
                      _enterEmail = value;
                    },
                    decoration: InputDecoration(
                        label:  ListTile(
                          leading: const Icon(Icons.email),
                          title: Text('Enter Email',
                            style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color:  Colors.grey
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              style: BorderStyle.none,
                              width: 0,
                              color: Colors.transparent
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent
                            )
                        )
                    ),

                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: PhysicalModel(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  elevation: 10,
                  shadowColor: Colors.grey.shade200,
                  child: TextFormField(
                    obscureText: _obscureText,
                    validator: (v){
                      if(v!.isEmpty){
                        return 'Please Enter password';
                      }else{
                        return null;
                      }
                    },
                    onChanged: (value){
                      _enterPassword = value;
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: (){
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: _obscureText ? const Icon(Icons.visibility)
                              :const Icon(Icons.visibility_off),
                        ),
                        label: Text('Enter Password',
                          style: GoogleFonts.epilogue(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey
                          ),
                        ),

                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              style: BorderStyle.none,
                              width: 0,
                              color: Colors.transparent
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent
                            )
                        )
                    ),

                  ),
                ),
              ),


              const SizedBox(
                height: 25,
              ),
              GestureDetector(
                onTap: (){
                  signUp();
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width*0.8,
                  decoration:  BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                          colors: [
                            Color(0xff0038F5),
                            Color(0xff9F03FF)
                          ])
                  ),
                  child: Center(
                    child: _wait ? const CircularProgressIndicator(color: Colors.white,):Text('Sign In',
                      style: GoogleFonts.epilogue(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Don\'t have an account?',
                      style: GoogleFonts.epilogue(
                          color: Colors.grey,
                          fontSize: 14
                      ),
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return const UsersSignUpScreen();
                        }));
                      },
                      child: Text('SignUp',
                        style: GoogleFonts.epilogue(
                            color: Colors.purple,
                            fontSize: 14
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Want to be a merchant?',
                    style: GoogleFonts.epilogue(
                        color: Colors.grey,
                        fontSize: 14
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return const CreatorLoginScreen();
                      }));
                    },
                    child: Text('Switch',
                      style: GoogleFonts.epilogue(
                          color: Colors.purple,
                          fontSize: 14
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
