import 'package:flutter/material.dart';
import 'package:iris_tools/modules/propertyNotifier/propertyChangeNotifier.dart';

typedef PropertyChangeBuilder<Mo, S> = Widget Function(BuildContext, Mo?, S?);
///===============================================================================
class PropertyChangeConsumer<Mo extends PropertyChangeNotifier<S>, S> extends StatefulWidget {
  final Mo? model;
  final Iterable<S>? properties;
  late final bool onAnyInstance;
  final PropertyChangeBuilder<Mo, S> builder;

  PropertyChangeConsumer({
    Key? key,
    this.model,
    this.properties,
    this.onAnyInstance = false,
    required this.builder,
  })  : super(key: key);

  @override
  PropertyChangeConsumerState<Mo, S> createState() => PropertyChangeConsumerState();
}
///=================================================================================
class PropertyChangeConsumerState<Mo extends PropertyChangeNotifier<Pro>, Pro> extends State<PropertyChangeConsumer<Mo,Pro>>{
  Pro? currentProperty;

  @override
  void initState() {
    super.initState();

    final handler =  PropertyNotifierHandler<Pro>();
    handler.onAnyInstance = widget.onAnyInstance;
    handler.modelType = Mo;

    if(widget.properties == null || widget.properties!.isEmpty){
      handler.onAnyProperty = true;
    }
    else {
      handler.properties.addAll(widget.properties!);
    }

    widget.model?.addListener(listener, handler);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.model, currentProperty);
  }

  @override
  void dispose() {
    widget.model?.removeListener(listener, widget.properties);

    super.dispose();
  }

  void listener(dynamic property){
    currentProperty = property;

    if(mounted) {
      setState(() {});
    }
  }
}