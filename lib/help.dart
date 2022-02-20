import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/expandable_fab.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help Center"),
      ),
      body: Center(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              children: [
                ExpansionTile(
                  title: AutoSizeText(
                    "National Eating Disorder Helpline",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            icon: Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch("tel: (800) 931-2237");
                            },
                          ),
                          ActionButton(
                            icon: Icon(
                              Icons.public,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch(
                                  "https://www.nationaleatingdisorders.org/help-support/contact-helpline");
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Contact the NEDA Helpline for support, resources,"
                        " and treatment options for yourself or a loved "
                        "one who is struggling with an eating disorder."
                        "\n\nPhone hours:\nMonday-Thursday 11am-9pm ET\nFriday 11am-5pm ET",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
                ExpansionTile(
                  title: AutoSizeText(
                    "The Trevor Project",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            icon: Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch("tel: 1-866-488-7386");
                            },
                          ),
                          ActionButton(
                            icon: Icon(
                              Icons.public,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch(
                                  "https://www.thetrevorproject.org/get-help-now/");
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "The Trevor Project is the leading national organization "
                        "providing 24/7 crisis intervention and suicide prevention "
                        "services to lesbian, gay, bisexual, transgender, queer "
                        "& questioning (LGBTQ) young people under 25.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
                ExpansionTile(
                  title: AutoSizeText(
                    "National Suicide Prevention Lifeline",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            icon: Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch("tel: (800) 273-8255");
                            },
                          ),
                          ActionButton(
                            icon: Icon(
                              Icons.public,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch(
                                  "https://suicidepreventionlifeline.org/talk-to-someone-now/");
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Support and asssitance 24/7 for anyone feeling depressed, overwhelmed or suicidal.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
                ExpansionTile(
                  title: AutoSizeText(
                    "National Sexual Assault Hotline",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            icon: Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch("tel: 800.656.HOPE");
                            },
                          ),
                          ActionButton(
                            icon: Icon(
                              Icons.public,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch(
                                  "https://www.rainn.org/about-national-sexual-assault-telephone-hotline");
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Nationwide referrals for specialized counseling and support groups."
                        " Hotline (1.800.656.4673) routes calls to local sex assault crisis"
                        " centers for resources and referrals. Spanish available.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
                ExpansionTile(
                  title: AutoSizeText(
                    "National Domestic Violence Hotline",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            icon: Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch("tel: 1.800.799.SAFE");
                            },
                          ),
                          ActionButton(
                            icon: Icon(
                              Icons.public,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch("https://www.thehotline.org/get-help/");
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "National call center refers to local resources; Spanish plus 160 other languages available; no caller ID used.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
                ExpansionTile(
                  title: AutoSizeText(
                    "National Substance Abuse Hotline",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            icon: Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch("tel:  1-800-662-HELP");
                            },
                          ),
                          ActionButton(
                            icon: Icon(
                              Icons.public,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launch("https://www.samhsa.gov/find-help/national-helpline");
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "SAMHSA’s National Helpline is a free, confidential, 24/7, 365-day-a-year treatment referral "
                            "and information service (in English and Spanish) for individuals and "
                            "families facing mental and/or substance use disorders.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ],
            )
            /*Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "National Eating Disorder Helpline",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://www.nationaleatingdisorders.org/help-support/contact-helpline");
                        },
                    ),
                    TextSpan(
                      text: "The National Eating Disorder Association (NEDA) runs a free,"
                          " confidential hotline available Monday–Thursday, 9:00 am EST – 9:00 pm EST and Friday, 9:00 am EST– 5:00 pm EST."
                          " Refer to their website for a list of holidays when the hotline is not available."
                          " NEDA also provides instant messaging and texting options.",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://www.nationaleatingdisorders.org/help-support/contact-helpline");
                        },
                    ),
                    TextSpan(
                      text: "The National Eating Disorder Association (NEDA) runs a free,"
                          " confidential hotline available Monday–Thursday, 9:00 am EST – 9:00 pm EST and Friday, 9:00 am EST– 5:00 pm EST."
                          " Refer to their website for a list of holidays when the hotline is not available."
                          " NEDA also provides instant messaging and texting options.",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://www.nationaleatingdisorders.org/help-support/contact-helpline");
                        },
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "The Trevor Project",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://www.thetrevorproject.org/get-help-now/");
                        },
                    ),
                    TextSpan(
                      text:
                          "\nA national 24-hour, toll free confidential suicide hotline for LGBTQ youth. "
                          "If you are a young person in crisis, feeling suicidal, "
                          "or in need of a safe and judgment-free place to talk, "
                          "call ",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    TextSpan(
                        text: "1-866-488-7386",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            launch("tel: 1-866-488-7386");
                          }),
                    TextSpan(
                      text: " to connect with a trained counselor.",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "National Suicide Prevention Lifeline",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://suicidepreventionlifeline.org/talk-to-someone-now/");
                        },
                    ),
                    TextSpan(
                      text: "\nCall ",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://suicidepreventionlifeline.org/talk-to-someone-now/");
                        },
                    ),
                    TextSpan(
                      text: "1-800-273-TALK (8255)",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch("tel: 1-800-273-TALK");
                        },
                    ),
                    TextSpan(
                      text:
                          " for free and confidential support for people in distress, "
                          "prevention and crisis resources for you or your loved ones, and best practices for professionals.",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://suicidepreventionlifeline.org/talk-to-someone-now/");
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),*/
            ),
      ),
    );
  }
}
