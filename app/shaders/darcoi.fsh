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

// Based on http://blog.qt.digia.com/blog/2011/03/22/the-convenient-power-of-qml-scene-graph/

// General
uniform sampler2D source;
uniform lowp float qt_Opacity;
varying vec2 qt_TexCoord0;

// Amplitude General
uniform float amplitude;

// Wobble
uniform float wobbleAmplitude;
uniform float wobbleFrequency;
uniform float wobbleTime;
uniform float wobbleDegree;

// Brighten
uniform float greyOn;
uniform float greyBrightness;

// Brighten
uniform float brightenDegree;

void main()
{
    vec2 uv = qt_TexCoord0.xy;
    vec2 tc = qt_TexCoord0.xy;

    ///////////////////////////
    // Wobble Effect
    ///////////////////////////
    float calcDegree = 0.25 - abs(0.5 - uv.x);

    float p = sin(wobbleTime + wobbleFrequency * qt_TexCoord0.y);
    tc.x += wobbleAmplitude * calcDegree * p;

    // Get rid of wavy bits
    if (tc.x < 0.01) tc.x = 0.01;
    if (tc.x > 0.99) tc.x = 0.99;

    vec4 newPixel = texture2D(source, tc);
    
    ///////////////////////////
    // Grey Effect
    ///////////////////////////
    if (greyOn >= 0.5) {
        if (newPixel.r > greyBrightness && newPixel.g > greyBrightness && newPixel.b > greyBrightness) {
            newPixel = vec4(greyBrightness, greyBrightness, greyBrightness, 0.0);
        }
    }

    ///////////////////////////
    // Brighten Effect
    ///////////////////////////
    newPixel = newPixel * brightenDegree;

    gl_FragColor = qt_Opacity * newPixel;
}
