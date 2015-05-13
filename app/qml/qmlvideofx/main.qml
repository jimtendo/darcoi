import QtQuick 2.2
import QtMultimedia 5.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0
import QtQuick.Controls.Styles 1.1

Rectangle {
    id: root
    color: "black"
    width: 800
    height: 600
    property real rmsAmplitude: 0.0

    MediaPlayer {
        id: mediaPlayer
        autoPlay: true
        volume: 0.5
        loops: Audio.Infinite
        source:"rtsp://192.168.1.80:554/ipcam_mjpeg.sdp"
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        source: mediaPlayer
    }

    ShaderEffect {
        id: shaderEffect
        anchors.fill: videoOutput

        property variant source: ShaderEffectSource { sourceItem: videoOutput; hideSource: true }
        property real time: 0
        property real volume: 0
        property real frequency: 0

        NumberAnimation on time { loops: Animation.Infinite; from: 0; to: 2; duration: 1000 }

        fragmentShader: ""
    }

    /*EffectPanel {
        id: effectPanel
        opacity:0.7;
    }*/

    MouseArea {
        id: toggleEditor
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 10
        height: 10
        onClicked: {
            editorDialog.visible = !editorDialog.visible
        }
    }

    Rectangle {
        id: editorDialog
        width:parent.width
        height:200
        anchors.bottom: parent.bottom
        color: "#111"
        opacity: 0.9
        visible: true

        TextArea {
            id: effectEditor
            x: 10
            y: 10
            width: parent.width - x * 2
            height: parent.height - y * 2 - 25
            text: ""
            style: TextAreaStyle {
                textColor: "#FFF"
                selectionColor: "steelblue"
                selectedTextColor: "#eee"
                backgroundColor: "#393939"
            }
        }

        Button {
            text: "Apply Effect"
            y: 5
            height:25
            anchors.right: effectEditor.right
            anchors.top: effectEditor.bottom
            onClicked: {
                shaderEffect.fragmentShader = "
                    varying highp vec2 qt_TexCoord0;
                    uniform sampler2D source;
                    uniform float time;
                    uniform float volume;
                    uniform float frequency;

                    vec4 getPixelAt(float x, float y)
                    {
                        return texture2D(source, vec2(x, y));
                    }

                    void main(void)
                    {
                        vec2 position = qt_TexCoord0.xy;
                        vec4 pixel = texture2D(source, position);
                    "
                    + effectEditor.text +
                    "
                        gl_FragColor = pixel;
                    }"
            }
        }

        Button {
            text: "Open Video"
            y: 5
            height:25
            anchors.left: effectEditor.left
            anchors.top: effectEditor.bottom
            onClicked: {
                fileBrowser.show()
            }
        }

        Behavior on height  {
           NumberAnimation  { duration: 500 }
        }
    }

    TuningPanel {
        id: tuningPanel
        objectName: "tuningPanel"
        color:"black"
        textColor:"white"
        opacity:0.5
        anchors {
            top: parent.top
            bottom: editorDialog.top
            left: parent.left
        }
        width:200

        Behavior on width  {
           NumberAnimation  { duration: 500 }
        }
    }

    MouseArea {
        id: parametersOptions
        anchors {
            top: parent.top
            left: parent.left
        }
        width:10
        height:10
        onClicked: {
            tuningPanel.visible = !tuningPanel.visible
        }
    }

    FileBrowser {
        id: fileBrowser
        folder: "file://home/"
        anchors.fill: root
        onFileSelected: {
            mediaPlayer.source = file
        }
    }

    function levelChanged(rms, peak, samples) {
        tuningPanel.volume = rms * 100 + 1
        shaderEffect.volume = rms
    }

    function spectrumChanged(bar0, bar1, bar2, bar3, bar4, bar5, bar6, bar7, bar8, bar9) {
        tuningPanel.spectrum0 = bar0 * 100 + 1
        tuningPanel.spectrum1 = bar1 * 100 + 1
        tuningPanel.spectrum2 = bar2 * 100 + 1
        tuningPanel.spectrum3 = bar3 * 100 + 1
        tuningPanel.spectrum4 = bar4 * 100 + 1
        tuningPanel.spectrum5 = bar5 * 100 + 1
        tuningPanel.spectrum6 = bar6 * 100 + 1
        tuningPanel.spectrum7 = bar7 * 100 + 1
        tuningPanel.spectrum8 = bar8 * 100 + 1
        tuningPanel.spectrum9 = bar9 * 100 + 1
    }

    function dominantBarChanged(bar, amplitude) {
        shaderEffect.frequency = bar * 1.0 + amplitude;
    }
}
