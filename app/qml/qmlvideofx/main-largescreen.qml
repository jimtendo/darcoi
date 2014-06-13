/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Qt Mobility Components.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0

Rectangle {
    id: root
    color: "black"
    property string fileName
    property alias volume: content.volume
    property bool perfMonitorsLogging: false
    property bool perfMonitorsVisible: false
    property real rmsAmplitude: 0.0

    QtObject {
        id: d
        property real gripSize: 20
    }

    Rectangle {
        id: inner
        objectName:"inner"
        anchors.fill: parent

        Content {
            id: content
            objectName: "content"
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            gripSize: d.gripSize
            width: parent.width
            height: parent.height
        }

        Loader {
            id: performanceLoader
            function init() {
                console.log("[qmlvideofx] performanceLoader.init logging " + root.perfMonitorsLogging + " visible " + root.perfMonitorsVisible)
                var enabled = root.perfMonitorsLogging || root.perfMonitorsVisible
                source = enabled ? "../performancemonitor/PerformanceItem.qml" : ""
            }
            onLoaded: {
                item.parent = content
                item.anchors.top = content.top
                item.anchors.left = content.left
                item.anchors.right = content.right
                item.logging = root.perfMonitorsLogging
                item.displayed = root.perfMonitorsVisible
                item.init()
            }
        }

        ParameterPanel {
            id: parameterPanel
            anchors {
                left: tuningPanel.right
                bottom: parent.bottom
                right: effectSelectionPanel.left
                margins: 20
            }
            gripSize: d.gripSize
        }

        TuningPanel {
            id: tuningPanel
            objectName: "tuningPanel"
            color:"black"
            textColor:"white"
            opacity:0.5
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width:200

            Behavior on width  {
               NumberAnimation  { duration: 500 }
            }
        }

        FileOpen {
            id: fileOpen
            color:"black"
            opacity:0.5
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            width: 0
            buttonHeight: 32
            topMargin: 10

            Behavior on width  {
               NumberAnimation  { duration: 500 }
            }
        }
    }

    MouseArea {
        id: tuningOptions
        anchors {
            top: parent.top
            left: parent.left
        }
        width:10
        height:10
        onClicked: {
            if (tuningPanel.width) {
                tuningPanel.width = 0
            } else {
                tuningPanel.width = 200
            }
        }
    }

    MouseArea {
        id: options
        anchors {
            top: parent.top+10
            right: parent.right
        }
        width:10
        height:10
        onClicked: {
            if (fileOpen.width) {
                fileOpen.width = 0
            } else {
                fileOpen.width = 200
            }
        }
    }

    MouseArea {
        id: parametersOptions
        anchors {
            bottom: parent.bottom
        }
        width:parent.width
        height:10
        onClicked: {
            if (parametersPanel.visible) {
                parametersPanel.visible = false
            } else {
                parametersPanel.visible = true
            }
        }
    }

    FileBrowser {
        id: imageFileBrowser
        anchors.fill: root
        Component.onCompleted: fileSelected.connect(content.openImage)
    }

    FileBrowser {
        id: videoFileBrowser
        anchors.fill: root
        Component.onCompleted: fileSelected.connect(content.openVideo)
    }

    Component.onCompleted: {
        fileOpen.openImage.connect(openImage)
        fileOpen.openVideo.connect(openVideo)
        fileOpen.openCamera.connect(openCamera)
        fileOpen.close.connect(close)
    }

    function init() {
        console.log("[qmlvideofx] main.init")
        imageFileBrowser.folder = imagePath
        videoFileBrowser.folder = videoPath
        content.init()
        performanceLoader.init()
        if (fileName != "")
            content.openVideo(fileName)
    }

    function qmlFramePainted() {
        if (performanceLoader.item)
            performanceLoader.item.qmlFramePainted()
    }

    function openImage() {
        imageFileBrowser.show()
    }

    function openVideo() {
        videoFileBrowser.show()
    }

    function openCamera() {
        content.openCamera()
    }

    function close() {
        onClicked: Qt.quit()
    }

    function changeParameter(rms, peak, samples) {
	tuningPanel.volume = rms * 100 + 1
        rmsAmplitude = rms
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
        content.effect.amplitude = bar * 1.0 + amplitude;

        // Wobble Effect
        if (content.effect.amplitude > tuningPanel.wobbleThreshold) {
            content.effect.wobbleAmplitude = (content.effect.amplitude - tuningPanel.wobbleThreshold)/10 * 0.40 * tuningPanel.wobbleMultiplier
            content.effect.wobbleDegree = (content.effect.amplitude - tuningPanel.wobbleThreshold)/10 * tuningPanel.wobbleMultiplier
        } else {
            content.effect.wobbleAmplitude = 0.0
            content.effect.wobbleDegree = 0.0
        }

        // Grey Effect
        if (content.effect.amplitude > tuningPanel.greyThreshold) {
            content.effect.greyOn = 1.0
            content.effect.greyBrightness = tuningPanel.greyBrightness
        } else {
            content.effect.greyOn = 0.0
        }

        // Brighten Effect
        if (content.effect.amplitude > tuningPanel.brightenThreshold) {
            content.effect.brightenDegree = (content.effect.amplitude - tuningPanel.brightenThreshold)/10 * 10 + 1.0
        } else {
            content.effect.brightenDegree = 1.0
        }
    }
}
