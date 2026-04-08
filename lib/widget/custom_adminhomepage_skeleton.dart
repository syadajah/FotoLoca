import 'package:flutter/material.dart';

class AdminSkeleton extends StatelessWidget {
  const AdminSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton Header
          Container(
            width: 200, 
            height: 24, 
            decoration: BoxDecoration(
              color: Colors.grey.shade300, 
              borderRadius: BorderRadius.circular(8)
            )
          ),
          const SizedBox(height: 8),
          Container(
            width: 280, 
            height: 14, 
            decoration: BoxDecoration(
              color: Colors.grey.shade300, 
              borderRadius: BorderRadius.circular(8)
            )
          ),
          const SizedBox(height: 30),

          // Skeleton Card 1
          Container(
            width: 180, 
            height: 16, 
            decoration: BoxDecoration(
              color: Colors.grey.shade300, 
              borderRadius: BorderRadius.circular(8)
            )
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity, 
            height: 100, 
            decoration: BoxDecoration(
              color: Colors.grey.shade300, 
              borderRadius: BorderRadius.circular(15)
            )
          ),
          const SizedBox(height: 30),

          // Skeleton Card 2
          Container(
            width: 180, 
            height: 16, 
            decoration: BoxDecoration(
              color: Colors.grey.shade300, 
              borderRadius: BorderRadius.circular(8)
            )
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity, 
            height: 120, 
            decoration: BoxDecoration(
              color: Colors.grey.shade300, 
              borderRadius: BorderRadius.circular(15)
            )
          ),
          const SizedBox(height: 30),

          // Skeleton Card 3 (List)
          Container(
            width: 150, 
            height: 16, 
            decoration: BoxDecoration(
              color: Colors.grey.shade300, 
              borderRadius: BorderRadius.circular(8)
            )
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: List.generate(3, (index) => Container(
                margin: const EdgeInsets.only(bottom: 15),
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200, 
                  borderRadius: BorderRadius.circular(12)
                ),
              )),
            ),
          )
        ],
      ),
    );
  }
}