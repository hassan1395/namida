import 'package:flutter/material.dart';

import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:share_plus/share_plus.dart';

import 'package:namida/class/youtube_id.dart';
import 'package:namida/controller/miniplayer_controller.dart';
import 'package:namida/controller/player_controller.dart';
import 'package:namida/core/enums.dart';
import 'package:namida/core/extensions.dart';
import 'package:namida/core/icon_fonts/broken_icons.dart';
import 'package:namida/core/translations/language.dart';
import 'package:namida/ui/widgets/custom_widgets.dart';
import 'package:namida/youtube/functions/add_to_playlist_sheet.dart';
import 'package:namida/youtube/functions/download_sheet.dart';
import 'package:namida/youtube/widgets/yt_card.dart';

class YoutubeVideoCard extends StatelessWidget {
  final StreamInfoItem? video;
  const YoutubeVideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final videoId = video?.id ?? '';
    return YoutubeCard(
      borderRadius: 12.0,
      videoId: video?.id,
      thumbnailUrl: null,
      shimmerEnabled: video == null,
      title: video?.name ?? '',
      subtitle: [
        video?.viewCount?.formatDecimalShort() ?? 0,
        if (video?.uploadDate != null) video?.uploadDate,
      ].join(' - '),
      thirdLineText: video?.uploaderName ?? '',
      onTap: () {
        if (video?.id != null) {
          final st = MiniPlayerController.inst.ytMiniplayerKey.currentState;
          if (st != null) st.animateToState(true);

          Player.inst.playOrPause(
            0,
            [YoutubeID(id: videoId)],
            QueueSource.others,
          );

          // if the miniplayer wasnt already active, we wait till the queue get filled (i.e. miniplayer gets a state)
          // it would be better if we had a callback instead of waiting 100ms.
          // since awaiting [playOrPause] would take quite long.
          if (st == null) {
            Future.delayed(
              const Duration(milliseconds: 100),
              () => MiniPlayerController.inst.ytMiniplayerKey.currentState?.animateToState(true),
            );
          }
        }
      },
      channelThumbnailUrl: video?.uploaderAvatarUrl,
      displayChannelThumbnail: true,
      smallBoxText: video?.duration?.inSeconds.secondsLabel,
      smallBoxIcon: null,
      menuChildrenDefault: [
        NamidaPopupItem(
          icon: Broken.music_library_2,
          title: lang.ADD_TO_PLAYLIST,
          onTap: () {
            showAddToPlaylistSheet(ids: [videoId], idsNamesLookup: {videoId: video?.name});
          },
        ),
        NamidaPopupItem(
          icon: Broken.import,
          title: lang.DOWNLOAD,
          onTap: () {
            showDownloadVideoBottomSheet(
              videoId: videoId,
            );
          },
        ),
        NamidaPopupItem(
          icon: Broken.share,
          title: lang.SHARE,
          onTap: () {
            final url = video?.url;
            if (url != null) Share.share(url);
          },
        ),
        NamidaPopupItem(
          icon: Broken.next,
          title: lang.PLAY_NEXT,
          onTap: () {
            Player.inst.addToQueue([YoutubeID(id: videoId)], insertNext: true);
          },
        ),
        NamidaPopupItem(
          icon: Broken.play_cricle,
          title: lang.PLAY_LAST,
          onTap: () {
            Player.inst.addToQueue([YoutubeID(id: videoId)], insertNext: false);
          },
        ),
      ],
    );
  }
}
