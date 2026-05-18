import 'package:flutter/material.dart';
import '../models/task.dart';
class AddScreen extends StatefulWidget {
  final Task? taskToEdit;
  const AddScreen({super.key, this.taskToEdit});
  @override
  State<AddScreen> createState() => _AddScreenState();
}
class _AddScreenState extends State<AddScreen> {
  bool _isTitleNotEmpty = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();


  String _selectedCategory = 'Work';
  DateTime _selectedDate = DateTime.now();
  String _selectedPriority = 'Low';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description;
      _selectedCategory = widget.taskToEdit!.category;
      _selectedDate = widget.taskToEdit!.date;
      _selectedPriority = widget.taskToEdit!.priority;
      _isTitleNotEmpty = true;
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              onPrimary: Colors.white, primary: Color(0xFFF3701E), onSurface: Colors.white, surface: Color(0xFF1A1A1A))
              ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //..........Esli bi tolko komentarii zelenie bili
            const Text('Task name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              onChanged: (value) => setState(() => _isTitleNotEmpty = value.trim().isNotEmpty),
              decoration: InputDecoration(
                hintText: 'Enter the task name',
                border: UnderlineInputBorder(),
                //border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0),)
              ),
            ),

            //desc
            const SizedBox(height: 25),
            const Text(
              'Description', style: TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter task description',
                
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0),),
              ),
            ),
            
            //categor
            const SizedBox(height: 25,),
            const Text('Task Category', style: TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildCategoryIcon(Icons.work, "Work", Color(0xFFF3701E)),
                const SizedBox(width:10),
                _buildCategoryIcon(Icons.person, "Personal", Color(0xFFF3701E)),
                const SizedBox(width:10),
                _buildCategoryIcon(Icons.school, "Study", Color(0xFFF3701E)),
                const SizedBox(width:10),
                _buildCategoryIcon(Icons.more_horiz, "Other", Color(0xFFF3701E)),
              ],
            ),

            //calend
            const SizedBox(height: 25,),
            const Text('To do before', style: TextStyle(fontWeight: FontWeight.bold),),
            SizedBox(height: 10),
            InkWell(
              onTap: () async {
                await _selectDate(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}", 
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey,)
                  ],
                )
              ),
            ),

            //prior
            const SizedBox(height:25),
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height:10), 
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Expanded(
            //       child: _buildPriorityChip('Low', Colors.green, true),
            //     ),
            //     const SizedBox(width: 8),
            //     Expanded(
            //       child: _buildPriorityChip('Medium', Colors.yellow, false),
            //     ),
            //     const SizedBox(width: 8),
            //     Expanded(child: _buildPriorityChip('High', Colors.red, false),
            //     ),   
            //   ],
            // ),
            Row( 
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildPriorityChip('Low', "Low", Colors.green),
                const SizedBox(width:10),
                _buildPriorityChip('Medium', "Medium", Colors.yellow),
                const SizedBox(width:10),
                _buildPriorityChip('High', "High", Colors.red),
              ],
            ),
            // const SizedBox(height:25),
            // SizedBox(
            //   width: double.infinity,
            //   height: 55,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Theme.of(context).colorScheme.primary,
            //       foregroundColor: Theme.of(context).colorScheme.onPrimary,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(15),
            //       ),
            //     ),
            //     child: const Text('Add', 
            //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            //   ),
            // ),
            
          ],
        )
      ),


      //Add button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30), 
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isTitleNotEmpty ? () {
              final newTask = Task(
                id: widget.taskToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text,
                description: _descriptionController.text,
                category: _selectedCategory,
                date: _selectedDate,
                priority: _selectedPriority,
                isCompleted: widget.taskToEdit?.isCompleted ?? false,
              );
              Navigator.pop(context, newTask);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 1.5,
                ),
              ),
            ),
            child: const Text('Add', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),

    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Color color) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() { _selectedCategory = label;});
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(50) : color.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? color : Colors.grey, width:2)
            ),
            child: Icon(icon, color: isSelected ? color : Colors.grey),
          ),
          const SizedBox(height:25),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? color : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )
          )
        ],
      ),
    );
  }
  Widget _buildPriorityChip(String label, String value, Color color) {  
    final bool isSelected = _selectedPriority == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected, 
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
      selectedColor: color.withAlpha(150),
      checkmarkColor: color,
      //padding: const EdgeInsets.symmetric(horizontal:20, vertical:8),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey.shade300,
      ),
    );
  }

//ne prigodilos
//enum Categ { work, personal, study, shopping }
}