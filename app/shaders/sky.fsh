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

// Based on http://kodemongki.blogspot.com/2011/06/kameraku-custom-shader-effects-example.html

uniform float threshold;
uniform float red;
uniform float green;
uniform float blue;
uniform float dividerValue;

uniform sampler2D source;
uniform lowp float qt_Opacity;
varying vec2 qt_TexCoord0;


void main()
{
    float degree = threshold;

    vec2 uv = qt_TexCoord0.xy; // Position
    vec4 original = texture2D(source, uv.xy).rgba;

    /*
    if (uv.x < dividerValue) {

        vec3 maxColor;

        // Look right
        for (float span = uv.x; span < uv.x + degree && span < 100.0; span += 0.01) {
            vec2 currentPosition;
            currentPosition.y = uv.y;
            currentPosition.x = span;
            vec3 color = texture2D(source, currentPosition).rgb;

            if (color.r > maxColor.r) {
                maxColor = color;
            }
        }

        // Look left
        for (float span = uv.x; span < degree && span > 0.0; span -= 0.01) {

        }

        gl_FragColor = qt_Opacity * vec4(maxColor.r, maxColor.g, maxColor.b, 1.0);

    } else {

        gl_FragColor = qt_Opacity * vec4(original.r, original.g, original.b, 1.0);
    }
    */

    if (uv.x < dividerValue) {
        vec3 color = texture2D(source, uv).rgb;

        if (color.r > red && color.g > green && color.b > blue) {
            gl_FragColor = vec4(0.8, 0.0, 0.0, 0.0);
        } else {
            gl_FragColor = qt_Opacity * vec4(original.r, original.g, original.b, 1.0);
        }
    } else {
        gl_FragColor = qt_Opacity * vec4(original.r, original.g, original.b, 1.0);
    }

    /*vec4 orig = texture2D(source, uv); // Original Value
    vec3 col = orig.rgb;
    float y = 0.3 *col.r + 0.59 * col.g + 0.11 * col.b;
    y = y < threshold ? 0.0 : 1.0;
    if (uv.x < dividerValue)
        gl_FragColor = qt_Opacity * vec4(y, y, y, 1.0);
    else
        gl_FragColor = qt_Opacity * orig;*/
}


