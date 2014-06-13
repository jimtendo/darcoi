#ifndef AUDIOLISTENER_H
#define AUDIOLISTENER_H

#include <QObject>

#include <QByteArray>
#include <QIODevice>

#include <QAudioFormat>
#include <QAudioDeviceInfo>
#include <QAudioInput>

#include "spectrumanalyser.h"

class AudioListener : public QObject
{
    Q_OBJECT
public:
    explicit AudioListener(QObject *parent = 0);

signals:
    /**
     * Level changed
     * \param rmsLevel RMS level in range 0.0 - 1.0
     * \param peakLevel Peak level in range 0.0 - 1.0
     * \param numSamples Number of audio samples analyzed
     */
    void levelChanged(qreal rmsLevel, qreal peakLevel, int numSamples);

    void levelChangedQml(QVariant rmsLevel, QVariant peakLevel, QVariant numSamples);

    void spectrumChangedQml(QVariant bar0, QVariant bar1, QVariant bar2, QVariant bar3, QVariant bar4, QVariant bar5, QVariant bar6, QVariant bar7, QVariant bar8, QVariant bar9);

    void dominantBarChangedQml(QVariant bar, QVariant amplitude);

public slots:
    void startListening();
    void stopListening();

    void setLowFreqThreshold(int value);
    void setHighFreqThreshold(int value);

private:
    bool selectFormat();
    void calculateLevel();
    void calculateSpectrum();

    qint64 audioLength(const QAudioFormat &format, qint64 microSeconds);

private slots:
    void audioDataReady();
    void audioNotify();
    void audioStateChanged(QAudio::State state);

    void spectrumChanged(const FrequencySpectrum &spectrum);

private:
    const QList<QAudioDeviceInfo> m_availableAudioInputDevices;
    QAudioDeviceInfo    m_audioInputDevice;
    QAudioInput*        m_audioInput;
    QIODevice*          m_audioInputIODevice;
    QAudioFormat        m_format;

    QByteArray          m_buffer;

    QByteArray          m_spectrumBuffer;
    SpectrumAnalyser    m_spectrumAnalyser;
    int                 m_spectrumBufferLength;
    int                 m_spectrumLowThreshold;
    int                 m_spectrumHighThreshold;

    static const int    NOTIFY_INTERVAL = 100;
    
    // HACK
    QAudio::Error	m_lastError;
};

#endif // AUDIOLISTENER_H
