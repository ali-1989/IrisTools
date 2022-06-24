import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/attribute.dart';
import 'package:iris_tools/widgets/icon/circularIcon.dart';

class OutsideButton extends StatefulWidget {
  final TextDirection? textDirection;
  final Color backColor;
  final Color splashColor;
  final Widget child;
  final void Function() onCloseTap;

  const OutsideButton({
    Key? key,
    required this.child,
    required this.onCloseTap,
    required this.splashColor,
    this.textDirection = TextDirection.ltr,
    this.backColor = Colors.transparent,
    })
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OutsideButtonState();
  }
}
///===============================================================================================
class OutsideButtonState extends State<OutsideButton>{
  AttributeController panelCloseAtt = AttributeController();

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (pse) {
        bool isXMatch = pse.position.dx >= panelCloseAtt.getPositionX()! && pse.position.dx < (panelCloseAtt.getPositionX()! + panelCloseAtt.getWidth()!);
        bool isYMatch = pse.position.dy >= panelCloseAtt.getPositionY()! && pse.position.dy < (panelCloseAtt.getPositionY()! + panelCloseAtt.getHeight()!);
        if (isXMatch && isYMatch) {
          InkWell? child = panelCloseAtt.findChild<InkWell>();

          if (child != null) {
            child.onTap?.call();
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Stack(
          textDirection: widget.textDirection,
          children: [
            ColoredBox(
              color: widget.backColor,
              child: widget.child,
            ),

            SizedBox( // for centering
              height: 0,
              child: OverflowBox(
                minHeight: 60,
                maxHeight: 60,
                child: Attribute(
                  controller: panelCloseAtt,
                  child: Material(
                    color: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    type: MaterialType.circle,
                    borderOnForeground: true,
                    elevation: 0,
                    child: InkWell(
                      splashColor: widget.splashColor,
                      canRequestFocus: true,
                      autofocus: true,
                      onTap: (){
                        Future.delayed(Duration(milliseconds: 150), (){widget.onCloseTap.call();});
                      },
                      child: CircularIcon(
                        icon: Icons.close,
                        size: 36,
                        itemColor: Colors.black,
                        backColor: Colors.white,
                      ),
                    ),
                  )/*.wrapMaterial(
                      onCloseTap: () {
                    widget.onCloseTap.call();
                  })*/,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}