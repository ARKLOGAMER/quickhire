import 'package:flutter/material.dart';

class ApplyScreen extends StatelessWidget {
  final String jobTitle;
  final String company;
  final String location;
  final String salary;
  final String jobDescription;
  final String? logoUrl;

  const ApplyScreen({
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.salary,
    required this.jobDescription,
    this.logoUrl, // Now optional
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(company),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    child: logoUrl != null && logoUrl!.isNotEmpty
                        ? Image.network(
                            logoUrl!,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported,
                                    size: 60, color: Colors.grey),
                          )
                        : const Icon(Icons.business, size: 60, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    jobTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(company, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(location, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text("\$$salary/month", style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Job Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              jobDescription,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement application logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Application submitted!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Apply Now", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
