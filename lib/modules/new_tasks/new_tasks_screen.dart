import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class NewTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        AppCubit cubit = AppCubit.get(context);
        var tasks = AppCubit.get(context).newTasks;
        double width = MediaQuery.of(context).size.width;
        if (tasks!.isEmpty) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.assignment_outlined, color: Colors.grey),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'No Tasks Archived',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          return ListView.builder(
              padding: EdgeInsets.all(width / 30),
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return defaultTaskItem(
                    Icons.check_box,
                    Colors.grey,
                    Icons.archive,
                    Colors.grey,
                    showSnackBar(context, 'new', tasks[index], 'Moved Successfully', 'Undo',),
                    tasks[index],
                    width, index, context);
              });
        }
      },
    );
  }
}
