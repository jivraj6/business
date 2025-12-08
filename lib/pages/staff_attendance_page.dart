import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class StaffAttendancePage extends StatefulWidget {
  @override
  _StaffAttendancePageState createState() => _StaffAttendancePageState();
}

class _StaffAttendancePageState extends State<StaffAttendancePage> {
  DateTime selectedDate = DateTime.now().subtract(Duration(days: 1));

  bool loading = false;
  List attendanceList = [];

  // ------------------------------
  // 🔵 FETCH ATTENDANCE API
  // ------------------------------
  Future<void> loadAttendance() async {
    setState(() => loading = true);
    String formattedDate = DateFormat("dd/MM/yyyy").format(selectedDate);
    var response = await http.get(
      Uri.parse(
        "https://www.livehomefurniture.com/application/ledgerbook/labour/getdailylist.php?date=" +
            formattedDate,
      ),
      //  body: {"date": selectedDate.toString().substring(0, 10)},
    );
    print("API RESPONSE: ${response.body}");

    setState(() {
      var decode = jsonDecode(response.body);
      attendanceList = decode["labourlist"];
      loading = false;
    });
  }

  // ------------------------------
  // 🔵 UPDATE CHECK-IN / CHECK-OUT
  // ------------------------------
  Future<void> updateTime(int attendanceId, bool isCheckIn, String time) async {
    await http.post(
      Uri.parse(
        "https://www.livehomefurniture.com/application/ledgerbook//update_attendance.php",
      ),
      body: {
        "id": attendanceId.toString(),
        isCheckIn ? "check_in" : "check_out": time,
      },
    );

    loadAttendance(); // refresh list
  }

  // ------------------------------
  // 🔵 PICK TIME
  // ------------------------------
  Future<void> pickTime(att, bool isCheckIn) async {
    TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (t != null) {
      String formatted =
          "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";

      updateTime(att, isCheckIn, formatted);
    }
  }

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Staff Attendance")),
      body: Column(
        children: [
          // 🔵 Date Picker
          GestureDetector(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
                loadAttendance();
              }
            },
            child: Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 12),
                  Text(
                    DateFormat("dd MMM yyyy").format(selectedDate),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Header row
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey.shade300,
            child: Row(
              children: const [
                Expanded(flex: 2, child: Center(child: Text("Employee"))),
                Expanded(child: Center(child: Text("IN"))),
                Expanded(child: Center(child: Text("OUT"))),
                Expanded(child: Center(child: Text("Salary"))),
              ],
            ),
          ),

          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: attendanceList.length,
                    itemBuilder: (context, i) {
                      var att = attendanceList[i];

                      return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          children: [
                            // IMAGE + NAME
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () {
                                  // open staff details page
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundImage: NetworkImage(
                                        att["pic"] ?? "",
                                      ),
                                      onBackgroundImageError: (_, __) =>
                                          Icon(Icons.person),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      att["name"] ?? "Unknown",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // IN
                            Expanded(
                              child: InkWell(
                                onTap: () => pickTime(att, true),
                                child: Center(
                                  child: Text(
                                    att["dayin"] ?? "IN",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // OUT
                            Expanded(
                              child: InkWell(
                                onTap: () => pickTime(att, false),
                                child: Center(
                                  child: Text(
                                    att["dayout"] ?? "OUT",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Salary
                            Expanded(
                              child: Center(
                                child: Text(
                                  att["daily_salary"] != null
                                      ? "₹${att["daily_salary"]}"
                                      : "-",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
