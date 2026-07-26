// import 'package:flutter/material.dart';
//
// class VolunteerHistoryScreen extends StatefulWidget {
//   const VolunteerHistoryScreen({super.key});
//
//   @override
//   State<VolunteerHistoryScreen> createState() => _VolunteerHistoryScreenState();
// }
//
// class _VolunteerHistoryScreenState extends State<VolunteerHistoryScreen>
//     with TickerProviderStateMixin {
//   int _selectedIndex = 0;
//
//   final List<String> _titles = [
//     "Call Logs",
//     "Activity Log",
//     "Feedback & Ratings",
//     "Filters & Search"
//   ];
//
//   final List<Widget> _screens = [
//     CallLogsScreen(),
//     ActivityLogScreen(),
//     FeedbackScreen(),
//     FilterSearchScreen(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true, // 👈 Gradient ke upar appbar transparent
//       appBar: AppBar(
//         title: Text(
//           _titles[_selectedIndex],
//           style: const TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black, Color(0xFF6A1B9A)], // Black → Purple
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Column(
//           children: [
//             const SizedBox(height: 80), // AppBar spacing
//             // ✅ Summary Card
//             Container(
//               margin: const EdgeInsets.all(12),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black45,
//                     blurRadius: 8,
//                     offset: Offset(0, 4),
//                   )
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: const [
//                   SummaryItem(title: "Calls", value: "12"),
//                   SummaryItem(title: "Feedback", value: "5"),
//                   SummaryItem(title: "Hours", value: "3h"),
//                 ],
//               ),
//             ),
//
//             // ✅ Dynamic Screens
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 12),
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: _screens[_selectedIndex],
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       // ✅ Custom Animated Bottom Bar
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Colors.black, Color(0xFF4A148C)], // Black → Dark Purple
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           boxShadow: [
//             BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, -2))
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             BottomBarButton(
//               icon: Icons.call,
//               label: "Calls",
//               isSelected: _selectedIndex == 0,
//               onTap: () => _onItemTapped(0),
//               vsync: this,
//             ),
//             BottomBarButton(
//               icon: Icons.bar_chart,
//               label: "Activity",
//               isSelected: _selectedIndex == 1,
//               onTap: () => _onItemTapped(1),
//               vsync: this,
//             ),
//             BottomBarButton(
//               icon: Icons.star,
//               label: "Feedback",
//               isSelected: _selectedIndex == 2,
//               onTap: () => _onItemTapped(2),
//               vsync: this,
//             ),
//             BottomBarButton(
//               icon: Icons.filter_alt,
//               label: "Filters",
//               isSelected: _selectedIndex == 3,
//               onTap: () => _onItemTapped(3),
//               vsync: this,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /////////////////// SUMMARY WIDGET ///////////////////
// class SummaryItem extends StatelessWidget {
//   final String title;
//   final String value;
//
//   const SummaryItem({super.key, required this.title, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(value,
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             )),
//         const SizedBox(height: 4),
//         Text(title,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.white70,
//             )),
//       ],
//     );
//   }
// }
//
// /////////////////// BOTTOM BAR BUTTON ///////////////////
// class BottomBarButton extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final TickerProvider vsync;
//
//   const BottomBarButton({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//     required this.vsync,
//   });
//
//   @override
//   State<BottomBarButton> createState() => _BottomBarButtonState();
// }
//
// class _BottomBarButtonState extends State<BottomBarButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scale;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: widget.vsync,
//       duration: const Duration(milliseconds: 250),
//     );
//     _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//
//     if (widget.isSelected) _controller.forward();
//   }
//
//   @override
//   void didUpdateWidget(covariant BottomBarButton oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isSelected) {
//       _controller.forward();
//     } else {
//       _controller.reverse();
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final color = widget.isSelected ? Colors.purpleAccent : Colors.white70;
//
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: ScaleTransition(
//         scale: _scale,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(widget.icon, color: color, size: 28),
//             const SizedBox(height: 4),
//             Text(widget.label,
//                 style: TextStyle(
//                     color: color,
//                     fontSize: 12,
//                     fontWeight: widget.isSelected
//                         ? FontWeight.bold
//                         : FontWeight.normal)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /////////////////// DUMMY SCREENS ///////////////////
// class CallLogsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final List<Map<String, String>> callLogs = [
//       {"name": "Ali", "time": "10:30 AM", "status": "Completed"},
//       {"name": "Sara", "time": "11:45 AM", "status": "Missed"},
//       {"name": "Ahmed", "time": "1:15 PM", "status": "Completed"},
//     ];
//
//     return ListView.builder(
//       itemCount: callLogs.length,
//       itemBuilder: (context, index) {
//         return Card(
//           color: Colors.white12,
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.all(10),
//           child: ListTile(
//             leading: const Icon(Icons.call, color: Colors.greenAccent),
//             title: Text("Call with ${callLogs[index]["name"]}",
//                 style: const TextStyle(color: Colors.white)),
//             subtitle: Text(
//                 "${callLogs[index]["time"]} • ${callLogs[index]["status"]}",
//                 style: const TextStyle(color: Colors.white70)),
//             trailing: const Icon(Icons.arrow_forward_ios,
//                 size: 16, color: Colors.white54),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class ActivityLogScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final List<String> activities = [
//       "5 calls answered today",
//       "2 emergency requests handled",
//       "Total 3 hours active",
//     ];
//
//     return ListView.builder(
//       itemCount: activities.length,
//       itemBuilder: (context, index) {
//         return Card(
//           color: Colors.white12,
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.all(10),
//           child: ListTile(
//             leading: const Icon(Icons.bar_chart, color: Colors.blueAccent),
//             title: Text(activities[index],
//                 style: const TextStyle(color: Colors.white)),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class FeedbackScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final List<Map<String, dynamic>> feedbacks = [
//       {"user": "Ali", "rating": 5, "comment": "Very helpful!"},
//       {"user": "Sara", "rating": 4, "comment": "Good, but response was slow"},
//       {"user": "Ahmed", "rating": 5, "comment": "Excellent support!"},
//     ];
//
//     return ListView.builder(
//       itemCount: feedbacks.length,
//       itemBuilder: (context, index) {
//         return Card(
//           color: Colors.white12,
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.all(10),
//           child: ListTile(
//             leading: Icon(Icons.star, color: Colors.amberAccent.shade200),
//             title: Text(
//                 "${feedbacks[index]["user"]} - ⭐ ${feedbacks[index]["rating"]}",
//                 style: const TextStyle(color: Colors.white)),
//             subtitle: Text(feedbacks[index]["comment"],
//                 style: const TextStyle(color: Colors.white70)),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class FilterSearchScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Search Bar
//         Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: TextField(
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: "Search by name...",
//               hintStyle: const TextStyle(color: Colors.white54),
//               prefixIcon: const Icon(Icons.search, color: Colors.white),
//               filled: true,
//               fillColor: Colors.white12,
//               border:
//               OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ),
//
//         // Filter Options
//         Wrap(
//           spacing: 10,
//           children: [
//             FilterChip(
//                 label: const Text("Today"),
//                 selectedColor: Colors.purpleAccent,
//                 onSelected: (val) {}),
//             FilterChip(
//                 label: const Text("This Week"),
//                 selectedColor: Colors.purpleAccent,
//                 onSelected: (val) {}),
//             FilterChip(
//                 label: const Text("This Month"),
//                 selectedColor: Colors.purpleAccent,
//                 onSelected: (val) {}),
//             FilterChip(
//                 label: const Text("Calls"),
//                 selectedColor: Colors.purpleAccent,
//                 onSelected: (val) {}),
//             FilterChip(
//                 label: const Text("Feedback"),
//                 selectedColor: Colors.purpleAccent,
//                 onSelected: (val) {}),
//           ],
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class VolunteerHistoryScreen extends StatefulWidget {
  const VolunteerHistoryScreen({super.key});

  @override
  State<VolunteerHistoryScreen> createState() => _VolunteerHistoryScreenState();
}

class _VolunteerHistoryScreenState extends State<VolunteerHistoryScreen> {
  String _searchQuery = "";
  String _selectedFilter = "All"; // All, Today, Accepted, Rejected

  final List<String> _filters = ["All", "Today", "Accepted", "Rejected"];

  String? get currentVolunteerId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Call History & Logs",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF2D0A4E), Color(0xFF5E2B97)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ✅ Live Summary Card (Counts from Firestore)
              if (currentVolunteerId != null)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('volunteer')
                      .doc(currentVolunteerId)
                      .collection('call')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int totalCalls = snapshot.data?.docs.length ?? 0;
                    int acceptedCalls = 0;

                    if (snapshot.hasData) {
                      acceptedCalls = snapshot.data!.docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return data['status'] == 'accepted';
                      }).length;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SummaryItem(
                              title: "Total Calls", value: "$totalCalls"),
                          SummaryItem(
                              title: "Accepted", value: "$acceptedCalls"),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 10),

              // ✅ SEARCH & INLINE FILTER (Integrated in Same Screen)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase().trim();
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search user ID or status...",
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon:
                        const Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.purpleAccent),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Inline Filter Chips
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: Colors.purpleAccent,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              side: BorderSide.none, // 👈 FIX: 'border' ki jagah 'side' use kiya hai
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ✅ SINGLE UNIFIED CALL LOGS STREAM
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: currentVolunteerId == null
                      ? const Center(
                    child: Text("User not logged in",
                        style: TextStyle(color: Colors.white70)),
                  )
                      : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('volunteer')
                        .doc(currentVolunteerId)
                        .collection('call')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error fetching call logs",
                              style: TextStyle(color: Colors.redAccent)),
                        );
                      }

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Colors.purpleAccent),
                        );
                      }

                      var docs = snapshot.data?.docs ?? [];

                      // Local Filtering & Search Logic
                      var filteredDocs = docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        String userId =
                            data['blindUserId']?.toString().toLowerCase() ??
                                '';
                        String status =
                            data['status']?.toString().toLowerCase() ?? '';

                        // Search Match
                        bool matchesSearch = userId.contains(_searchQuery) ||
                            status.contains(_searchQuery);

                        // Filter Match
                        bool matchesFilter = true;
                        if (_selectedFilter == "Accepted") {
                          matchesFilter = status == 'accepted';
                        } else if (_selectedFilter == "Rejected") {
                          matchesFilter = status == 'rejected';
                        } else if (_selectedFilter == "Today") {
                          Timestamp? ts = data['timestamp'] as Timestamp?;
                          if (ts != null) {
                            DateTime date = ts.toDate();
                            DateTime now = DateTime.now();
                            matchesFilter = date.year == now.year &&
                                date.month == now.month &&
                                date.day == now.day;
                          } else {
                            matchesFilter = false;
                          }
                        }

                        return matchesSearch && matchesFilter;
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No call logs found",
                            style: TextStyle(
                                color: Colors.white60, fontSize: 14),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data = filteredDocs[index]
                              .data() as Map<String, dynamic>;

                          String blindUserId =
                              data['blindUserId'] ?? "Unknown User";
                          String status = data['status'] ?? "pending";
                          Timestamp? ts = data['timestamp'] as Timestamp?;

                          String formattedDate = ts != null
                              ? DateFormat('dd MMM, hh:mm a')
                              .format(ts.toDate())
                              : "Recent";

                          bool isAccepted = status == 'accepted';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isAccepted
                                    ? Colors.greenAccent.withOpacity(0.3)
                                    : Colors.redAccent.withOpacity(0.3),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAccepted
                                    ? Colors.greenAccent.withOpacity(0.2)
                                    : Colors.redAccent.withOpacity(0.2),
                                child: Icon(
                                  isAccepted
                                      ? Icons.call_made
                                      : Icons.call_missed,
                                  color: isAccepted
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                              ),
                              title: Text(
                                "User: $blindUserId",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                "Status: ${status.toUpperCase()}",
                                style: TextStyle(
                                  color: isAccepted
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                formattedDate,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 10),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/////////////////// SUMMARY WIDGET ///////////////////
class SummaryItem extends StatelessWidget {
  final String title;
  final String value;

  const SummaryItem({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}