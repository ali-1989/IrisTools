import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


class Sticky extends StatefulWidget {
  final String? title;

  const Sticky({Key? key, this.title}) : super(key: key);

  @override
  State createState() => _StickyState();
}
///==============================================================================
class _StickyState extends State<Sticky> {
  final controller = ScrollController();
  GlobalKey stickyKey = GlobalKey();
  late OverlayEntry stickyEntry;

  @override
  void initState() {
    super.initState();

    stickyEntry = OverlayEntry(
      builder: (context) => stickyBuilder(),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context)!.insert(stickyEntry);
    });
  }

  @override
  void dispose() {
    stickyEntry.remove();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: controller,
        itemCount: 50,
        itemBuilder: (context, index) {
          if (index == 6) {
            return Container(
              key: stickyKey,
              height: 50.0,
              color: Colors.green,
              child: const Text(" I'm anchor"),
            );
          }

          return ListTile(
            title: Text(
              'Hello $index',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget stickyBuilder() {
    return AnimatedBuilder(
      animation: controller,
      builder: (ctx, child) {
        final keyContext = stickyKey.currentContext;

        if (keyContext != null) {
          final box = keyContext.findRenderObject() as RenderBox;
          final pos = box.localToGlobal(Offset.zero);
          return Positioned(
            top: pos.dy + box.size.height - 10,
            left: pos.dx + 5.0,
            right: 50.0,
            height: box.size.height,
            child: Material(
              child: Container(
                alignment: Alignment.center,
                color: Colors.purple,
                child: const Text(" I think you're okay"),
              ),
            ),
          );
        }

        return SizedBox();
      },
    );
  }
}