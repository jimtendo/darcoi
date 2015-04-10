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

#include <QtCore/QStandardPaths>
#include <QtCore/QStringList>
#include <QtQml/QQmlContext>
#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>

#include "filereader.h"
#include "trace.h"
#include "engine.h"
#include "audiolistener.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Command line options
    bool fullscreen = false;
    QUrl fileName;

    // Get command line arguments
    QStringList args = app.arguments();
    for (int i = 1; i < args.size(); ++i) {

        // Get argument
        const QByteArray arg = args.at(i).toUtf8();

        // If argument is a flag...
        if (arg.startsWith('-')) {

            if ("-fullscreen" == arg) {
                fullscreen = true;
            }
        }

        // Otherwise it is a filename
        else {
            fileName = QUrl::fromLocalFile(arg);
        }
    }

    QQuickView viewer;

    // Setup viewer window
    viewer.setSource(QUrl(QLatin1String("qrc:///qml/qmlvideofx/main.qml")));
    QQuickItem *rootObject = viewer.rootObject();
    viewer.setTitle("DarceArt");
    viewer.setFlags(Qt::Window | Qt::WindowSystemMenuHint | Qt::WindowTitleHint | Qt::WindowMinMaxButtonsHint | Qt::WindowCloseButtonHint);
    viewer.setMinimumSize(QSize(600, 400));

    // Show the view
    viewer.show();

    // If fullscreen was specified...
    if (fullscreen) {
        viewer.showFullScreen();
    }

    // Make root object fill the size of the view
    viewer.setResizeMode(QQuickView::SizeRootObjectToView);

    // Connect quit signal with quit of application
    //QObject::connect((QObject*)viewer.rootContext()->engine(), SIGNAL(quit()), &app, SLOT(quit()));

    // Create and start audio listener
    AudioListener audioListener;
    audioListener.startListening();
    QObject::connect(&audioListener, SIGNAL(levelChangedQml(QVariant, QVariant, QVariant)),
                     rootObject, SLOT(levelChanged(QVariant, QVariant, QVariant)));

    QObject::connect(&audioListener, SIGNAL(spectrumChangedQml(QVariant, QVariant, QVariant, QVariant, QVariant, QVariant, QVariant, QVariant, QVariant, QVariant)),
                     rootObject, SLOT(spectrumChanged(QVariant, QVariant, QVariant, QVariant, QVariant, QVariant, QVariant, QVariant, QVariant, QVariant)));

    QObject::connect(&audioListener, SIGNAL(dominantBarChangedQml(QVariant, QVariant)),
                     rootObject, SLOT(dominantBarChanged(QVariant, QVariant)));

    // Connect QML Frequency shit (we need to send back when Low or High Frequency change)
    QObject* tuningPanel = rootObject->findChild<QObject*>("tuningPanel");
    if (tuningPanel) {
        QObject::connect(tuningPanel, SIGNAL(lowFrequencyChanged(int)),
                         &audioListener, SLOT(setLowFreqThreshold(int)));

        QObject::connect(tuningPanel, SIGNAL(highFrequencyChanged(int)),
                         &audioListener, SLOT(setHighFreqThreshold(int)));
    }

    // Delay invocation of init until the event loop has started, to work around
    // a GL context issue on Harmattan: without this, we get the following error
    // when the first ShaderEffectItem is created:
    // "QGLShaderProgram::addShader: Program and shader are not associated with same context"
    QMetaObject::invokeMethod(viewer.rootObject(), "init", Qt::QueuedConnection);

    return app.exec();
}

