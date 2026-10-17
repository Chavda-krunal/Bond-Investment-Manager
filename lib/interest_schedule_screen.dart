import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interest_schedule/kcolor.dart';
import 'package:interest_schedule/models/company_record.dart';
import 'package:interest_schedule/models/schedule_entry.dart';

class InterestScheduleScreen extends StatefulWidget {
  final CompanyRecord companyRecord;

  const InterestScheduleScreen({super.key, required this.companyRecord});

  @override
  State<InterestScheduleScreen> createState() => _InterestScheduleScreenState();
}

class _InterestScheduleScreenState extends State<InterestScheduleScreen> {
  late CompanyRecord _company;

  @override
  void initState() {
    super.initState();
    _company = widget.companyRecord;
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('companies_data');
    if (dataString != null) {
      List<dynamic> decoded = jsonDecode(dataString);
      List<CompanyRecord> allCompanies = decoded.map((e) => CompanyRecord.fromJson(e)).toList();

      int index = allCompanies.indexWhere((element) => element.id == _company.id);
      if (index != -1) {
        allCompanies[index] = _company;
        final String encoded = jsonEncode(allCompanies.map((e) => e.toJson()).toList());
        await prefs.setString('companies_data', encoded);
      }
    }
  }

  void _showAddEntryModal() {
    final dateController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Interest Entry',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Kcolor.darkText),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setModalState(() {
                            dateController.text = "${pickedDate.day.toString().padLeft(2, '0')}/"
                                "${pickedDate.month.toString().padLeft(2, '0')}/"
                                "${pickedDate.year}";
                          });
                        }
                      },
                      validator: (value) => value!.isEmpty ? 'Please select a date' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Interest',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => double.tryParse(value ?? '') == null ? 'Please enter a valid interest amount' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Kcolor.primary,
                          foregroundColor: Kcolor.darkText,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final newEntry = ScheduleEntry(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              date: dateController.text.trim(),
                              amount: double.parse(amountController.text.trim()),
                            );
                            setState(() {
                              _company.scheduleEntries.add(newEntry);
                            });
                            _saveToStorage();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteEntry(String id) {
    setState(() {
      _company.scheduleEntries.removeWhere((element) => element.id == id);
    });
    _saveToStorage();
  }

  @override
  Widget build(BuildContext context) {
    double totalInterestAmount = _company.scheduleEntries.fold(0.0, (sum, item) => sum + item.amount);
    double interestRate = _company.principal > 0 ? (totalInterestAmount / _company.principal) * 100 : 0.0;

    return Scaffold(
      backgroundColor: Kcolor.lightBackground,
      appBar: AppBar(
        title: Text(_company.companyName, style: const TextStyle(color: Kcolor.darkText, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Kcolor.primary, Kcolor.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Interest', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${totalInterestAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Kcolor.darkText),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Kcolor.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Interest Rate: ${interestRate.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Kcolor.darkText, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _company.scheduleEntries.isEmpty
                ? const Center(
              child: Text('No interest entries found. Tap + to add.', style: TextStyle(color: Colors.grey)),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _company.scheduleEntries.length,
              itemBuilder: (context, index) {
                final entry = _company.scheduleEntries[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Kcolor.primary, Kcolor.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text('Date: ${entry.date}', style: const TextStyle(fontWeight: FontWeight.w600, color: Kcolor.darkText)),
                    subtitle: Text('Interest: ₹${entry.amount.toStringAsFixed(2)}', style: const TextStyle(color: Kcolor.darkText)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteEntry(entry.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Kcolor.primary,
        onPressed: _showAddEntryModal,
        child: const Icon(Icons.add, color: Kcolor.darkText),
      ),
    );
  }
}