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
    property int itemHeight: 25
    property string effectSource: ""

    signal clicked

    QtObject {
        id: d
        property Item selectedItem
    }

    ListModel {
        id: sources
        ListElement { name: "No effect"; source: "EffectPassThrough.qml" }
        ListElement { name: "Effect 1"; source: "EffectWobble.qml" }
        ListElement { name: "Effect 2"; source: "EffectBillboard.qml" }
        ListElement { name: "Effect 3"; source: "EffectPixelate.qml" }
        ListElement { name: "Effect 4"; source: "EffectSharpen.qml" }
    }

    Component {
        id: sourceDelegate
        Item {
            id: sourceDelegateItem
            width: root.width
            height: itemHeight

            Button {
                id: sourceSelectorItem
                anchors.centerIn: parent
                width: 0.9 * parent.width
                height: 0.8 * itemHeight
                text: name
                onClicked: {
                    if (d.selectedItem)
                        d.selectedItem.state = "baseState"
                    d.selectedItem = sourceDelegateItem
                    d.selectedItem.state = "selected"
                    effectSource = source
                    root.clicked()
                }
            }

            states: [
                State {
                    name: "selected"
                    PropertyChanges {
                        target: sourceSelectorItem
                        bgColor: "#ff8888"
                    }
                }
            ]

            Component.onCompleted: {
                if (name == "No effect") {
                    state = "selected"
                    d.selectedItem = sourceDelegateItem
                }
            }

            transitions: [
                Transition {
                    from: "*"
                    to: "*"
                    ColorAnimation {
                        properties: "color"
                        easing.type: Easing.OutQuart
                        duration: 500
                    }
                }
            ]
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: (itemHeight * sources.count) + layout.anchors.topMargin + layout.spacing
        clip: true

        Column {
            id: layout

            anchors {
                fill: parent
                topMargin: 10
            }

            Repeater {
                model: sources
                delegate: sourceDelegate
            }
        }
    }
}
