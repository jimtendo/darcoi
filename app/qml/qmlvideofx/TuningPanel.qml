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
    color:"#eee"
    clip:true
    anchors.verticalCenter: parent.verticalCenter

    signal lowFrequencyChanged(int value);
    signal highFrequencyChanged(int value);

    property string textColor:"black"

    property double wobbleThreshold: wobbleThresholdSlider.value * 10
    property double wobbleMultiplier: wobbleMultiplierSlider.value
    
    property double greyThreshold: greyThresholdSlider.value * 10
    property double greyBrightness: greyBrightnessSlider.value

    property double brightenThreshold: brightenThresholdSlider.value * 10

    property int volume: 0
    property int spectrum0: 0
    property int spectrum1: 0
    property int spectrum2: 0
    property int spectrum3: 0
    property int spectrum4: 0
    property int spectrum5: 0
    property int spectrum6: 0
    property int spectrum7: 0
    property int spectrum8: 0
    property int spectrum9: 0

    Column {
        width:parent.width*0.8
        height:parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing:20
        Text {
             anchors.horizontalCenter: parent.horizontalCenter
             text: "<b>Spectrogram</b>"
             color:root.textColor
        }
        Row {
            id:spectrometer
            height:100
            width:parent.width
            spacing: 2
            Rectangle { id:spectrum0; color: "green"; width: parent.width/11-2; height: root.spectrum0; anchors{ bottom:parent.bottom } }
            Rectangle { id:spectrum1; color: "green"; width: parent.width/11-2; height: root.spectrum1; anchors{ bottom:parent.bottom } }
            Rectangle { id:spectrum2; color: "green"; width: parent.width/11-2; height: root.spectrum2; anchors{ bottom:parent.bottom } }
            Rectangle { id:spectrum3; color: "green"; width: parent.width/11-2; height: root.spectrum3; anchors{ bottom:parent.bottom } }
            Rectangle { id:spectrum4; color: "green"; width: parent.width/11-2; height: root.spectrum4; anchors{ bottom:parent.bottom } }
            Rectangle { id:spectrum5; color: "green"; width: parent.width/11-2; height: root.spectrum5; anchors{ bottom:parent.bottom } }
            Rectangle { id:spectrum6; color: "green"; width: parent.width/11-2; height: root.spectrum6; anchors{ bottom:parent.bottom } }
            Rectangle { id:spectrum7; color: "green"; width: parent.width/11-2; height: root.spectrum7; anchors{ bottom:parent.bottom } }
            Rectangle { id:spectrum8; color: "green"; width: parent.width/11-2; height: root.spectrum8; anchors{ bottom:parent.bottom } }
            Rectangle { id:spectrum9; color: "green"; width: parent.width/11-2; height: root.spectrum9; anchors{ bottom:parent.bottom } }
            Rectangle { id:volume; color: "red"; width: parent.width/11-2; height: root.volume; anchors{ bottom:parent.bottom } }
        }
        Text { text: "<b>Low Frequency Threshold</b>"; color:root.textColor }
        Slider {
            id:lowFrequency
            width:parent.width
            height:20
            gripSize: 20
            value: 0.0
            increment: 0.001
            onValueChanged: {
                lowFrequencyChanged(value * 4000)
            }
        }
        Text { text: "<b>High Frequency Threshold</b>"; color:root.textColor}
        Slider {
            id:highFrequency
            width:parent.width
            height:20
            gripSize: 20
            value: 1.0
            increment: 0.001
            onValueChanged: {
                highFrequencyChanged(value * 4000)
            }
        }
        Text { text: "<b>Wobble Threshold</b>"; color:root.textColor }
        Slider {
            id:wobbleThresholdSlider
            width:parent.width
            height:20
            gripSize: 20
            value: 0.2
            increment: 0.01
        }
        Text { text: "<b>Grey Threshold</b>"; color:root.textColor; }
        Slider {
            id:greyThresholdSlider
            width:parent.width
            height:20
            gripSize: 20
            value: 0.4
            increment: 0.01
        }
        Text { text: "<b>Brighten Threshold</b>"; color:root.textColor; }
        Slider {
            id:brightenThresholdSlider
            width:parent.width
            height:20
            gripSize: 20
            value: 0.8
            increment: 0.01
        }
        Text { text: "<b>Wobble Multiplier</b>"; color:root.textColor; }
        Slider {
            id:wobbleMultiplierSlider
            width:parent.width
            height:20
            gripSize: 20
            value: 0.5
        }
        Text { text: "<b>Grey Clipping</b>"; color:root.textColor; }
        Slider {
            id:greyBrightnessSlider
            width:parent.width
            height:20
            gripSize: 20
            value: 0.5
        }
    }
}
