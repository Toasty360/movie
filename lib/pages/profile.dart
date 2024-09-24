import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Box<String> settings = MySettings.box;

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: TextButton(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.deepPurple.withOpacity(0.5),
          ),
          child: const Icon(Icons.close),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: screen.height * 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                "Settings",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Providers",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.blueGrey),
                    ),
                    TextButton(
                        onPressed: () {
                          settings.putAll({
                            'alpha': 'https://vidsrc.pro',
                            'beta': 'https://vidsrc.net',
                            'vidlink': 'https://hugo.vidlink.pro',
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: const Text(
                            "Reset",
                            style: TextStyle(fontSize: 10),
                          ),
                        )),
                  ],
                )),
            ValueListenableBuilder<Box<String>>(
              valueListenable:
                  settings.listenable(keys: ["alpha", "beta", "vidlink"]),
              builder: (context, value, _) {
                return ListView(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    myListTile("alpha", "Alpha", value),
                    myListTile("beta", "Beta", value),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget myListTile(String key, String title, Box<String> value) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Text(title),
        subtitle: Text(
          value.get(key) ?? "Not available",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        trailing: TextButton(
            child: const Text("change?"),
            onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return myDialog(context, key, value);
                  },
                )));
  }

  Widget myDialog(BuildContext context, String key, Box<String> box) {
    TextEditingController editingController = TextEditingController();
    return AlertDialog(
      content: TextFormField(
        controller: editingController,
        maxLength: 50,
        keyboardType: TextInputType.url,
        obscureText: false,
        decoration: InputDecoration(
          labelText: '${key.toUpperCase()} Link',
        ),
      ),
      contentPadding: const EdgeInsets.only(left: 20, top: 20, right: 20),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            String value = editingController.value.text;
            if (value.isNotEmpty) {
              box.put(key, value);
              Navigator.pop(context);
            }
          },
        ),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"))
      ],
    );
  }
}
