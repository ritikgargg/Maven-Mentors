import 'package:flutter/material.dart';

import '../user_type.dart';
import './login_page.dart';

class UserSelect extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
              child: Align(
          alignment: Alignment.center,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: deviceSize.height*0.25,),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      width: deviceSize.width * 0.25,
                      height: deviceSize.width * 0.25,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/logomini.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: deviceSize.height*0.25,),
                  SizedBox(
                    width: deviceSize.width*0.8,
                                    child: MaterialButton(
                      height: 50,
                      child: Text(
                        'MENTOR',
                        style: TextStyle(color: Colors.white,fontFamily: "Josefin Sans"),
                      ),
                      onPressed: () {
                        UserTypeInfo.instance.userType=UserType.Mentor;
                        Navigator.of(context).push(MaterialPageRoute(builder: (_)=> LoginPage()));
                        
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 15 ,),

                  SizedBox(
                    width: deviceSize.width*0.8,
                                    child: MaterialButton(
                      height: 50,
                      color: Colors.white,
                      child: Text(
                        'MENTEE',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: "Josefin Sans"
                        ),
                      ),
                      onPressed: () {
                        UserTypeInfo.instance.userType=UserType.Mentee;
                        Navigator.of(context).push(MaterialPageRoute(builder: (_)=> LoginPage()));
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(color: Colors.white)),
                    ),
                  ),
                ]),
          
        ),
      ),
    );
  }
}
