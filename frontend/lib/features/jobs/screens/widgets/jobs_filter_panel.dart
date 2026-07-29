import 'package:flutter/material.dart';

class JobsFilterPanel extends StatefulWidget {
  final Function(String search, List<String> types, String? location)? onFilterChanged;

  const JobsFilterPanel({super.key, this.onFilterChanged});

  @override
  State<JobsFilterPanel> createState() => _JobsFilterPanelState();
}

class _JobsFilterPanelState extends State<JobsFilterPanel> {
  final Set<String> _selectedTypes = {'Full-time'};
  String _selectedLocation = 'All Locations';
  double _maxSalary = 150;

  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Remote',
  ];

  final List<String> _locations = [
    'All Locations',
    'San Francisco, CA',
    'New York, NY',
    'Austin, TX',
    'Remote',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 20, color: Color(0xFF111827)),
                    SizedBox(width: 8),
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTypes.clear();
                      _selectedLocation = 'All Locations';
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFE5E7EB)),

            // Filter Section: Employment Type
            _buildSectionTitle('Employment Type'),
            const SizedBox(height: 10),
            ..._employmentTypes.map((type) {
              final isChecked = _selectedTypes.contains(type);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isChecked) {
                      _selectedTypes.remove(type);
                    } else {
                      _selectedTypes.add(type);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: isChecked,
                          activeColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedTypes.add(type);
                              } else {
                                _selectedTypes.remove(type);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Divider(height: 32, color: Color(0xFFE5E7EB)),

            // Filter Section: Location
            _buildSectionTitle('Location'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                  items: _locations.map((loc) {
                    return DropdownMenuItem(
                      value: loc,
                      child: Text(loc),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedLocation = val);
                    }
                  },
                ),
              ),
            ),

            const Divider(height: 32, color: Color(0xFFE5E7EB)),

            // Quick Stats / Info Widget matching visual cards
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '💡 Pro Tip',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Use tokens to quickly share active job postings directly with candidate pools.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4338CA),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
        letterSpacing: 0.5,
      ),
    );
  }
}