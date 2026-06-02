class SundaySchoolScreen extends StatefulWidget {
  const SundaySchoolScreen({Key? key}) : super(key: key);

  @override
  State<SundaySchoolScreen> createState() => _SundaySchoolScreenState();
}

class _SundaySchoolScreenState extends State<SundaySchoolScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SundaySchoolProvider>().fetchLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunday School'),
        elevation: 0,
      ),
      body: Consumer<SundaySchoolProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.lessons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.lessons.isEmpty) {
            return const Center(child: Text('No lessons available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.lessons.length,
            itemBuilder: (context, index) {
              final lesson = provider.lessons[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SundaySchoolDetailScreen(lesson: lesson),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                lesson.ageGroup,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('MMM dd, yyyy').format(lesson.lessonDate),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'by ${lesson.teacherName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          lesson.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (lesson.notes != null && lesson.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.note, size: 16),
                                const SizedBox(width: 4),
                                Text('${lesson.notes!.length} notes'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create lesson screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SundaySchoolDetailScreen extends StatefulWidget {
  final SundaySchoolLesson lesson;

  const SundaySchoolDetailScreen({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  State<SundaySchoolDetailScreen> createState() => _SundaySchoolDetailScreenState();
}

class _SundaySchoolDetailScreenState extends State<SundaySchoolDetailScreen> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.lesson.ageGroup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(widget.lesson.lessonDate),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Title
            Text(
              widget.lesson.title,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 8),
            
            // Teacher
            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 8),
                Text('Teacher: ${widget.lesson.teacherName}'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.lesson.description),
            
            const SizedBox(height: 24),
            
            // Content
            Text(
              'Lesson Content',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.lesson.lessonContent),
            
            const SizedBox(height: 24),
            
            // Add Note Section
            Text(
              'Add Your Notes',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Write a note...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_noteController.text.isNotEmpty) {
                      context.read<SundaySchoolProvider>().addNote(
                        widget.lesson.id,
                        _noteController.text,
                      );
                      _noteController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Note added')),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notes List
            if (widget.lesson.notes != null && widget.lesson.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Notes (${widget.lesson.notes!.length})',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...widget.lesson.notes!.map((note) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.content,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('MMM dd, yyyy - hh:mm a')
                                  .format(note.createdAt),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
