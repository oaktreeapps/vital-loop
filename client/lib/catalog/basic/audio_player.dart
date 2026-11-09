// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../shared/catalog_item.dart';
import '../shared/data_binding.dart';
import 'basic_schemas.dart';
import 'format_duration.dart';

final Logger _log = Logger('AudioPlayer');

/// An audio player for the audio at `url`, with an optional `description`
/// above its play button, position and volume.
final CatalogItem audioPlayer = CatalogItem(
  name: 'AudioPlayer',
  description: 'An audio player component that plays audio from a given URL.',
  schemaIsComplete: true,
  dataSchema: basicSchema('AudioPlayer', (properties, _) {
    properties['description'] = {
      r'$ref': r'common_types.json#/$defs/DynamicString',
    };
  }),
  widgetBuilder: (itemContext) {
    final JsonMap data = itemContext.data;
    return BoundString(
      dataContext: itemContext.dataContext,
      value: data['url'],
      builder: (context, urlValue) => BoundString(
        dataContext: itemContext.dataContext,
        value: data['description'],
        builder: (context, descriptionValue) =>
            _AudioPlayerWidget(url: urlValue, description: descriptionValue),
      ),
    );
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "AudioPlayer",
          "url": "https://upload.wikimedia.org/wikipedia/commons/d/db/Minuet_in_G_%28Beethoven%29%2C_piano.ogg",
          "description": "Beethoven — Minuet in G (public domain)"
        }
      ]
    ''',
  ],
);

class _AudioPlayerWidget extends StatefulWidget {
  const _AudioPlayerWidget({required this.url, this.description});

  final String? url;
  final String? description;

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  late final ap.AudioPlayer _player;
  late final List<StreamSubscription<dynamic>> _subscriptions;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _player = ap.AudioPlayer();
    _player.setVolume(_volume);

    void onStreamError(Object error, StackTrace stackTrace) {
      _log.warning('Audio player stream error', error, stackTrace);
    }

    _subscriptions = [
      _player.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == ap.PlayerState.playing;
          });
        }
      }, onError: onStreamError),
      _player.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() => _position = position);
        }
      }, onError: onStreamError),
      _player.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() => _duration = duration);
        }
      }, onError: onStreamError),
    ];

    _setSource();
  }

  @override
  void didUpdateWidget(_AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _player.stop();
      _position = Duration.zero;
      _duration = Duration.zero;
      _setSource();
    }
  }

  void _setSource() {
    final String? url = widget.url;
    if (url != null && url.isNotEmpty) {
      _player.setSource(ap.UrlSource(url)).catchError((Object error) {
        _log.warning('Failed to set audio source: $url', error);
      });
    }
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> sub in _subscriptions) {
      sub.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const contentPadding = EdgeInsets.all(12);

    return Card(
      child: Padding(
        padding: contentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.description != null && widget.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.description!,
                  style: theme.textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: widget.url != null && widget.url!.isNotEmpty
                      ? () {
                          if (_isPlaying) {
                            _player.pause();
                          } else {
                            _player.resume();
                          }
                        }
                      : null,
                ),
                Text(
                  formatDuration(_position),
                  style: theme.textTheme.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds
                              .clamp(0, _duration.inMilliseconds)
                              .toDouble()
                        : 0,
                    max: _duration.inMilliseconds > 0
                        ? _duration.inMilliseconds.toDouble()
                        : 1,
                    onChanged: (value) {
                      _player.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
                Text(
                  formatDuration(_duration),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Icon(
                  _volume == 0
                      ? Icons.volume_off
                      : _volume < 0.5
                      ? Icons.volume_down
                      : Icons.volume_up,
                  size: 20,
                ),
                SizedBox(
                  width: 100,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      overlayShape: SliderComponentShape.noOverlay,
                      padding: EdgeInsets.zero,
                    ),
                    child: Slider(
                      value: _volume,
                      onChanged: (value) {
                        setState(() => _volume = value);
                        _player.setVolume(value);
                      },
                    ),
                  ),
                ),
                SizedBox(width: contentPadding.right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
