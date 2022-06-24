import 'package:flutter/material.dart';


typedef OnCellClick = void Function(BuildContext context, int cellNumber, dynamic cellValue);
///============================================================================================
class DaysCalendar extends StatefulWidget {
  final int firstDay;
  final int lastDay;
  final int cellCount;
  final TableBorder? tableBorder;
  final OnCellClick? cellClick;
  final Color? cellColor;
  final Color? selectedCellColor;
  final Color? cellTextColor;
  final Color? selectedCellTextColor;
  final List<int>? selectedCells;
  final Map<int, dynamic>? cellValues;

  DaysCalendar({
    this.firstDay = 1,
    this.lastDay = 30,
    this.cellCount = 7,
    this.tableBorder,
    this.cellClick,
    this.selectedCells,
    this.cellColor,
    this.cellTextColor,
    this.selectedCellColor,
    this.selectedCellTextColor,
    this.cellValues,
    Key? key,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DaysCalendarState();
  }
}
///=============================================================================================
class DaysCalendarState extends State<DaysCalendar> {
  late int cellCount;
  late TableBorder tableBorder;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    cellCount = widget.cellCount;
    tableBorder = widget.tableBorder?? TableBorder.all(color: Colors.white, width: 1);

    return LayoutBuilder(
      builder: (ctx, w){
        //var media = MediaQuery.of(context);
        var wid = w.maxWidth - cellCount;
        var colWidth = FixedColumnWidth(wid/cellCount); //MinColumnWidth

        return Table(
          defaultColumnWidth: colWidth,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          textDirection: TextDirection.ltr,
          border: tableBorder,
          children: [
            ...generateTiles(colWidth),
          ],
        );
      },
    );
  }

  List<TableRow> generateTiles(FixedColumnWidth columnWidth){
    double height = columnWidth.value;
    List<TableRow> res = [];

    int all = widget.lastDay - widget.firstDay;
    all++;
    int rowCount = (all / cellCount).ceil();
    int currentCell = widget.firstDay;

    for(int i =0; i< rowCount; i++) {
      TableRow row = TableRow(
          children: [
            ...generateCells(all, currentCell, i, height),
          ]
      );

      res.add(row);
      currentCell += cellCount;
    }

    return res;
  }

  List<Widget> generateCells(int all, int current, int rowNum, double height){
    List<Widget> res = [];
    int c = 0;
    bool isSelected;
    Color backColor;
    Color textColor;

    while(c < cellCount){
      isSelected = widget.selectedCells?.contains(current)?? false;
      backColor = isSelected?
        widget.selectedCellColor?? theme.colorScheme.secondary : widget.cellColor?? theme.primaryColor;

      textColor = isSelected?
        widget.selectedCellTextColor?? Colors.white : widget.cellTextColor?? Colors.white;

      Widget w = _Cell(
          height: height,
          cellIndex: current,
          backColor: backColor,
          cellNumber: '${(current > all)? '': current}',
          cellValue: widget.cellValues?[current],
          cellNumberStyle: TextStyle(fontWeight: FontWeight.w900, color: textColor),
          cellValueStyle: TextStyle(color: textColor),
          cellClick: widget.cellClick,
      );

      res.add(w);
      current++;
      c++;
    }

    return res;
  }
}
///===================================================================================================
class _Cell extends StatelessWidget {
  final double height;
  final int cellIndex;
  final Color backColor;
  final String? cellNumber;
  final dynamic cellValue;
  final TextStyle cellNumberStyle;
  final TextStyle cellValueStyle;
  final OnCellClick? cellClick;

  _Cell({
    Key? key,
    required this.height,
    required this.cellIndex,
    required this.backColor,
    this.cellNumber,
    this.cellValue,
    this.cellClick,
    required this.cellNumberStyle,
    required this.cellValueStyle,
  }) : super(key: key);

  /*@override
  State<StatefulWidget> createState() {
    return _CellState();
  }*/

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: GestureDetector(
        child: ColoredBox(
            color: backColor,
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(cellNumber?? '',
                        style: cellNumberStyle,)
                  ),
                  Text('${cellValue?? ''}',
                    style: cellValueStyle,
                    textAlign: TextAlign.left,
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.clip,),
                ],
              ),
            )
        ),
        onTap: (){
          cellClick?.call(context, cellIndex, cellValue);
        },
      ),
    );
  }
}
///===================================================================================================
/*
class _CellState extends State<_Cell> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: GestureDetector(
        child: ColoredBox(
            color: widget.backColor,
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text('${widget.cellNumber?? ''}',
                        style: widget.cellNumberStyle,)
                  ),
                  Text('${widget.cellValue?? ''}',
                    style: widget.cellValueStyle,
                  textAlign: TextAlign.left,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.clip,),
                ],
              ),
            )
        ),
        onTap: (){
          widget.cellClick?.call(context, widget.cellIndex, widget.cellValue);
        },
      ),
    );
  }
}*/
