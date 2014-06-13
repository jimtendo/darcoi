#include "audiolistener.h"

#include <math.h>

#include <QDebug>
#include <QSet>

#include "frequencyspectrum.h"

AudioListener::AudioListener(QObject *parent) :
    QObject(parent),
    m_availableAudioInputDevices(QAudioDeviceInfo::availableDevices(QAudio::AudioInput)),
    m_audioInputDevice(QAudioDeviceInfo::defaultInputDevice()),
    m_spectrumLowThreshold(1),
    m_spectrumHighThreshold(4000)
{
    qRegisterMetaType<FrequencySpectrum>("FrequencySpectrum");
    qRegisterMetaType<WindowFunction>("WindowFunction");

    connect(&m_spectrumAnalyser, SIGNAL(spectrumChanged(FrequencySpectrum)),
            this, SLOT(spectrumChanged(FrequencySpectrum)));
}

void AudioListener::startListening()
{
    foreach (const QAudioDeviceInfo &audioDevice, m_availableAudioInputDevices) {
        qDebug() << "Available device: " << audioDevice.deviceName();

        if (audioDevice.deviceName() == "default") {
            m_audioInputDevice = audioDevice;
        }
    }
  
    qDebug() << "Current Device: " << m_audioInputDevice.deviceName();

    // Reset buffers, etc
    m_buffer.clear();

    // Setup format
    selectFormat();

    // Setup device
    m_audioInput = new QAudioInput(m_audioInputDevice, m_format, this);
    m_audioInput->setNotifyInterval(NOTIFY_INTERVAL);

    
    connect(m_audioInput, SIGNAL(stateChanged(QAudio::State)),
                    this, SLOT(audioStateChanged(QAudio::State)));
    
    connect(m_audioInput, SIGNAL(notify()),
            this, SLOT(audioNotify()));

    m_audioInputIODevice = m_audioInput->start();
    connect(m_audioInputIODevice, SIGNAL(readyRead()),
            this, SLOT(audioDataReady()));
}

void AudioListener::stopListening()
{
    m_audioInput->stop();
    delete m_audioInput;
    m_audioInputIODevice->close();

    m_buffer.clear();
}

void AudioListener::setLowFreqThreshold(int value)
{
    if (value > 0 && value < m_spectrumHighThreshold) {
        m_spectrumLowThreshold = value;
        qDebug() << "Spectrum: Low Frequency Threshold: " << m_spectrumLowThreshold;
    }
}

void AudioListener::setHighFreqThreshold(int value)
{
    if (value < 4000 && value > m_spectrumLowThreshold) {
        m_spectrumHighThreshold = value;
        qDebug() << "Spectrum: High Frequency Threshold: " << m_spectrumHighThreshold;
    }
}

bool AudioListener::selectFormat()
{
    bool foundSupportedFormat = false;

    QList<int> sampleRatesList;
    sampleRatesList += m_audioInputDevice.supportedSampleRates();
    sampleRatesList = sampleRatesList.toSet().toList(); // remove duplicates
    qSort(sampleRatesList);
    qDebug() << "AudioListener::initialize frequenciesList" << sampleRatesList;

    QList<int> channelsList;
    channelsList += m_audioInputDevice.supportedChannelCounts();
    channelsList = channelsList.toSet().toList();
    qSort(channelsList);
    qDebug() << "AudioListener::initialize channelsList" << channelsList;

    QAudioFormat format;
    format.setByteOrder(QAudioFormat::LittleEndian);
    format.setCodec("audio/pcm");
    format.setSampleSize(16);
    format.setSampleType(QAudioFormat::SignedInt);

    int sampleRate, channels;
    foreach (sampleRate, sampleRatesList) {
        if (foundSupportedFormat)
            break;
        format.setSampleRate(sampleRate);
        foreach (channels, channelsList) {
            format.setChannelCount(channels);
            const bool inputSupport = m_audioInputDevice.isFormatSupported(format);
            qDebug() << "AudioListener::initialize checking " << format
                     << "input" << inputSupport;
            if (inputSupport) {
                foundSupportedFormat = true;
                break;
            }
        }
    }

    if (!foundSupportedFormat)
        format = QAudioFormat();

    m_format = format;

    m_spectrumBufferLength = SpectrumLengthSamples *
                            (m_format.sampleSize() / 8) * m_format.channelCount();

    return foundSupportedFormat;
}

void AudioListener::audioDataReady()
{
    const qint64 bytesReady = m_audioInput->bytesReady();

    m_buffer.append(m_audioInputIODevice->read(bytesReady));
    
    if (m_audioInput->error() == QAudio::NoError && m_lastError != QAudio::NoError) {
	qDebug() << "AudioListener::Restarting Audio";
	qDebug() << "AudioListener::Previous error: " << m_lastError << ", Current Error: " << m_audioInput->error();
	stopListening();
	startListening();
    }
    
    m_lastError = m_audioInput->error();
}

void AudioListener::audioNotify()
{
    calculateLevel();

    if (m_spectrumBuffer.length() >= m_spectrumBufferLength) {
        m_spectrumBuffer.remove(0, m_buffer.length());
    }

    m_spectrumBuffer.append(m_buffer);

    if (m_spectrumBuffer.length() >= m_spectrumBufferLength) {
        m_spectrumBuffer.remove(0, m_spectrumBuffer.length() - m_spectrumBufferLength);
        calculateSpectrum();
    }

    m_buffer.clear();
}

void AudioListener::audioStateChanged(QAudio::State state)
{
    switch (state) {
      case QAudio::ActiveState: qDebug() << "AudioListener::audioStateChanged Active"; break;
      case QAudio::SuspendedState: qDebug() << "AudioListener::audioStateChanged Suspended"; break;
      case QAudio::StoppedState: qDebug() << "AudioListener::audioStateChanged Stopped"; break;
      case QAudio::IdleState: qDebug() << "AudioListener::audioStateChanged Idle"; break;
    }
}

void AudioListener::spectrumChanged(const FrequencySpectrum &spectrum)
{
    int barCount = 9;
    float bars[barCount];
    int step = (m_spectrumHighThreshold - m_spectrumLowThreshold) / barCount;

    int dominantBar = 0;
    double dominantBarAmplitude = 0.0;

    FrequencySpectrum::const_iterator it = spectrum.begin();
    while (it != spectrum.end()) {
        if ((int)(*it).frequency > m_spectrumLowThreshold && (int)(*it).frequency < m_spectrumHighThreshold) {
            int barNumber = (int)((*it).frequency-m_spectrumLowThreshold) / step;
            bars[barNumber] = qMax((qreal)bars[barNumber], (*it).amplitude);

            if (bars[barNumber] > dominantBarAmplitude) {
                dominantBar = barNumber;
                dominantBarAmplitude = bars[barNumber];
            }
        }
        it++;
    }

    emit spectrumChangedQml(bars[0], bars[1], bars[2], bars[3], bars[4], bars[5], bars[6], bars[7], bars[8], bars[9]);
    emit dominantBarChangedQml(dominantBar, dominantBarAmplitude);
}

qint64 AudioListener::audioLength(const QAudioFormat &format, qint64 microSeconds)
{
   qint64 result = (format.sampleRate() * format.channelCount() * (format.sampleSize() / 8))
       * microSeconds / 1000000;
   result -= result % (format.channelCount() * format.sampleSize());
   return result;
}

void AudioListener::calculateLevel()
{
    qreal peakLevel = 0.0;

    qreal sum = 0.0;
    const char *ptr = m_buffer.constData();
    const char *const end = ptr + m_buffer.length();
    while (ptr < end) {
        const qint16 value = *reinterpret_cast<const qint16*>(ptr);
        const qreal fracValue = qreal(value) / 32768;
        peakLevel = qMax(peakLevel, fracValue);
        sum += fracValue * fracValue;
        ptr += 2;
    }
    const int numSamples = m_buffer.length() / 2;
    qreal rmsLevel = sqrt(sum / numSamples);

    rmsLevel = qMax(qreal(0.0), rmsLevel);
    rmsLevel = qMin(qreal(1.0), rmsLevel);
    emit levelChanged(rmsLevel, peakLevel, numSamples);
    emit levelChangedQml(rmsLevel, peakLevel, numSamples);
}

void AudioListener::calculateSpectrum()
{
    // QThread::currentThread is marked 'for internal use only', but
    // we're only using it for debug output here, so it's probably OK :)
    /*ENGINE_DEBUG << "Engine::calculateSpectrum" << QThread::currentThread()
                 << "count" << m_count << "pos" << position << "len" << m_spectrumBufferLength
                 << "spectrumAnalyser.isReady" << m_spectrumAnalyser.isReady();*/

    if (m_spectrumAnalyser.isReady()) {
        //m_spectrumBuffer = QByteArray::fromRawData(m_buffer.constData(), SpectrumLengthSamples * m_format.sampleSize()/8);
        m_spectrumAnalyser.calculate(m_spectrumBuffer, m_format);
    }
}
