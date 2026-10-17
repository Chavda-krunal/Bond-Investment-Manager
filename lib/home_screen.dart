import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interest_schedule/kcolor.dart';
import 'package:interest_schedule/models/company_record.dart';
import 'package:interest_schedule/interest_schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CompanyRecord> _companies = [];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('companies_data');
    if (dataString != null) {
      final List<dynamic> decoded = jsonDecode(dataString);
      setState(() {
        _companies = decoded.map((e) => CompanyRecord.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveCompanies() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_companies.map((e) => e.toJson()).toList());
    await prefs.setString('companies_data', encoded);
  }

  void _showAddCompanyModal() {
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    final tenureController = TextEditingController();
    final principalController = TextEditingController();
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
                      'Add New Company Record',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Kcolor.darkText),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Please enter company name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date Of Investment',
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
                      controller: tenureController,
                      decoration: const InputDecoration(labelText: 'Tenure', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Please enter tenure' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: principalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Principal',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => double.tryParse(value ?? '') == null ? 'Please enter a valid principal amount' : null,
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
                            final newCompany = CompanyRecord(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              companyName: nameController.text.trim(),
                              dateOfInvestment: dateController.text.trim(),
                              tenure: tenureController.text.trim(),
                              principal: double.parse(principalController.text.trim()),
                              scheduleEntries: [],
                            );
                            setState(() {
                              _companies.add(newCompany);
                            });
                            _saveCompanies();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  void _deleteCompany(String id) {
    setState(() {
      _companies.removeWhere((element) => element.id == id);
    });
    _saveCompanies();
  }

  @override
  Widget build(BuildContext context) {
    double totalAppInvestment = _companies.fold(0.0, (sum, item) => sum + item.principal);

    return Scaffold(
      backgroundColor: Kcolor.lightBackground,
      appBar: AppBar(
        title: const Text('Interest Schedule', style: TextStyle(color: Kcolor.darkText, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Total Investment:\n₹${totalAppInvestment.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Kcolor.darkText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
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
      body: _companies.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No Record Found!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Tap the + button below to add your first record.', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _companies.length,
        itemBuilder: (context, index) {
          final company = _companies[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Kcolor.primary, Kcolor.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                company.companyName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Kcolor.darkText),
              ),
              subtitle: Text(
                'Date: ${company.dateOfInvestment} | Tenure: ${company.tenure}\nPrincipal: ₹${company.principal.toStringAsFixed(2)}',
                style: const TextStyle(color: Kcolor.darkText, height: 1.3),
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deleteCompany(company.id),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InterestScheduleScreen(companyRecord: company),
                  ),
                );
                _loadCompanies();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Kcolor.primary,
        onPressed: _showAddCompanyModal,
        child: const Icon(Icons.add, color: Kcolor.darkText),
      ),
    );
  }
}