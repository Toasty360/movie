import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movie/extractors/catflix.dart';
import 'package:movie/extractors/embed2.dart';
import 'package:movie/extractors/vidlink.dart';
import 'package:movie/extractors/vidsrcNet.dart';
import 'package:movie/extractors/vidsrcPro.dart';
import 'package:movie/model/model.dart';
import 'package:movie/model/service_provider.dart';

// Function to show the task dialog
Future<MediaData> showTaskDialog(
  Episode episode,
  BuildContext context,
) async {
  final result = await showDialog<MediaData>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: TaskSelector(episode: episode),
      );
    },
  );

  // Provide a fallback in case the result is null
  return result ??
      MediaData(
        provider: SrcProvider.none,
        qualities: [],
        headers: {},
        src: "",
        subtitles: [],
      );
}

class TaskSelector extends StatefulWidget {
  final Episode episode;
  const TaskSelector({super.key, required this.episode});

  @override
  _TaskSelectorState createState() => _TaskSelectorState();
}

class _TaskSelectorState extends State<TaskSelector> {
  @override
  void initState() {
    super.initState();
    findSource();
  }

  final ScrollController _scrollController = ScrollController();
  int selectedIndex = 0;
  MediaData data = MediaData(
      provider: SrcProvider.none,
      qualities: [],
      headers: {},
      src: "",
      subtitles: []);

  int itHasData = -1;
  final List<ServiceProvider> providers = kIsWeb
      ? [
          VidLink(),
          VidsrcNet(),
          Embed2(),
          Catflix(),
          VidsrcPro(),
        ]
      : [
          VidsrcNet(),
          VidsrcPro(),
          Catflix(),
          Embed2(),
          VidLink(),
        ];

  void findSource() async {
    for (int i = 0; i < providers.length; i++) {
      setState(() {
        selectedIndex = i;
      });
      print([
        widget.episode.id,
        widget.episode.title,
        widget.episode.season,
        widget.episode.episode
      ]);
      try {
        data = widget.episode.season == null
            ? await providers[i]
                .getSource(widget.episode.id, true, title: widget.episode.title)
            : await providers[i].getSource(widget.episode.id, false,
                season: widget.episode.season,
                episode: widget.episode.episode,
                title: widget.episode.title);
        print(data.src.split(":").last);
        // await Future.delayed(Duration(minutes: 10));
        setState(() {
          itHasData = i;
        });
        _close();

        break;
      } catch (e) {
        if (mounted) {
          _scrollToNext(i);
        }
      }
    }
  }

  void _close() {
    Navigator.pop(context, data);
  }

  void _scrollToNext(int nextIndex) {
    _scrollController.animateTo(
      nextIndex * 70.0, // Adjust based on item height
      duration:
          const Duration(milliseconds: 500), // Slower scroll for visibility
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(16.0),
      height: screen.width > 700 ? screen.height * 0.4 : 300,
      width: screen.width * 0.5,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: providers.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: leadingWidgetShit(selectedIndex, index, itHasData),
            title: Text(
              providers[index].getProviderName(),
              style: TextStyle(
                color: selectedIndex == index ? Colors.white : Colors.grey,
              ),
            ),
            subtitle: selectedIndex == index
                ? itHasData == index
                    ? const Text("Successful")
                    : const Text('Checking for videos...')
                : null,
            onTap: () => {}, // No action on tap for now
          );
        },
      ),
    );
  }
}

Widget leadingWidgetShit(int selectedIndex, int index, int itHasData) {
  const double iconSize =
      20.0; // Define a consistent size for both icon and progress indicator

  if (selectedIndex == index) {
    return const Padding(
      padding: EdgeInsets.all(4),
      child: SizedBox(
        width: iconSize - 2,
        height: iconSize - 2,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  } else {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Icon(
        itHasData == index
            ? Icons.check_circle
            : selectedIndex > index
                ? Icons.cancel
                : Icons.radio_button_unchecked,
        size: iconSize, // Ensure the icon matches the size
        color: itHasData == index
            ? Colors.green
            : selectedIndex > index
                ? Colors.red
                : Colors.grey,
      ),
    );
  }
}
