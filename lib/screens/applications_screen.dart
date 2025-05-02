import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickhire1/screens/apply_screen.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Applications"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('jobs').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              return JobApplicationCard(
                company: doc['company'],
                position: doc['title'],
                location: doc['location'],
                salary: "\$${doc['salary']} Monthly",
                onApply: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplyScreen(
                        jobTitle: doc['title'],
                        company: doc['company'],
                        location: doc['location'],
                        salary: doc['salary'].toString(),
                        jobDescription: doc['description'],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class JobApplicationCard extends StatelessWidget {
  final String company;
  final String position;
  final String location;
  final String salary;
  final VoidCallback onApply;

  const JobApplicationCard({
    required this.company,
    required this.position,
    required this.location,
    required this.salary,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company, style: TextStyle(color: Colors.grey)),
                  Text(position, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(location, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(salary, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onApply,
                  child: Text("Apply"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}