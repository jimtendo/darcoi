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

uniform float amplitude;
uniform float dividerValue;
uniform float frequency;
uniform float time;
uniform float degree;

uniform float amount;
uniform float threshold;
const float step_w = 0.0015625;
const float step_h = 0.0027778;

uniform sampler2D source;
uniform lowp float qt_Opacity;
varying vec2 qt_TexCoord0;


void main()
{
    vec2 uv = qt_TexCoord0.xy;
    vec2 tc = qt_TexCoord0.xy;

    if (uv.x < dividerValue) {

        float calcDegree = 0.25 - abs(0.5 - uv.x);

        float p = sin(time + frequency * qt_TexCoord0.y);
        tc.x += amplitude * calcDegree * p;

        // Get rid of wavy bits
        if (tc.x < 0.01) tc.x = 0.01;
        if (tc.x > 0.99) tc.x = 0.99;
    }

    vec4 brightness = vec4(1.0, 1.0, 1.0, 1.0);

    if (amount > 0.4) {
        float amount2 = amount + 0.6;
        brightness = vec4(1.0 * amount2, 1.0 * amount2, 1.0 * amount2, 1.0 * amount2);
    }
    
    vec4 newPixel = texture2D(source, tc);

    if (newPixel.g > threshold && newPixel.r > threshold && newPixel.b > threshold) {
        newPixel.r = 1.0;
	newPixel.g = 0.0;
	newPixel.b = 0.0;
    }
    
    gl_FragColor = qt_Opacity * newPixel * brightness;
}
