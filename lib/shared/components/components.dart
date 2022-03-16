import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blueAccent,
  String text = '',
  bool isUpperCase = true,
  required Function function,
}) =>
    Container(
      width: width,
      color: background,
      child: MaterialButton(
        onPressed: function(),
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );

Widget defaultFormField({
  required TextInputType inputType,
  required String text,
  IconData? icon,
  required TextEditingController controller,
  Function? onSubmit,
  Function? onTap,
  //Function? onChange,
  final String? Function(String? val)? validate,
  bool isClickable = true,
}) =>
    TextFormField(
      enabled: isClickable,
      controller: controller,
      keyboardType: inputType,
      onFieldSubmitted: (s) {
        onSubmit!(s);
      },
      /*onChanged: (s){onChange!();},*/
      onTap: () {
        onTap!();
      },
      validator: validate,
      decoration: InputDecoration(
        labelText: text,
        prefix: Padding(
          padding: const EdgeInsets.only(right: 5.0,top: 5.0),
          child: Icon(
            icon,
            color: Colors.blueAccent,
            size: 15,
          ),
        ),
      ),
    );

SnackBar showSnackBar(
    context,
    String? state,
    Map? model,
    String? text,
    String? label,) {
  SnackBar snackBar = SnackBar(
    content: Text('$text'),
    action: SnackBarAction(
      label: '$label',
      onPressed: () {
        AppCubit.get(context).updateData(state: '$state', id: model!['id']);
      },
    ),
  );
  return snackBar;
}

Widget defaultTaskItem(
        IconData? doneIcon,
        Color? doneColor,
        IconData? archiveIcon,
        Color? archiveColor,
        SnackBar? snackBar,
        Map? model,
        double? width,
        int index,
        context) =>
    AnimationConfiguration.staggeredList(
      position: index,
      delay: const Duration(milliseconds: 100),
      child: SlideAnimation(
        duration: const Duration(milliseconds: 2500),
        curve: Curves.fastLinearToSlowEaseIn,
        horizontalOffset: 30,
        verticalOffset: 300.0,
        child: FlipAnimation(
          duration: const Duration(milliseconds: 3000),
          curve: Curves.fastLinearToSlowEaseIn,
          flipAxis: FlipAxis.y,
          //row information
          child: Dismissible(
            key: Key(model!['id'].toString()),
            onDismissed: (direction) {
              AppCubit.get(context).updateData(state: 'hide', id: model['id']);
              ScaffoldMessenger.of(context).showSnackBar(snackBar!);
            },
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          '${model['time']}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${model['title']}',
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${model['date']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    IconButton(
                      onPressed: () {
                        AppCubit.get(context).updateData(
                          state: 'done',
                          id: model['id'],
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar!);
                      },
                      icon: Icon(
                        doneIcon,
                        color: doneColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        AppCubit.get(context).updateData(
                          state: 'archived',
                          id: model['id'],
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar!);
                      },
                      icon: Icon(
                        archiveIcon,
                        color: archiveColor,
                      ),
                    )
                  ],
                ),
              ),
              margin: EdgeInsets.only(bottom: width! / 30),
              height: width / 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
