import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../themes/color_schemes.dart';

class ChatBotAvatar extends StatelessWidget {
  const ChatBotAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary,
      child: SvgPicture.asset('assets/images/chatbot.svg'),
    );
  }
}
