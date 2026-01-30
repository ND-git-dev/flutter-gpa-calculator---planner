import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import for date formatting

void main() {
  runApp(const GPACalculatorApp());
}

class GPACalculatorApp extends StatelessWidget {
  const GPACalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _GPACalculatorAppStateful();
  }
}

class _GPACalculatorAppStateful extends StatefulWidget {
  @override
  _GPACalculatorAppState createState() => _GPACalculatorAppState();
}

class _GPACalculatorAppState extends State<_GPACalculatorAppStateful> {
  bool _isDarkMode = false; //

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGPA/CGPA Calculator (Ethiopian System)', //
      theme: _isDarkMode ? _darkTheme() : _lightTheme(), //
      home: GPACalculatorScreen(
        isDarkMode: _isDarkMode, //
        onThemeChanged: (bool value) {
          setState(() {
            _isDarkMode = value;
          });
        }, //
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light, //
      scaffoldBackgroundColor: Colors.white, //
      colorScheme: ColorScheme.light(
        primary: Colors.blueGrey, //
        secondary: Colors.teal, //
        error: Colors.redAccent, //
        surface: Colors.white, // Card background
        onSurface: Colors.black, // Text on card
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blueGrey, //
        foregroundColor: Colors.white, //
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey, //
          foregroundColor: Colors.white, //
          side: const BorderSide(color: Colors.black26), //
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey)), //
        labelStyle: TextStyle(color: Colors.blueGrey), //
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black87), //
        titleMedium: TextStyle(color: Colors.black), //
      ),
      iconTheme: const IconThemeData(color: Colors.blueGrey), //
      cardTheme: CardTheme(
        elevation: 2, //
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), //
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark, //
      scaffoldBackgroundColor: Colors.black, //
      colorScheme: ColorScheme.dark(
        primary: Colors.tealAccent, //
        secondary: Colors.cyanAccent, //
        error: Colors.red, //
        surface: Colors.grey[850]!, // Card background
        onSurface: Colors.white, // Text on card
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900], //
        foregroundColor: Colors.white, //
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent, //
          foregroundColor: Colors.black, //
          side: const BorderSide(color: Colors.white24), //
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.tealAccent)), //
        labelStyle: TextStyle(color: Colors.tealAccent), //
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white70), //
        titleMedium: TextStyle(color: Colors.white), //
      ),
      iconTheme: const IconThemeData(color: Colors.tealAccent), //
      cardTheme: CardTheme(
        color: Colors.grey[850], //
        elevation: 3, //
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), //
      ),
    );
  }
}

class GPACalculatorScreen extends StatefulWidget {
  final bool isDarkMode; //
  final Function(bool) onThemeChanged; //

  const GPACalculatorScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  _GPACalculatorScreenState createState() => _GPACalculatorScreenState(); //
}

class _GPACalculatorScreenState extends State<GPACalculatorScreen> {
  final TextEditingController _previousCGPAController =
      TextEditingController(); //
  final TextEditingController _previousCreditHoursController =
      TextEditingController(); //
  final TextEditingController _courseNameController =
      TextEditingController(); //
  final TextEditingController _creditHoursController =
      TextEditingController(); //
  List<Map<String, dynamic>> _courses = []; //
  double _sgpa = 0.0; //
  double _cgpa = 0.0; //

  int? _editingCourseIndex; // To track which course is being edited
  String? _lastSavedTimestamp; //

  @override
  void initState() {
    super.initState();
    _previousCGPAController.addListener(_calculateSGPAAndCGPA); //
    _previousCreditHoursController.addListener(_calculateSGPAAndCGPA); //
    _loadLastSavedTimestamp(); //
  }

  @override
  void dispose() {
    _previousCGPAController.removeListener(_calculateSGPAAndCGPA); //
    _previousCreditHoursController.removeListener(_calculateSGPAAndCGPA); //
    _previousCGPAController.dispose(); //
    _previousCreditHoursController.dispose(); //
    _courseNameController.dispose(); //
    _creditHoursController.dispose(); //
    super.dispose(); //
  }

  Future<void> _loadLastSavedTimestamp() async {
    final prefs = await SharedPreferences.getInstance(); //
    if (mounted) {
      setState(() {
        _lastSavedTimestamp = prefs.getString('lastSavedTimestamp'); //
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); //
    return Scaffold(
      appBar: AppBar(
        title: const Text('SGPA/CGPA Calculator'), //
      ),
      drawer: Drawer(
        backgroundColor: theme.drawerTheme.backgroundColor ??
            theme.scaffoldBackgroundColor, //
        child: ListView(
          padding: EdgeInsets.zero, //
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary, //
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary, //
                  fontSize: 24, //
                ),
              ),
            ),
            if (_lastSavedTimestamp != null)
              ListTile(
                leading: Icon(Icons.history, color: theme.iconTheme.color), //
                title: Text('Last Saved: $_lastSavedTimestamp',
                    style: theme.textTheme.bodyMedium), //
              ),
            ListTile(
              leading: Icon(Icons.save, color: theme.iconTheme.color), //
              title: Text('Save', style: theme.textTheme.bodyMedium), //
              onTap: () {
                _saveData(context); //
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file, color: theme.iconTheme.color), //
              title: Text('Load', style: theme.textTheme.bodyMedium), //
              onTap: () {
                _loadData(context); //
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.help_outline, color: theme.iconTheme.color), //
              title: Text('Help', style: theme.textTheme.bodyMedium), //
              onTap: () {
                _showHelpDialog(context); //
              },
            ),
            ListTile(
              title: Text('Dark Mode', style: theme.textTheme.bodyMedium), //
              trailing: Switch(
                value: widget.isDarkMode, //
                onChanged: widget.onThemeChanged, //
                activeColor: theme.colorScheme.primary, //
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), //
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Make buttons stretch
            children: <Widget>[
              TextField(
                controller: _previousCGPAController, //
                decoration: const InputDecoration(labelText: 'Current CGPA'), //
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true), //
              ),
              const SizedBox(height: 10), //
              TextField(
                controller: _previousCreditHoursController, //
                decoration: const InputDecoration(
                    labelText: 'Total Credit Hours Taken'), //
                keyboardType: TextInputType.number, //
              ),
              const SizedBox(height: 10), //
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, //
                children: [
                  Text('SGPA: ${_sgpa.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium), //
                  Text('CGPA: ${_cgpa.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium), //
                ],
              ),
              const SizedBox(height: 20), //
              TextField(
                controller: _courseNameController, //
                decoration: const InputDecoration(labelText: 'Course Name'), //
              ),
              const SizedBox(height: 10), //
              TextField(
                controller: _creditHoursController, //
                decoration: const InputDecoration(labelText: 'Credit Hour'), //
                keyboardType: TextInputType.number, //
              ),
              const SizedBox(height: 10), //
              ElevatedButton(
                onPressed: _submitCourse, //
                child: Text(_editingCourseIndex != null
                    ? 'Update Course'
                    : 'Add Course'), //
              ),
              if (_editingCourseIndex != null) ...[
                const SizedBox(height: 10), //
                ElevatedButton(
                  onPressed: _cancelEdit, //
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error), //
                  child: Text('Cancel Edit',
                      style: TextStyle(color: theme.colorScheme.onError)), //
                ),
              ],
              const SizedBox(height: 20), //
              Text('Course Details:', style: theme.textTheme.titleMedium), //
              const SizedBox(height: 10), //
              _courses.isEmpty
                  ? Center(
                      child: Text('No courses added yet.',
                          style: theme.textTheme.bodyMedium)) //
                  : ListView.builder(
                      shrinkWrap: true, //
                      physics: const NeverScrollableScrollPhysics(), //
                      itemCount: _courses.length, //
                      itemBuilder: (context, index) {
                        return _buildCourseItem(index, theme); //
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context, //
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help'), //
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, //
              children: <Widget>[
                const Text(
                  'This calculator helps you calculate your SGPA and CGPA based on the Ethiopian grading system.', //
                ),
                const SizedBox(height: 20), //
                // Ensure you have 'assets/icon/he.png' in your project's assets folder
                // and it's declared in pubspec.yaml
                Image.asset(
                  'icon/he.png', // Make sure this path is correct
                  width: 100, //
                  height: 100, //
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Help image not found.'); //
                  },
                ),
                const SizedBox(height: 20), //
                const Text(
                  'Enter your previous CGPA and total credit hours taken, then add courses with their names, credit hours, and grades using the slider.', //
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'), //
              onPressed: () {
                Navigator.of(context).pop(); //
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourseItem(int index, ThemeData theme) {
    var course = _courses[index]; //
    int grade = course['grade'] ?? 0; //
    String letterGrade = _calculateLetterGrade(grade); //
    return Card(
      // CardTheme from ThemeData will be applied
      margin: const EdgeInsets.symmetric(vertical: 8.0), //
      child: Padding(
        padding: const EdgeInsets.all(12.0), //
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, //
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, //
              children: [
                Expanded(
                  child: Text(
                    '${course['name']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface), //
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: theme.colorScheme.primary), //
                  onPressed: () => _startEditCourse(index), //
                  tooltip: 'Edit Course', //
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: theme.colorScheme.error), //
                  onPressed: () => _removeCourse(index), //
                  tooltip: 'Delete Course', //
                ),
              ],
            ),
            const SizedBox(height: 8), //
            Text('Credit Hours: ${course['creditHours']}',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.8))), //
            Text('Letter Grade: $letterGrade (Score: $grade)',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.8))), //
            Slider(
              value: grade.toDouble(), //
              min: 0, //
              max: 100, //
              divisions: 100, //
              label: grade.toString(), //
              activeColor: theme.colorScheme.primary, //
              inactiveColor: theme.colorScheme.primary.withOpacity(0.3), //
              onChanged: (double newValue) {
                setState(() {
                  _courses[index]['grade'] = newValue.toInt(); //
                  _calculateSGPAAndCGPA(); //
                });
              }, //
            ),
          ],
        ),
      ),
    );
  }

  void _startEditCourse(int index) {
    setState(() {
      _editingCourseIndex = index; //
      final course = _courses[index]; //
      _courseNameController.text = course['name']; //
      _creditHoursController.text = course['creditHours'].toString(); //
      // Grade is edited via the slider directly in the Card for that course.
    });
  }

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index); //
      _calculateSGPAAndCGPA(); //
      if (_editingCourseIndex == index) {
        // If deleting the course being edited
        _cancelEdit(); //
      } else if (_editingCourseIndex != null && _editingCourseIndex! > index) {
        _editingCourseIndex = _editingCourseIndex! -
            1; // Adjust index if deleting before current edit target
      }
    });
  }

  void _submitCourse() {
    String courseName = _courseNameController.text.trim(); //
    double? creditHours = double.tryParse(_creditHoursController.text); //
    if (courseName.isEmpty || creditHours == null || creditHours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please enter valid course name and positive credit hours.')), //
      );
      return; //
    }

    setState(() {
      if (_editingCourseIndex != null) {
        // Update existing course
        _courses[_editingCourseIndex!]['name'] = courseName; //
        _courses[_editingCourseIndex!]['creditHours'] = creditHours; //
        // Grade is already updated by its own slider in the list
      } else {
        // Add new course
        _courses.add({
          'name': courseName, //
          'creditHours': creditHours, //
          'grade': 0, // Default grade for new course
        });
      }
      _calculateSGPAAndCGPA(); //
      _courseNameController.clear(); //
      _creditHoursController.clear(); //
      _editingCourseIndex = null; // Reset editing state
    });
  }

  void _cancelEdit() {
    setState(() {
      _courseNameController.clear(); //
      _creditHoursController.clear(); //
      _editingCourseIndex = null; //
    });
  }

  String _calculateLetterGrade(int grade) {
    if (grade >= 91) return 'A+'; //
    if (grade >= 86) return 'A'; //
    if (grade >= 81) return 'A-'; //
    if (grade >= 76) return 'B+'; //
    if (grade >= 71) return 'B'; //
    if (grade >= 66) return 'B-'; //
    if (grade >= 61) return 'C+'; //
    if (grade >= 50) return 'C'; //
    if (grade >= 45) return 'C-'; //
    if (grade >= 40) return 'D'; //
    return 'F'; //
  }

  double _calculateGradePoints(int grade) {
    if (grade >= 91) return 4.0; //
    if (grade >= 86) return 4.0; //
    if (grade >= 81) return 3.75; //
    if (grade >= 76) return 3.5; //
    if (grade >= 71) return 3.0; //
    if (grade >= 66) return 2.75; //
    if (grade >= 61) return 2.5; //
    if (grade >= 50) return 2.0; //
    if (grade >= 45) return 1.75; //
    if (grade >= 40) return 1.0; //
    return 0.0; //
  }

  void _calculateSGPAAndCGPA() {
    double totalSemesterCreditHours = 0; //
    double totalSemesterGradePoints = 0; //
    for (var course in _courses) {
      totalSemesterCreditHours += course['creditHours']; //
      totalSemesterGradePoints +=
          course['creditHours'] * _calculateGradePoints(course['grade']); //
    }
    double sgpa = totalSemesterCreditHours > 0
        ? totalSemesterGradePoints / totalSemesterCreditHours
        : 0.0; //
    double previousCGPA =
        double.tryParse(_previousCGPAController.text) ?? 0.0; //
    int previousCreditHours =
        int.tryParse(_previousCreditHoursController.text) ?? 0; //

    double totalCumulativeCreditHours =
        previousCreditHours + totalSemesterCreditHours; //
    double totalCumulativeGradePoints =
        (previousCGPA * previousCreditHours) + totalSemesterGradePoints; //
    double cgpa = totalCumulativeCreditHours > 0
        ? totalCumulativeGradePoints / totalCumulativeCreditHours
        : 0.0; //
    if (mounted) {
      setState(() {
        _sgpa = sgpa; //
        _cgpa = cgpa; //
      });
    }
  }

  Future<void> _saveData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance(); //

    // Always attempt to save, the overwrite check is handled by the dialog
    // if data already exists.
    bool dataExists = prefs.containsKey('courses'); //

    if (dataExists) {
      bool? overwrite = await showDialog<bool>(
        context: context, //
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Overwrite Data?'), //
          content: const Text(
              'Saved data already exists. Do you want to overwrite it?'), //
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), //
              child: const Text('Cancel'), //
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true), //
              child: const Text('Overwrite'), //
            ),
          ],
        ),
      );
      if (overwrite != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Save operation cancelled.')), //
          );
          Navigator.pop(context); // Close drawer
        }
        return; // Do not save
      }
    }

    List<String> courseData = _courses.map((course) {
      return '${course['name']},${course['creditHours']},${course['grade']}'; //
    }).toList();
    await prefs.setStringList('courses', courseData); //
    await prefs.setDouble('previousCGPA',
        double.tryParse(_previousCGPAController.text) ?? 0.0); //
    await prefs.setInt('previousCreditHours',
        int.tryParse(_previousCreditHoursController.text) ?? 0); //

    String currentTimestamp =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()); //
    await prefs.setString('lastSavedTimestamp', currentTimestamp); //

    if (mounted) {
      setState(() {
        _lastSavedTimestamp = currentTimestamp; // Update UI immediately
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully.')), //
      );
      Navigator.pop(context); // Close drawer after saving
    }
  }

  Future<void> _loadData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance(); //
    List<String>? courseData = prefs.getStringList('courses'); //
    double previousCGPA = prefs.getDouble('previousCGPA') ?? 0.0; //
    int previousCreditHours = prefs.getInt('previousCreditHours') ?? 0; //
    String? loadedTimestamp = prefs.getString('lastSavedTimestamp'); //

    if (courseData != null) {
      List<Map<String, dynamic>> loadedCourses = courseData.map((courseString) {
        List<String> parts = courseString.split(','); //
        return {
          'name': parts[0], //
          'creditHours': double.parse(parts[1]), //
          'grade': int.parse(parts[2]), //
        };
      }).toList();
      if (mounted) {
        setState(() {
          _courses = loadedCourses; //
          _previousCGPAController.text = previousCGPA.toString(); //
          _previousCreditHoursController.text =
              previousCreditHours.toString(); //
          _lastSavedTimestamp = loadedTimestamp; //
          _calculateSGPAAndCGPA(); //
          _cancelEdit(); // Ensure edit mode is reset on load
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data loaded successfully.')), //
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No saved data found.')), //
        );
      }
    }
    if (mounted) {
      Navigator.pop(context); // Close drawer after loading
    }
  }
}
