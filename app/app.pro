TEMPLATE = app
TARGET = darcoi

QT += widgets quick multimedia

SUBDIRS += ../3rdparty/fftreal

fftreal_dir = ../3rdparty/fftreal

INCLUDEPATH += $${fftreal_dir}

SOURCES += filereader.cpp main.cpp \
    engine.cpp \
    utils.cpp \
    spectrumanalyser.cpp \
    frequencyspectrum.cpp \
    tonegenerator.cpp \
    waveform.cpp \
    wavfile.cpp \
    audiolistener.cpp
HEADERS += filereader.h trace.h \
    engine.h \
    spectrum.h \
    utils.h \
    spectrumanalyser.h \
    frequencyspectrum.h \
    tonegenerator.h \
    waveform.h \
    wavfile.h \
    audiolistener.h

RESOURCES += app.qrc

# Dynamic linkage against FFTReal DLL
!contains(DEFINES, DISABLE_FFT) {
    macx {
        # Link to fftreal framework
        LIBS += -F$${fftreal_dir}
        LIBS += -framework fftreal
    } else {
        LIBS += -L..$${spectrum_build_dir}
        LIBS += -lfftreal
    }
}

maemo6: {
    DEFINES += SMALL_SCREEN_LAYOUT
    DEFINES += SMALL_SCREEN_PHYSICAL
}

target.path = /usr/local/bin/qmlvideofx
INSTALLS += target
