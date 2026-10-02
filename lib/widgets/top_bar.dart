import 'package:flutter/material.dart';

//Widgets
import '../widgets/app_widgets.dart';

//Themes
import '../themes/app_theme.dart';

class TopBar extends StatelessWidget {
  final String _barTitle;
  // Smaller line under the title
  final String? subtitle;
  // Sits at the end of the bar
  final Widget? primaryAction;
  // Sits at the start of the bar, before the title
  final Widget? secondryAction;
  // Shown between the start action and the title
  final Widget? avatar;
  final double fontSize;

  const TopBar(this._barTitle,
      {super.key,
      this.subtitle,
      this.primaryAction,
      this.secondryAction,
      this.avatar,
      this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (secondryAction != null) secondryAction!,
          if (avatar != null) ...[
            avatar!,
            const SizedBox(width: 12),
          ],
          Expanded(child: _titleBar()),
          if (primaryAction != null) ...[
            const SizedBox(width: 8),
            primaryAction!,
          ],
        ],
      ),
    );
  }

  Widget _titleBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContentText(
          _barTitle,
          maxLines: 1,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: AppColors.text,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.muted,
            ),
          ),
      ],
    );
  }
}
