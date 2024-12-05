import 'package:curdapi/api/apicode.dart';
import 'package:curdapi/model/model.dart';
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<curd> entries = [];
  bool isLoading = false; // To track loading state
  final UserService _userService = UserService(); // Initialize UserService

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  // Load all users into the state
  Future<void> _loadEntries() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      final users = await _userService.fetchUsers();
      setState(() {
        entries = users;
        isLoading = false; // Stop loading
      });    
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  // Show the bottom sheet for adding or editing a user
  void _showBottomSheet(BuildContext context, {curd? note}) {
    final nameController = TextEditingController(text: note?.name ?? '');
    final addressController = TextEditingController(text: note?.address ?? '');
    final emailController = TextEditingController(text: note?.email ?? '');

    // Save new or updated user
    Future<void> _saveNote() async {
      final name = nameController.text.trim();
      final address = addressController.text.trim();
      final email = emailController.text.trim();

      if (name.isEmpty || address.isEmpty || email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All fields are required')),
        );
        return;
      }

      try {
        if (note == null) {
          // Create a new user
          await _userService.createUser({
            'name': name,
            'address': address,
            'email': email,
          });
        } else {
          // Update existing user
          await _userService.updateUser(note.id, {
            'name': name,
            'address': address,
            'email': email,
          });
        }
        await _loadEntries(); // Reload data after creating or updating user
        Navigator.pop(context); // Close the bottom sheet
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('succes: $e')),
        );
      }
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(note == null ? 'Add User' : 'Edit User', style: TextStyle(fontSize: 18)),
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveNote, child: Text(note == null ? 'Save' : 'Update')),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          // Refresh button in the AppBar
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEntries, // Refresh the data
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _loadEntries, // Refresh when tapping anywhere on the screen
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Loading indicator while fetching data
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    title: Text(entry.name),
                    subtitle: Text('${entry.address}\n${entry.email}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showBottomSheet(context, note: entry),
                        ),
                        // Delete button
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            try {
                              await _userService.deleteUser(entry.id); // Delete user
                              await _loadEntries(); // Reload data after deletion
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User deleted')));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Succes: $e')));
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
