import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController txtController = TextEditingController();
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Records"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection("tasks").orderBy("time").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(ds["task"]),
                  leading: IconButton(
                    onPressed: () {
                      db.collection("tasks").doc(ds.id).delete();
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Update Task"),
                              content: Form(
                                key: formkey,
                                child: TextFormField(
                                  autofocus: true,
                                  controller: txtController,
                                  decoration: const InputDecoration(
                                    hintText: "Update your task",
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Required";
                                    }
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      if (formkey.currentState!.validate()) {
                                        db
                                            .collection("tasks")
                                            .doc(ds.id)
                                            .update(
                                          {
                                            "task": txtController.text,
                                            "time": DateTime.now()
                                          },
                                        );
                                        txtController.clear();
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text("Update Task")),
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.edit),
                  ),
                );
              },
            );
          }
          return const CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add Data"),
                content: Form(
                  key: formkey,
                  child: TextFormField(
                    controller: txtController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Add text here",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Required";
                      }
                    },
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        db.collection("tasks").add({
                          'task': txtController.text,
                          "time": DateTime.now()
                        });
                        Navigator.pop(context);
                        txtController.clear();
                      }
                    },
                    child: const Text("Submit"),
                  )
                ],
              );
            }),
        child: const Icon(Icons.add),
      ),
    );
  }
}
