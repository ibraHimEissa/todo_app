import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/dones_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);
  List<Map>? newTasks = [];
  List<Map>? doneTasks = [];
  List<Map>? archivedTasks = [];
  List<Map>? hidesTasks = [];

  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen()
  ];

  var currentIndex = 0;
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  bool isBottomSheetShown = false;
  IconData floatingIcon = Icons.add;
  void changeFabIcon(bool isShow, IconData icon) {
    isBottomSheetShown = isShow;
    floatingIcon = icon;
    emit(AppChangeFloatingState());
  }

  late Database db;
  // to create database
  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (db, version) {
        print('database created');

        db
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) => print('table created'))
            .catchError((error) =>
                print('Error when creating table \n${error.toString()}'));
      },
      onOpen: (db) {
        getDataFromDataBase(db);
        print('database opened');
      },
    ).then((value) {
      db = value;
      emit(AppCreateDBState());
    });
  }

// to insert into table at database
  insertToDatabase({
    required String? title,
    required String? date,
    required String? time,
  }) async {
    return await db.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time,status) VALUES("$title","$date","$time","new")')
          .then((value) {
        print('$value inserted successfully');
        getDataFromDataBase(db);
        emit(AppInsertDBState());
      }).catchError((error) {
        print('Error when inserting new record \n${error.toString()}');
      });
    });
  }

  void getDataFromDataBase(Database db) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    hidesTasks = [];

    emit(AppGetDBLoadingState());
    db.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks!.add(element);
        } else if (element['status'] == 'done') {
          doneTasks!.add(element);
        } else if(element['status'] == 'archived'){
          archivedTasks!.add(element);
        } else {
          hidesTasks!.add(element);
        }
      });
      emit(AppGetDataFromDBState());
      print(newTasks);
    });
  }

  IconData doneIcon = Icons.check_box;
  Color doneColor = Colors.grey;
  IconData archiveIcon = Icons.archive;
  Color archiveColor = Colors.black;

  void updateData({
    required String state,
    required int id,
  }) async {
    db.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$state', '$id'],
    ).then((value) {
      getDataFromDataBase(db);
      emit(AppUpdateDBState());
    });
  }

  void deleteData({
    required int id,
  }) async {
    db.rawDelete(
      'DELETE FROM tasks WHERE id = $id',
    )
        .then((value) {
      getDataFromDataBase(db);
      emit(AppUpdateDBState());
    });
  }
}
