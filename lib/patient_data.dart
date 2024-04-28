import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PatientInfoPage extends StatefulWidget {
  @override
  _PatientInfoPageState createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  String apiUrl = 'http://192.168.1.2:5000/api/patients'; //  API endpoint

  TextEditingController nameController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();
  String? selectedGender;
  TextEditingController maritalStatusController = TextEditingController();
  TextEditingController childrenStatusController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emergencyPhoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController medicalHistoryController = TextEditingController();
  TextEditingController reasonForVisitController = TextEditingController();
  TextEditingController symptomsController = TextEditingController();
  TextEditingController vitalSignsController = TextEditingController();
  TextEditingController diagnosticTestsController = TextEditingController();
  TextEditingController treatmentPlanController = TextEditingController();
  TextEditingController insuranceStatusController = TextEditingController();
  TextEditingController insurancePolicyController = TextEditingController();
  TextEditingController pillsNumberController = TextEditingController();
  TextEditingController pillsNameController = TextEditingController();
  TextEditingController admissionDateController = TextEditingController();
  TextEditingController dischargeDateController = TextEditingController();

  bool pillsFound = false;
  String? insuranceDocumentsPath;
  String? pillImagesPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Admission Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Personal Information'),
              _buildTextField('Full Name', nameController),
              _buildTextField('Father\'s Name', fatherNameController),
              _buildTextField('Mother\'s Name', motherNameController),
              _buildGenderSelection(),
              _buildMaritalStatusSelection(),
              if (maritalStatusController.text == 'Married') ...[
                _buildChildrenStatusSelection(),
              ],
              _buildTextField('Phone Number', phoneController),
              _buildTextField('Emergency Phone Number', emergencyPhoneController),
              _buildTextField('Email', emailController),
              _buildSectionTitle('Medical Details'),
              _buildTextField('Medical History', medicalHistoryController),
              _buildTextField('Reason for Visit', reasonForVisitController),
              _buildTextField('Symptoms', symptomsController),
              _buildTextField('Vital Signs', vitalSignsController),
              _buildTextField('Diagnostic Tests', diagnosticTestsController),
              _buildTextField('Treatment Plan', treatmentPlanController),
              _buildSectionTitle('Insurance Information'),
              _buildInsuranceStatusSelection(),
              if (insuranceStatusController.text == 'Found') ...[
                _buildTextField('Insurance Policy Number', insurancePolicyController),
                _buildAddDocumentButton('Insurance Documents', () {
                  _selectDocument('insurance');
                }),
              ],
              _buildSectionTitle('Pills Information'),
              _buildPillsStatus(),
              if (pillsFound) ...[
                _buildTextField('Pills Number', pillsNumberController),
                _buildTextField('Pills Name', pillsNameController),
                _buildAddDocumentButton('Pill Images', () {
                  _selectDocument('pill');
                }),
              ],
              _buildSectionTitle('Dates'),
              _buildDateField('Admission Date', admissionDateController),
              _buildDateField('Discharge Date', dischargeDateController),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    "name": nameController.text,
                    "fatherName": fatherNameController.text,
                    "motherName": motherNameController.text,
                    "gender": selectedGender,
                    "maritalStatus": maritalStatusController.text,
                    "childrenStatus": childrenStatusController.text,
                    "phone": phoneController.text,
                    "emergencyPhone": emergencyPhoneController.text,
                    "email": emailController.text,
                    "medicalHistory": medicalHistoryController.text,
                    "reasonForVisit": reasonForVisitController.text,
                    "symptoms": symptomsController.text,
                    "vitalSigns": vitalSignsController.text,
                    "diagnosticTests": diagnosticTestsController.text,
                    "treatmentPlan": treatmentPlanController.text,
                    "insuranceStatus": insuranceStatusController.text,
                    "insurancePolicy": insurancePolicyController.text,
                    "insuranceDocuments": insuranceDocumentsPath,
                    "pillsNumber": pillsNumberController.text,
                    "pillsName": pillsNameController.text,
                    "pillImages": pillImagesPath,
                    "admissionDate": admissionDateController.text,
                    "dischargeDate": dischargeDateController.text,
                  };

                  final response = await http.post(
                    Uri.parse(apiUrl),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(data),
                  );

                  if (response.statusCode == 200) {
                    _clearTextFields();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Patient data saved successfully!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save patient data.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Gender',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Male',
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),
            Text('Male'),
            Radio<String>(
              value: 'Female',
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),
            Text('Female'),
          ],
        ),
      ],
    );
  }

  Widget _buildMaritalStatusSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Marital Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Single',
              groupValue: maritalStatusController.text,
              onChanged: (value) {
                setState(() {
                  maritalStatusController.text = value!;
                });
              },
            ),
            Text('Single'),
            Radio<String>(
              value: 'Married',
              groupValue: maritalStatusController.text,
              onChanged: (value) {
                setState(() {
                  maritalStatusController.text = value!;
                });
              },
            ),
            Text('Married'),
          ],
        ),
      ],
    );
  }

  Widget _buildChildrenStatusSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Children',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Yes',
              groupValue: childrenStatusController.text,
              onChanged: (value) {
                setState(() {
                  childrenStatusController.text = value!;
                });
              },
            ),
            Text('Yes'),
            Radio<String>(
              value: 'No',
              groupValue: childrenStatusController.text,
              onChanged: (value) {
                setState(() {
                  childrenStatusController.text = value!;
                });
              },
            ),
            Text('No'),
          ],
        ),
      ],
    );
  }

  Widget _buildInsuranceStatusSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Insurance Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Found',
              groupValue: insuranceStatusController.text,
              onChanged: (value) {
                setState(() {
                  insuranceStatusController.text = value!;
                });
              },
            ),
            Text('Found'),
            Radio<String>(
              value: 'Not Found',
              groupValue: insuranceStatusController.text,
              onChanged: (value) {
                setState(() {
                  insuranceStatusController.text = value!;
                });
              },
            ),
            Text('Not Found'),
          ],
        ),
      ],
    );
  }

  Widget _buildPillsStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Pills',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: pillsFound,
              onChanged: (value) {
                setState(() {
                  pillsFound = value!;
                });
              },
            ),
            Text('Pills Found'),
            SizedBox(width: 16.0),
            Radio<bool>(
              value: false,
              groupValue: pillsFound,
              onChanged: (value) {
                setState(() {
                  pillsFound = value!;
                });
              },
            ),
            Text('Pills Not Found'),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(label),
        subtitle: Text(controller.text.isNotEmpty ? controller.text : 'Select date'),
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text = pickedDate.toString().split(' ')[0];
            });
          }
        },
      ),
    );
  }

  Widget _buildAddDocumentButton(String labelText, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.attach_file),
          SizedBox(width: 8.0),
          Text(
            labelText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? filePath;
      try {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;

        PlatformFile file = result.files.single;
        String fileName = file.name;

        filePath = '$appDocPath/$fileName';
        await File(file.path!).copy(filePath);

        setState(() {
          if (type == 'insurance') {
            insuranceDocumentsPath = filePath;
          } else if (type == 'pill') {
            pillImagesPath = filePath;
          }
        });
      } catch (e) {
        print('Error selecting document: $e');
        setState(() {
          if (type == 'insurance') {
            insuranceDocumentsPath = null;
          } else if (type == 'pill') {
            pillImagesPath = null;
          }
        });
      }
    }
  }

  void _clearTextFields() {
    nameController.clear();
    fatherNameController.clear();
    motherNameController.clear();
    selectedGender = null;
    maritalStatusController.clear();
    childrenStatusController.clear();
    phoneController.clear();
    emergencyPhoneController.clear();
    emailController.clear();
    medicalHistoryController.clear();
    reasonForVisitController.clear();
    symptomsController.clear();
    vitalSignsController.clear();
    diagnosticTestsController.clear();
    treatmentPlanController.clear();
    insuranceStatusController.clear();
    insurancePolicyController.clear();
    pillsNumberController.clear();
    pillsNameController.clear();
    admissionDateController.clear();
    dischargeDateController.clear();
  }
}
