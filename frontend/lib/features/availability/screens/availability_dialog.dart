import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/availability/data/availability_repository.dart';

class AvailabilityDialog extends StatefulWidget {
  const AvailabilityDialog({super.key});

  @override
  State<AvailabilityDialog> createState() => _AvailabilityDialogState();
}

class _AvailabilityDialogState extends State<AvailabilityDialog> {
  int day = 1;

  TimeOfDay start = const TimeOfDay(hour: 9, minute: 0);

  TimeOfDay end = const TimeOfDay(hour: 12, minute: 0);

  Future<void> pickStart() async {
    final result = await showTimePicker(context: context, initialTime: start);

    if (result != null) {
      setState(() => start = result);
    }
  }

  Future<void> pickEnd() async {
    final result = await showTimePicker(context: context, initialTime: end);

    if (result != null) {
      setState(() => end = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AvailabilityRepository>();

    return AlertDialog(
      title: const Text('Interview Availability'),

      content: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          DropdownButton<int>(
            value: day,

            items: [
              for (int i = 1; i <= 7; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(
                    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1],
                  ),
                ),
            ],

            onChanged: (v) {
              setState(() => day = v!);
            },
          ),

          ListTile(
            title: Text("Start: ${start.format(context)}"),

            onTap: pickStart,
          ),

          ListTile(title: Text("End: ${end.format(context)}"), onTap: pickEnd),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),

          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: () async {
            await repo.save(
              dayOfWeek: day,

              startTime: "${start.hour}:${start.minute}",

              endTime: "${end.hour}:${end.minute}",
            );

            if (context.mounted) {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Availability saved')),
              );
            }
          },

          child: const Text('Save'),
        ),
      ],
    );
  }
}
