import 'package:flutter/material.dart';


List<String> socialApps = ['com.whatsapp','com.google.android.youtube', 'com.instagram.android', 'com.twitter.android', 'com.facebook.katana', 'com.snapchat.android', 'com.tinder', 'com.linkedin.android', 'com.pinterest', 'com.reddit.frontpage', 'com.spotify.music' ];
Map<String,String> appIcons = {
  'com.whatsapp': 'assets/images/whatsapp_icon.png',
  'com.google.android.youtube': 'assets/images/youtube_icon.png',
  'com.instagram.android': 'assets/images/instagram_icon.png',
  'com.twitter.android': 'assets/images/twitter_icon.png',
  'com.facebook.katana': 'assets/images/facebook_icon.png',
  'com.snapchat.android': 'assets/images/snapchat_icon.png',
  'com.tinder': 'assets/images/tinder_icon.png',
  'com.linkedin.android': 'assets/images/linkedin_icon.png',
  'com.pinterest': 'assets/images/pinterest_icon.png',
  'com.reddit.frontpage': 'assets/images/reddit_icon.png',
  'com.spotify.music': 'assets/images/spotify_icon.png',
};
Map<String,String> appName = {
  'com.whatsapp': 'WhatsApp',
  'com.google.android.youtube': 'YouTube',
  'com.instagram.android': 'Instagram',
  'com.twitter.android': 'Twitter',
  'com.facebook.katana': 'Facebook',
  'com.snapchat.android': 'Snapchat',
  'com.tinder': 'Tinder',
  'com.linkedin.android': 'LinkedIn',
  'com.pinterest': 'Pinterest',
  'com.reddit.frontpage': 'Reddit',
  'com.spotify.music': 'Spotify',
};



class AppTile extends StatelessWidget  {
  final String packageName;
  final String text;
  const AppTile({Key? key, required this.packageName, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
                   leading: Image.asset(appIcons[packageName] ?? 'assets/images/app.png'),
            title: Text(appName[packageName] ?? 'Unknown'),
            subtitle: Text(packageName),
            trailing: Text(text),
          );
  }
}