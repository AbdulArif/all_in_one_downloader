import 'package:all_in_one_downloader/main.dart';
import 'package:all_in_one_downloader/screens/home_page.dart';
import 'package:all_in_one_downloader/screens/facebook_page.dart';
import 'package:all_in_one_downloader/screens/instagram_page.dart';
import 'package:all_in_one_downloader/screens/youtube_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash screen shows brand and loading state', (tester) async {
    await tester.pumpWidget(const DownloaderApp());

    expect(find.text('Droply'), findsOneWidget);
    expect(find.text('Everything you love, saved in one tap.'), findsOneWidget);
    expect(find.text('GETTING THINGS READY'), findsOneWidget);
    expect(find.text('FAST  |  SIMPLE  |  SECURE'), findsOneWidget);
  });

  testWidgets('opens home page after two seconds', (tester) async {
    await tester.pumpWidget(const DownloaderApp());

    await tester.pump(const Duration(milliseconds: 2010));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('YouTube'), findsOneWidget);
    expect(find.text('LinkedIn'), findsOneWidget);
  });

  testWidgets('facebook tile opens facebook page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Facebook'));
    await tester.pumpAndSettle();

    expect(find.byType(FacebookPage), findsOneWidget);
    expect(find.text('Download from\nFacebook'), findsOneWidget);
    expect(find.byKey(const Key('facebook-link-field')), findsOneWidget);
  });

  testWidgets('instagram tile opens instagram page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Instagram'));
    await tester.pumpAndSettle();

    expect(find.byType(InstagramPage), findsOneWidget);
    expect(find.text('Download from\nInstagram'), findsOneWidget);
    expect(find.byKey(const Key('instagram-link-field')), findsOneWidget);
  });

  testWidgets('youtube tile opens youtube page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('YouTube'));
    await tester.pumpAndSettle();

    expect(find.byType(YouTubePage), findsOneWidget);
    expect(find.text('Download from\nYouTube'), findsOneWidget);
    expect(find.byKey(const Key('youtube-link-field')), findsOneWidget);
  });
}
