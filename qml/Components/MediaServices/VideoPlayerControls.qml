import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

MediaServicesControls {
    id: root
    readonly property alias mediaPlayer: _mediaPlayer
    property bool interacting: false

    QtObject {
        id: priv

        function formatProgress(time) {
            time = Math.floor(time / 1000);

            var secs = time % 60;
            time = Math.floor(time / 60);
            var min = time % 60;
            var hour = Math.floor(time / 60);

            if (secs < 10) secs = "0%1".arg(secs);
            if (min < 10) min = "0%1".arg(min);
            if (hour > 0) {
                // TRANSLATORS: this refers to a duration/remaining time of the video in hours, minutes and seconds,
                // of which you can change the order.
                // %1 refers to hours, %2 refers to minutes and %3 refers to seconds.
                return  i18n.tr("%1:%2:%3").arg(hour).arg(min).arg(secs);
            } else {
                // TRANSLATORS: this refers to a duration/remaining time of the video in minutes and seconds,
                // of which you can change the order.
                // %1 refers to minutes and %2 refers to seconds.
                return  i18n.tr("%1:%2").arg(min).arg(secs);
            }
        }
    }

    component: Item {
        Connections {
            target: mediaPlayer
            onPositionChanged: {
                if (slider.valueGuard) return;

                slider.valueGuard = true;
                slider.value = mediaPlayer.position;
                slider.valueGuard = false;
                if (!slider.pressed) {
                    positionLabel.text = priv.formatProgress(mediaPlayer.position);
                }
            }
        }

        Binding {
            target: root
            property: "interacting"
            value: slider.pressed
        }

        Label {
            id: positionLabel
            anchors {
                left: parent.left
                bottom: parent.bottom
                bottomMargin: -units.dp(3)
            }
            verticalAlignment: Text.AlignBottom
            fontSize: "x-small"
            color: "#F3F3E7"

            text: priv.formatProgress(mediaPlayer.position)
        }

        Slider {
            id: slider
            property bool valueGuard: false

            anchors {
                left: parent.left
                right: parent.right
            }
            height: units.gu(2)
            live: true
            enabled: mediaPlayer.seekable && mediaPlayer.duration > 0
            minimumValue: 0
            maximumValue:  mediaPlayer.duration > 0 ? mediaPlayer.duration : 1
            value: mediaPlayer.position
            theme: ThemeSettings {
                palette: Palette {
                    normal.base: "#F3F3E7"
                }
            }

            onValueChanged: {
                if (!pressed) return;
                if (slider.valueGuard) return;

                slider.valueGuard = true;
                mediaPlayer.seek(value);
                slider.valueGuard = false;
            }

            property bool wasPlaying: mediaPlayer.playbackState === MediaPlayer.PlayingState
            onPressedChanged: {
                if (pressed) {
                    wasPlaying = mediaPlayer.playbackState === MediaPlayer.PlayingState
                    mediaPlayer.pause();
                } else {

                    positionLabel.text = priv.formatProgress(mediaPlayer.position);
                    if (wasPlaying) {
                        mediaPlayer.play();
                    }
                }
            }

            function formatValue(value) {
                return priv.formatProgress(value);
            }
        }

        Label {
            anchors {
                right: parent.right
                bottom: parent.bottom
                bottomMargin: -units.dp(3)
            }
            verticalAlignment: Text.AlignBottom
            fontSize: "x-small"
            color: "#F3F3E7"

            text: priv.formatProgress(mediaPlayer.duration)
        }
    }

    function getPlaybackState(playbackState) {
        if (playbackState === MediaPlayer.PlayingState) return "PlayingState";
        else if (playbackState === MediaPlayer.PausedState) return "PausedState";
        else if (playbackState === MediaPlayer.StoppedState) return "StoppedState";
        return "";
    }

    function getPlayerStatus(status) {
        if (status === MediaPlayer.NoMedia) return "NoMedia";
        else if (status === MediaPlayer.Loading) return "Loading";
        else if (status === MediaPlayer.Loaded) return "Loaded";
        else if (status === MediaPlayer.Buffering) return "Buffering";
        else if (status === MediaPlayer.Stalled) return "Stalled";
        else if (status === MediaPlayer.Buffered) return "Buffered";
        else if (status === MediaPlayer.EndOfMedia) return "EndOfMedia";
        else if (status === MediaPlayer.InvalidMedia) return "InvalidMedia";
        else if (status === MediaPlayer.UnknownStatus) return "UnknownStatus";
        return "";
    }

    MediaPlayer {
        id: _mediaPlayer
        objectName: "mediaPlayer"

        onError: {
            if (error !== MediaPlayer.NoError) {
                stop();
            }
        }
//        onPlaybackStateChanged: console.log("PLAYBACK STATE CHANGED", getPlaybackState(playbackState));
//        onStatusChanged: console.log("PLAYER STATUS CHANGED", getPlayerStatus(status));
    }
}
