/*

class ColorPicker extends StatefulWidget {
  @override
  _ColorPickerState createState() => _ColorPickerState();
}
///====================================================================================
class _ColorPickerState extends State<ColorPicker> {
  Color _themeColor = Colors.red;

  List<S2Choice<Color>> colors = S2Choice.listFrom<Color, Color>(
      source: Colors.primaries,
      value: (i, v) => v,
      title: (i, v) => null
  );

  ThemeData get theme => Theme.of(context);

  @override
  Widget build(BuildContext context) {
    return SmartSelect<Color>.single(
      title: 'Color',
      value: _themeColor,
      modalType: S2ModalType.popupDialog,
      modalHeader: false,
      choiceItems: colors,
      choiceLayout: S2ChoiceLayout.grid,

      onChange: (state) {
        setState(() => _themeColor = state.value);
        //ThemePatrol.of(context).setColor(_themeColor);
      },

      choiceGrid: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          crossAxisCount: 5
      ),

      choiceBuilder: (BuildContext context, S2Choice choice, String state) {
        return Card(
          color: choice.value,
          child: InkWell(
            onTap: () => choice.select(true),
            child: choice.selected
                ? Icon(
              Icons.check,
              color: Colors.white,
            )
                : Container(),
          ),
        );
      },

      tileBuilder: (context, state) {
        return IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: state.showModal
        );
      },
    );
  }
}*/
