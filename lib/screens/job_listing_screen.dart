import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobListingScreen extends StatefulWidget {
  @override
  _JobListingScreenState createState() => _JobListingScreenState();
}

class _JobListingScreenState extends State<JobListingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Listings')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddJobDialog(context), // Show dialog to add job
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('jobs').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No jobs available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var job = snapshot.data!.docs[index];

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: job['logo'] != null
                      ? Image.network(job['logo'], width: 40, height: 40)
                      : Icon(Icons.business, size: 40),
                  title: Text(job['title'] ?? 'No Title', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(job['company'] ?? 'Unknown Company'),
                  trailing: Text(job['salary']?.toString() ?? 'N/A', style: TextStyle(color: Colors.green)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Show a dialog to add a new job
  void _showAddJobDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController companyController = TextEditingController();
    TextEditingController salaryController = TextEditingController();
    TextEditingController logoController = TextEditingController(text: "https://via.placeholder.com/40"); // Default Logo

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Job"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Job Title")),
            TextField(controller: companyController, decoration: InputDecoration(labelText: "Company")),
            TextField(controller: salaryController, decoration: InputDecoration(labelText: "Salary")),
            TextField(controller: logoController, decoration: InputDecoration(labelText: "Logo URL")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('jobs').add({
                "title": titleController.text,
                "company": companyController.text,
                "salary": salaryController.text,
                "logo": logoController.text,
              });

              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}
