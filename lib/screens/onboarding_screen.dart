import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key,}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    final h=MediaQuery.of(context).size.height;
    final w=MediaQuery.of(context).size.width;

    return Scaffold(
      body: SizedBox(
        height: h,
        width: w,
        child: Stack(
          children: [
            Positioned(
              top: 0,
                child: Container(
                  height: h*.79,
                  width: w,
                  decoration: BoxDecoration(
                    color: Color(0xFF90AF17),
                    image: DecorationImage(
                      image: AssetImage('assets/images/best_2020@2x.png')
                      )
                  ),
                )
                ),
                Center(
                  child: Image.asset('assets/images/image_19.png'),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: h*.243,
                    width: w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40),
                        topLeft: Radius.circular(40)
                      )
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: h*.032),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text ('Lets cook good food', style: TextStyle(
                              fontSize: w*.06, fontWeight: FontWeight.w600
                            ),),
                            SizedBox(height: h*.01),
                            const Text('Check out the app and start to cooking delicous meals!',
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300
                            ),),

                            SizedBox(height: h*.032,),
                            SizedBox(
                              width: w*.8,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF90AF17),
                                ),
                                onPressed: () => Navigator.pushNamed(context, '/login'), 
                                child: const Text('Get Started', style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold
                                ),)),
                            ),
                          ],
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