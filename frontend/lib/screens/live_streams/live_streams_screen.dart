class LiveStreamsScreen extends StatefulWidget {
  const LiveStreamsScreen({Key? key}) : super(key: key);

  @override
  State<LiveStreamsScreen> createState() => _LiveStreamsScreenState();
}

class _LiveStreamsScreenState extends State<LiveStreamsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LiveStreamProvider>().fetchLiveStreams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Streams'),
        elevation: 0,
      ),
      body: Consumer<LiveStreamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.streams.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.streams.isEmpty) {
            return const Center(child: Text('No live streams available'));
          }

          // Separate active and past streams
          final activeStreams = provider.streams
              .where((s) => s.isActive)
              .toList();
          final pastStreams = provider.streams
              .where((s) => !s.isActive)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Active Streams
              if (activeStreams.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Now',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...activeStreams.map((stream) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveStreamPlayerScreen(
                                stream: stream,
                              ),
                            ),
                          );
                        },
                        child: _LiveStreamCard(stream: stream, isLive: true),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],
                ),

              // Past Streams
              if (pastStreams.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Past Streams',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...pastStreams.map((stream) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveStreamPlayerScreen(
                                stream: stream,
                              ),
                            ),
                          );
                        },
                        child: _LiveStreamCard(stream: stream, isLive: false),
                      );
                    }).toList(),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LiveStreamCard extends StatelessWidget {
  final LiveStream stream;
  final bool isLive;

  const _LiveStreamCard({
    required this.stream,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Thumbnail
          if (stream.thumbnail != null)
            CachedNetworkImage(
              imageUrl: stream.thumbnail!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
            )
          else
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.video_call, size: 60),
              ),
            ),

          // Live Badge
          if (isLive)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.fiber_manual_record,
                      size: 8,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Viewers Count
          Positioned(
            bottom: 12,
            left: 12,
            child: Row(
              children: [
                const Icon(Icons.visibility, size: 18, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${stream.viewersCount} watching',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Title at bottom
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stream.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  stream.streamType.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LiveStreamPlayerScreen extends StatefulWidget {
  final LiveStream stream;

  const LiveStreamPlayerScreen({
    Key? key,
    required this.stream,
  }) : super(key: key);

  @override
  State<LiveStreamPlayerScreen> createState() => _LiveStreamPlayerScreenState();
}

class _LiveStreamPlayerScreenState extends State<LiveStreamPlayerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LiveStreamProvider>().joinStream(widget.stream.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Video Player
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.black,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.stream.thumbnail ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.video_call, size: 80, color: Colors.white),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.stream.title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            if (widget.stream.isActive)
                              const Row(
                                children: [
                                  Icon(Icons.fiber_manual_record,
                                    size: 8,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 4),
                                  Text('LIVE', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // Viewers
                      Column(
                        children: [
                          const Icon(Icons.visibility),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.stream.viewersCount}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  if (widget.stream.description != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.stream.description!),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Implement share functionality
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
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
}
