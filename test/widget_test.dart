import 'package:all_in_one_downloader/main.dart';
import 'package:all_in_one_downloader/screens/home_page.dart';
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
}
