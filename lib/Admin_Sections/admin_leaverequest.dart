// ✅ Full Updated LeaveRequestsPage
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequestsPage extends StatefulWidget {
  @override
  State<LeaveRequestsPage> createState() => _LeaveRequestsPageState();
}

class _LeaveRequestsPageState extends State<LeaveRequestsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _searchQuery = "";

  final List<String> _statuses = ["Pending", "Approved", "Rejected"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  void _updateSearch(String value) {
    setState(() => _searchQuery = value.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Requests'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: _statuses.map((status) => Tab(text: status)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: _updateSearch,
              decoration: InputDecoration(
                hintText: "Search by name or employee ID",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statuses.map((status) => _buildLeaveList(status)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leave_requests')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text('No $status leave requests.'));

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['employeeName'] ?? '').toString().toLowerCase();
          final empId = (data['employeeId'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery) || empId.contains(_searchQuery);
        }).toList();

        if (docs.isEmpty)
          return Center(child: Text('No results for "$_searchQuery"'));

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildLeaveCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildLeaveCard(String docId, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(data['image'] ?? 'https://via.placeholder.com/150'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data['employeeName'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('ID: ${data['employeeId'] ?? 'N/A'}', style: TextStyle(color: Colors.grey[700])),
                ]),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (data['leaveType'] == 'Sick Leave') ? Colors.green[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data['leaveType'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: (data['leaveType'] == 'Sick Leave') ? Colors.green[800] : Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _info("Start Date", data['startDate']),
          _info("End Date", data['endDate']),
          _info("Half Day", data['isHalfDay'] == true ? 'Yes' : 'No'),
          _info("Reason", data['reason']),
          SizedBox(height: 12),
          if (data['status'] == 'Pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _button("APPROVE", Colors.green, () async {
                  await FirebaseFirestore.instance
                      .collection('leave_requests')
                      .doc(docId)
                      .update({'status': 'Approved'});

                  await FirebaseFirestore.instance.collection('notifications').add({
                    'title': 'Leave Request Approved',
                    'message': '${data['employeeName']}\'s leave from ${data['startDate']} to ${data['endDate']} has been approved.',
                    'type': 'leave',
                    'read': false,
                    'timestamp': Timestamp.now(),
                    'action': 'view_leave',
                    'employeeId': data['employeeId'],
                  });
                }),
                _button("REJECT", Colors.red, () async {
                  await FirebaseFirestore.instance
                      .collection('leave_requests')
                      .doc(docId)
                      .update({'status': 'Rejected'});

                  await FirebaseFirestore.instance.collection('notifications').add({
                    'title': 'Leave Request Rejected',
                    'message': '${data['employeeName']}\'s leave from ${data['startDate']} to ${data['endDate']} has been rejected.',
                    'type': 'leave',
                    'read': false,
                    'timestamp': Timestamp.now(),
                    'action': 'view_leave',
                    'employeeId': data['employeeId'],
                  });
                }),
              ],
            ),
        ]),
      ),
    );
  }

  Widget _info(String label, dynamic value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(value?.toString() ?? '-', style: TextStyle(color: Colors.grey[800])),
        ),
      ],
    ),
  );

  Widget _button(String text, Color color, VoidCallback onTap) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: color.withOpacity(0.1),
      foregroundColor: color.withOpacity(0.8),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Text(text),
  );
}