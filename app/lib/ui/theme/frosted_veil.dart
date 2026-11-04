import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'surfaces.dart';

/// 顶部 / 底部的磨砂浮层：把背后滚动的内容糊掉，再叠一层由上到下渐隐的轻底色。
///
/// 和 [BackdropVeil] 不同，它不重画页面背景（那会把内容整个盖住），只做模糊，
/// 所以滚动到栏下的消息会隐约透出来 —— 读得出「玻璃浮在内容上」。
class FrostedVeil extends StatelessWidget {
  const FrostedVeil({
    super.key,
    required this.height,
    this.feather = 18,
    this.fromTop = true,
    this.sigma = 14,
  });

  final double height;
  final double feather;
  final bool fromTop;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    final s = DshSurfaces.of(context);
    final tint = s.chrome.fill;
    final clear = tint.withValues(alpha: 0);
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: ui.TileMode.clamp),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
                  end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
                  colors: [tint, clear],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
