//Packages
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat.dart';
import '../models/chat_user.dart';

//Themes
import '../themes/app_theme.dart';

/// Switches between Arabic and English; the label names the other language.
class LanguagePill extends StatelessWidget {
  const LanguagePill({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Material(
      color: AppColors.surface,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => context.setLocale(Locale(isArabic ? 'en' : 'ar')),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, size: 16, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(
                context.tr('other_language'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Language switch and logout button: the actions of the Chats and Users tabs.
class AccountActions extends StatelessWidget {
  const AccountActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LanguagePill(),
        const SizedBox(width: 4),
        IconButton(
          tooltip: context.tr('logout'),
          // This icon does not turn around by itself in a right-to-left layout
          icon: Transform.flip(
            flipX: Directionality.of(context) == TextDirection.rtl,
            child: const Icon(Icons.logout, color: AppColors.primaryLight),
          ),
          onPressed: () {
            context.read<AuthenticationProvider>().logout();
          },
        ),
      ],
    );
  }
}

/// Centered icon, title and optional body and action: empty and error states.
class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryLight, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.muted,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centered spinner: the loading state of a list.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}

/// Text written by a user (a name or a message): read in its own direction.
/// It lines up with the screen, or with its own direction inside a bubble.
class ContentText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final bool alignWithContent;

  const ContentText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.alignWithContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isScreenRtl = Directionality.of(context) == TextDirection.rtl;
    final isTextRtl = Bidi.detectRtlDirectionality(text);
    return Text(
      text,
      textDirection: isTextRtl ? TextDirection.rtl : TextDirection.ltr,
      textAlign: (alignWithContent ? isTextRtl : isScreenRtl)
          ? TextAlign.right
          : TextAlign.left,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: style,
    );
  }
}

/// Short notice at the bottom of the screen, used for failures.
void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// The Arabic wording of the timeago package, with two corrections: a time
/// under a minute reads "moments ago" instead of a count of seconds (as the
/// English one does), and the plurals of day and month get their hamza back.
class ArabicTimeMessages extends timeago.ArMessages {
  @override
  String lessThanOneMinute(int seconds) => 'لحظات';

  @override
  String days(int days) => super.days(days).replaceFirst('ايام', 'أيام');

  @override
  String months(int months) => super.months(months).replaceFirst('اشهر', 'أشهر');
}

/// Makes relative times available in Arabic; English is built in. Called once at start-up.
void registerTimeAgoLocales() {
  timeago.setLocaleMessages('ar', ArabicTimeMessages());
}

/// How long ago [date] was, in the current language: "5 minutes ago".
String timeAgo(BuildContext context, DateTime date) {
  return timeago.format(date, locale: context.locale.languageCode);
}

/// Name of a user, or a stand-in when the profile has none.
String userName(BuildContext context, ChatUser user) {
  return user.name.trim().isEmpty ? context.tr('unknown_user') : user.name;
}

/// Title of a chat: the other member, or every other member of a group.
String chatTitle(BuildContext context, Chat chat) {
  final names = chat.recepients().map((user) => userName(context, user));
  if (names.isEmpty) {
    return context.tr('you');
  }
  return chat.group ? names.join(context.tr('list_separator')) : names.first;
}
