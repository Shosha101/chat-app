// Renders the real screens off-screen with sample users, chats and messages, in Arabic and English.
// Run: flutter test --update-goldens tool/screens_golden_test.dart  (PNGs land in tool/shots/)
//
// Firebase and Cloudinary cannot run in a widget test, so the pages get their data from
// the fakes below. Every name, message and picture here exists only in this file.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:chatify/models/chat.dart';
import 'package:chatify/models/chat_message.dart';
import 'package:chatify/models/chat_user.dart';
import 'package:chatify/pages/chat_page.dart';
import 'package:chatify/pages/home_page.dart';
import 'package:chatify/pages/login_page.dart';
import 'package:chatify/pages/register_page.dart';
import 'package:chatify/pages/splash_page.dart';
import 'package:chatify/providers/authentication_provider.dart';
import 'package:chatify/services/cloud_storage_services.dart';
import 'package:chatify/services/database_services.dart';
import 'package:chatify/services/media_services.dart';
import 'package:chatify/services/navigation_services.dart';
import 'package:chatify/themes/app_theme.dart';
import 'package:chatify/widgets/app_widgets.dart';
import 'package:chatify/widgets/rounded_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

/// Never contacted: [FakeHttpClient] answers every image request itself.
const imageHost = 'https://sample.invalid';
const myId = 'me';
const myName = {'ar': 'أحمد سمير', 'en': 'Ahmed Samir'};

class Person {
  const Person(this.id, this.ar, this.en, this.minutesSinceActive, this.colors);
  final String id;
  final String ar;
  final String en;
  final int minutesSinceActive;
  final List<Color> colors;

  String name(String lang) => lang == 'ar' ? ar : en;
  String get imageUrl => '$imageHost/avatars/$id.png';
}

const people = [
  Person('laila', 'ليلى حسن', 'Laila Hassan', 4, [Color(0xFFFF8A65), Color(0xFFD81B60)]),
  Person('omar', 'عمر خالد', 'Omar Khaled', 35, [Color(0xFF4DB6AC), Color(0xFF00695C)]),
  Person('sara', 'سارة محمود', 'Sara Mahmoud', 65, [Color(0xFFBA68C8), Color(0xFF5E35B1)]),
  Person('youssef', 'يوسف علي', 'Youssef Ali', 60 * 5, [Color(0xFFFFB74D), Color(0xFFE65100)]),
  Person('mariam', 'مريم إبراهيم', 'Mariam Ibrahim', 60 * 26, [Color(0xFF64B5F6), Color(0xFF283593)]),
  Person('karim', 'كريم عادل', 'Karim Adel', 60 * 24 * 3, [Color(0xFFAED581), Color(0xFF2E7D32)]),
];

class Line {
  const Line(this.sender, this.minutesAgo, {this.ar = '', this.en = '', this.photo});
  final String sender;
  final int minutesAgo;
  final String ar;
  final String en;
  // Path of a picture on [imageHost]; set for an image message
  final String? photo;
}

class Conversation {
  const Conversation(this.id, this.members, this.lines, {this.isTyping = false});
  final String id;
  final List<String> members;
  final List<Line> lines;
  final bool isTyping;
}

const trailPhoto = '/photos/trail.png';

const conversations = [
  Conversation('hike', ['laila'], [
    Line('laila', 26,
        ar: 'صباح الخير! هل ما زلنا على موعد رحلة الجمعة؟',
        en: 'Morning! Are we still on for the hike on Friday?'),
    Line(myId, 24,
        ar: 'أكيد. راجعت حالة الطقس والجو صافٍ طوال اليوم.',
        en: "Definitely. I checked the forecast and it's clear all day."),
    Line('laila', 21, photo: trailPhoto),
    Line('laila', 20, ar: 'هذا هو المسار الذي حدثتك عنه.', en: 'This is the trail I told you about.'),
    Line(myId, 9, ar: 'رائع! متى ننطلق؟', en: 'Looks great! What time do we leave?'),
    Line('laila', 4, ar: 'الساعة 6 صباحًا، قبل أن يشتد الحر.', en: '6 am, before it gets hot.'),
  ]),
  Conversation('team', ['omar', 'sara', 'youssef'], isTyping: true, [
    Line('omar', 41, ar: 'من سيحضر اجتماع الفريق غدًا؟', en: "Who's joining the team meeting tomorrow?"),
    Line('sara', 38,
        ar: 'أنا سأحضر، وسأجهّز عرض التصميم الجديد.',
        en: "I'm in, and I'll bring the new design deck."),
    Line(myId, 36, ar: 'وأنا كذلك. هل نبدأ الساعة 10؟', en: 'Me too. Shall we start at 10?'),
    Line('youssef', 30, ar: 'الساعة 10 مناسبة لي.', en: '10 works for me.'),
    Line('omar', 12, ar: 'ممتاز، سأرسل الدعوة الآن.', en: "Great, I'll send the invite now."),
  ]),
  Conversation('sara', ['sara'], [
    Line('sara', 65, photo: trailPhoto),
  ]),
  Conversation('youssef', ['youssef'], [
    Line(myId, 60 * 5, ar: 'شكرًا على مساعدتك اليوم!', en: 'Thanks for your help today!'),
  ]),
  Conversation('mariam', ['mariam'], [
    Line('mariam', 60 * 26,
        ar: 'أرسلت لك الملف، راجعه عندما تستطيع.',
        en: 'I sent you the file, have a look when you can.'),
  ]),
  // Opened on its own to show a chat nobody has written in yet
  Conversation('karim', ['karim'], []),
];

/// A name no sample user has, typed into the search to show its empty state.
const missingName = {'ar': 'نور', 'en': 'Nour'};

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// The signed-in user, without Firebase Auth behind it.
class FakeAuth extends ChangeNotifier implements AuthenticationProvider {
  FakeAuth(this.user);

  @override
  ChatUser user;
  @override
  String? errorKey;

  @override
  Future<void> loginUsingEmailAndPassword(String email, String password) async {}
  @override
  Future<String?> registerUserUsingEmailAndPassword(String email, String password) async => null;
  @override
  Future<void> deleteCurrentUser() async {}
  @override
  Future<void> logout() async {}
}

// ignore: subtype_of_sealed_class
class FakeDocument extends Fake implements QueryDocumentSnapshot<Object?> {
  FakeDocument(this.id, this.fields);

  @override
  final String id;
  final Map<String, dynamic>? fields;

  @override
  bool get exists => fields != null;
  // A copy, because the providers add the document id to the map they get
  @override
  Map<String, dynamic> data() => Map<String, dynamic>.of(fields!);
}

class FakeQuery extends Fake implements QuerySnapshot<Object?> {
  FakeQuery(this.docs);

  @override
  final List<QueryDocumentSnapshot<Object?>> docs;
}

/// Answers the app's Firestore reads from the sample data, shaped like the real documents.
class FakeDatabase implements DatabaseService {
  FakeDatabase(this.lang, {this.withChats = true});

  final String lang;
  final bool withChats;
  final DateTime now = DateTime.now();

  Timestamp _minutesAgo(int minutes) => Timestamp.fromDate(now.subtract(Duration(minutes: minutes)));

  Map<String, dynamic> _user(String uid) {
    if (uid == myId) {
      return {'name': myName[lang], 'email': 'ahmed@example.com', 'image': '', 'last_active': _minutesAgo(0)};
    }
    final person = people.firstWhere((p) => p.id == uid);
    return {
      'name': person.name(lang),
      'email': '${person.id}@example.com',
      'image': person.imageUrl,
      'last_active': _minutesAgo(person.minutesSinceActive),
    };
  }

  FakeDocument _message(Line line) {
    return FakeDocument('${line.sender}-${line.minutesAgo}', {
      'sender_id': line.sender,
      'type': line.photo == null ? 'text' : 'image',
      'content': line.photo == null ? (lang == 'ar' ? line.ar : line.en) : '$imageHost${line.photo}',
      'sent_time': _minutesAgo(line.minutesAgo),
    });
  }

  @override
  Future<DocumentSnapshot> getUser(String uid) async => FakeDocument(uid, _user(uid));

  @override
  Future<QuerySnapshot> getUsers({String? name}) async {
    return FakeQuery([
      for (final uid in [myId, ...people.map((p) => p.id)])
        if (name == null || name.isEmpty || '${_user(uid)['name']}'.startsWith(name)) FakeDocument(uid, _user(uid)),
    ]);
  }

  @override
  Stream<QuerySnapshot> getChatsForUser(String uid) {
    return Stream.value(FakeQuery([
      if (withChats)
        for (final chat in conversations.where((c) => c.lines.isNotEmpty))
          FakeDocument(chat.id, {
            'members': [...chat.members, myId],
            'is_group': chat.members.length > 1,
            'is_activity': chat.isTyping,
          }),
    ]));
  }

  @override
  Future<QuerySnapshot> getLastMessageForChat(String chatID) async {
    return FakeQuery([_message(conversations.firstWhere((c) => c.id == chatID).lines.last)]);
  }

  @override
  Stream<QuerySnapshot> streamMessagesForChat(String chatID) {
    final chat = conversations.firstWhere((c) => c.id == chatID);
    return Stream.value(FakeQuery([for (final line in chat.lines) _message(line)]));
  }

  @override
  Future<void> createUser(String uid, String email, String name, String imageURL) async {}
  @override
  Future<void> addMessageToChat(String chatID, ChatMessage message) async {}
  @override
  Future<void> updateChatData(String chatID, Map<String, dynamic> data) async {}
  @override
  Future<void> updateUserLastSeenTime(String uid) async {}
  @override
  Future<void> deleteChat(String chatID) async {}
  @override
  Future<DocumentReference?> createChat(Map<String, dynamic> data) async => null;
}

class FakeStorage extends Fake implements CloudStorageService {}

/// "Picks" the same picture from disk every time.
class FakeMedia implements MediaService {
  FakeMedia(this.file);
  final File file;

  @override
  Future<PlatformFile?> pickImageFromLibrary() async {
    return PlatformFile(name: 'photo.png', path: file.path, size: file.lengthSync());
  }
}

/// Serves the generated pictures to `NetworkImage`, so nothing leaves the machine.
class FakeHttpClient extends Fake implements HttpClient {
  FakeHttpClient(this.pictures);
  final Map<String, Uint8List> pictures;

  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => FakeRequest(pictures[url.path]);
}

class FakeRequest extends Fake implements HttpClientRequest {
  FakeRequest(this.bytes);
  final Uint8List? bytes;

  @override
  Future<HttpClientResponse> close() async => FakeResponse(bytes);
}

class FakeResponse extends Fake implements HttpClientResponse {
  FakeResponse(this.bytes);
  final Uint8List? bytes;

  @override
  int get statusCode => bytes == null ? HttpStatus.notFound : HttpStatus.ok;
  @override
  int get contentLength => bytes?.length ?? 0;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(bytes ?? Uint8List(0))
        .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

// ---------------------------------------------------------------------------
// Generated pictures
// ---------------------------------------------------------------------------

Future<Uint8List> paint(int width, int height, void Function(Canvas canvas, Size size) draw) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder), Size(width.toDouble(), height.toDouble()));
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

/// A profile picture: a head and shoulders on a two-colour gradient.
void drawAvatar(Canvas canvas, Size size, List<Color> colors) {
  final rect = Offset.zero & size;
  canvas.drawRect(rect, Paint()..shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight, colors));
  final figure = Paint()..color = const Color(0xE6FFFFFF);
  canvas.drawCircle(Offset(size.width / 2, size.height * 0.40), size.width * 0.18, figure);
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 1.04),
      width: size.width * 0.74,
      height: size.height * 0.68,
    ),
    figure,
  );
}

/// The photo sent in the sample chat: a trail between hills at sunrise.
void drawTrail(Canvas canvas, Size size) {
  final rect = Offset.zero & size;
  final w = size.width, h = size.height;
  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.linear(
        rect.topCenter,
        rect.bottomCenter,
        const [Color(0xFF27357E), Color(0xFFE8794F), Color(0xFFF8D06B)],
        const [0, 0.5, 0.72],
      ),
  );
  canvas.drawCircle(Offset(w * 0.70, h * 0.50), w * 0.07, Paint()..color = const Color(0xFFFFF4CC));

  void hill(double top, double wave, Color color, {required bool startsUp}) {
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * top);
    const bumps = 3;
    for (var i = 0; i < bumps; i++) {
      final up = (i.isEven == startsUp ? -1 : 1) * wave * h;
      path.quadraticBezierTo(w * (i + 0.5) / bumps, h * top + up, w * (i + 1) / bumps, h * top);
    }
    path
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  hill(0.56, 0.16, const Color(0xFF6C4A7E), startsUp: true);
  hill(0.68, 0.14, const Color(0xFF3F3A6B), startsUp: false);
  hill(0.80, 0.10, const Color(0xFF23284F), startsUp: true);

  final trail = Path()
    ..moveTo(w * 0.36, h)
    ..quadraticBezierTo(w * 0.50, h * 0.90, w * 0.43, h * 0.83)
    ..quadraticBezierTo(w * 0.39, h * 0.79, w * 0.46, h * 0.765)
    ..lineTo(w * 0.48, h * 0.765)
    ..quadraticBezierTo(w * 0.44, h * 0.80, w * 0.52, h * 0.84)
    ..quadraticBezierTo(w * 0.64, h * 0.91, w * 0.60, h)
    ..close();
  canvas.drawPath(trail, Paint()..color = const Color(0xFFD9B38C));
}

// ---------------------------------------------------------------------------
// Test harness
// ---------------------------------------------------------------------------

Future<void> loadFonts() async {
  Future<ByteData> file(String path) async => ByteData.view((await File(path).readAsBytes()).buffer);
  final plex = FontLoader(AppTheme.fontFamily);
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    plex.addFont(file('assets/fonts/IBMPlexSansArabic-$weight.ttf'));
  }
  await plex.load();
  final sdk = File(Platform.resolvedExecutable).parent.parent.parent.parent.path;
  await (FontLoader('MaterialIcons')..addFont(file('$sdk/artifacts/material_fonts/materialicons-regular.otf'))).load();
}

void main() {
  final pictures = <String, Uint8List>{};
  late Directory tempDir;
  late File pickedPhoto;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    registerTimeAgoLocales();
    await loadFonts();
    // The asset bundle keeps the first load of a text file for good. Doing it here, on
    // real time, keeps a later test from waiting on a load an earlier test's clock owned.
    for (final lang in ['ar', 'en']) {
      await rootBundle.loadString('assets/translations/$lang.json');
    }

    // The chat page listens to the keyboard through a plugin that has no test implementation
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_keyboard_visibility'),
      (call) async => null,
    );

    for (final person in people) {
      pictures['/avatars/${person.id}.png'] = await paint(256, 256, (c, s) => drawAvatar(c, s, person.colors));
    }
    pictures[trailPhoto] = await paint(800, 600, drawTrail);

    // The register page reads its picked image from a file
    tempDir = await Directory.systemTemp.createTemp('chatify_shots');
    pickedPhoto = File('${tempDir.path}/photo.png');
    await pickedPhoto.writeAsBytes(
      await paint(256, 256, (c, s) => drawAvatar(c, s, const [Color(0xFF4FC3F7), Color(0xFF0A5BD9)])),
    );
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = const FakeViewPadding(top: 88);
    tester.view.viewPadding = const FakeViewPadding(top: 88);
    addTearDown(tester.view.reset);
  }

  Widget localized(String lang, Widget child) {
    return EasyLocalization(
      key: UniqueKey(),
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(lang),
      saveLocale: false,
      ignorePluralRules: false,
      child: child,
    );
  }

  // Pictures and files load in real time, which a widget test only lets pass inside
  // runAsync; the pumps in between let the widgets pick up what has arrived.
  Future<void> settle(
    WidgetTester tester, {
    int rounds = 6,
    Duration step = const Duration(milliseconds: 150),
  }) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
      await tester.pump(step);
    }
  }

  // Registers the fakes in place of the app's services and shows [home] inside the
  // app's own wrappers: translations, the signed-in user and the theme.
  Future<void> pumpApp(WidgetTester tester, String lang, Widget home, {bool withChats = true}) async {
    usePhone(tester);

    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<NavigationService>(NavigationService());
    getIt.registerSingleton<MediaService>(FakeMedia(pickedPhoto));
    getIt.registerSingleton<CloudStorageService>(FakeStorage());
    getIt.registerSingleton<DatabaseService>(FakeDatabase(lang, withChats: withChats));

    final me = ChatUser(
      uid: myId,
      name: myName[lang]!,
      email: 'ahmed@example.com',
      imageURL: '',
      lastActive: DateTime.now(),
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(
        localized(
          lang,
          ChangeNotifierProvider<AuthenticationProvider>.value(
            value: FakeAuth(me),
            child: Builder(
              builder: (context) => MaterialApp(
                navigatorKey: NavigationService.navigatorKey,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.darkTheme,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: home,
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await settle(tester);
  }

  /// The chat as the chats list would hand it to the chat page.
  Chat sampleChat(String lang, String id) {
    final database = FakeDatabase(lang);
    final conversation = conversations.firstWhere((c) => c.id == id);
    return Chat(
      uid: id,
      currentUserUid: myId,
      members: [
        for (final uid in [...conversation.members, myId])
          ChatUser.fromJSON({...database._user(uid), 'uid': uid}),
      ],
      messages: [],
      activity: conversation.isTyping,
      group: conversation.members.length > 1,
    );
  }

  Future<void> openUsersTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.people_outline));
    await settle(tester);
  }

  Future<void> shot(String name) async {
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/$name.png'));
  }

  // Shadows and the picture server are debug switches the test framework wants back
  // in their default state when a test ends.
  void shotTest(String description, Future<void> Function(WidgetTester tester) body) {
    testWidgets(description, (tester) async {
      debugDisableShadows = false;
      debugNetworkImageHttpClientProvider = () => FakeHttpClient(pictures);
      try {
        await body(tester);
      } finally {
        debugDisableShadows = true;
        debugNetworkImageHttpClientProvider = null;
      }
    });
  }

  // Shows the splash page and returns once its start-up has failed: the page waits a
  // second and then asks for Firebase, which is not there in a test. The page is
  // pumped outside runAsync, so that second passes on the test's own clock.
  Future<void> pumpSplash(WidgetTester tester, String lang, {Future<void> Function()? whileLoading}) async {
    usePhone(tester);
    await GetIt.instance.reset();
    await tester.pumpWidget(localized(lang, SplashPage(key: UniqueKey(), onInitializationComplete: () {})));
    // Short steps: together they stay inside the page's one-second wait
    await settle(tester, rounds: 12, step: const Duration(milliseconds: 40));
    await whileLoading?.call();
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
  }

  shotTest('splash', (tester) async {
    await pumpSplash(tester, 'ar', whileLoading: () => shot('00-splash'));
  });

  for (final lang in ['ar', 'en']) {
    shotTest('$lang login', (tester) async {
      await pumpApp(tester, lang, const LoginPage());
      await shot('$lang-01-login');
    });

    shotTest('$lang register', (tester) async {
      await pumpApp(tester, lang, const RegisterPage());
      await tester.tap(find.byType(RoundedImageNetwork));
      await settle(tester);
      await tester.enterText(find.byType(TextFormField).at(0), myName[lang]!);
      await tester.enterText(find.byType(TextFormField).at(1), 'ahmed@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'not-a-real-password');
      FocusManager.instance.primaryFocus?.unfocus();
      await settle(tester);
      await shot('$lang-02-register');
    });

    shotTest('$lang chats', (tester) async {
      await pumpApp(tester, lang, const HomePage());
      await shot('$lang-03-chats');
    });

    shotTest('$lang chat', (tester) async {
      await pumpApp(tester, lang, ChatPage(chat: sampleChat(lang, 'hike')));
      await shot('$lang-04-chat');
    });

    shotTest('$lang group chat', (tester) async {
      await pumpApp(tester, lang, ChatPage(chat: sampleChat(lang, 'team')));
      await shot('$lang-05-group-chat');
    });

    shotTest('$lang users with two selected', (tester) async {
      await pumpApp(tester, lang, const HomePage());
      await openUsersTab(tester);
      await tester.tap(find.text(people[1].name(lang)));
      await tester.tap(find.text(people[2].name(lang)));
      await settle(tester);
      await shot('$lang-06-users');
    });

    shotTest('$lang no chats', (tester) async {
      await pumpApp(tester, lang, const HomePage(), withChats: false);
      await shot('$lang-07-chats-empty');
    });

    shotTest('$lang no users found', (tester) async {
      await pumpApp(tester, lang, const HomePage());
      await openUsersTab(tester);
      await tester.enterText(find.byType(TextField), missingName[lang]!);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);
      await shot('$lang-08-users-empty');
    });

    shotTest('$lang empty chat', (tester) async {
      await pumpApp(tester, lang, ChatPage(chat: sampleChat(lang, 'karim')));
      await shot('$lang-09-chat-empty');
    });

    shotTest('$lang start-up error', (tester) async {
      await pumpSplash(tester, lang);
      await shot('$lang-10-startup-error');
    });
  }
}
