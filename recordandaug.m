% پارامترهای ضبط
fs = 16000; % نرخ نمونه‌برداری
nBits = 16; % تعداد بیت‌ها در هر نمونه
nChannels = 1; % تعداد کانال‌ها

% تعداد کلمات و تعداد تکرارها
numWords = 20;
wordList = {'bale', 'nah', 'salam','bala','baste','baz','bebakhshid','boro','chap','khamoosh','khodahafez','komak','lotfan','payan','payin','rast','rooshan','shoro','tashakor','tavaghof'};
numRepetitions = 5;

% ایجاد پوشه‌ها
baseDir = 'data';
if ~exist(baseDir, 'dir')
    mkdir(baseDir);
end

for i = 1:numWords
    wordDir = fullfile(baseDir, wordList{i});
    if ~exist(wordDir, 'dir')
        mkdir(wordDir);
    end
end

% ضبط و ذخیره‌سازی صدا
for i = 1:numWords
    for j = 1:numRepetitions
        recObj = audiorecorder(fs, nBits, nChannels);
        disp(['Please say ', wordList{i}, ' ', num2str(j)]);
        pause(1); % یک ثانیه مکث برای آمادگی
        recordblocking(recObj, 2); % ضبط برای 2 ثانیه
        disp('Recording finished.');

        audioData = getaudiodata(recObj);
        filename = fullfile(baseDir, wordList{i}, [wordList{i}, '_', num2str(j, '%02d'), '.wav']);
        audiowrite(filename, audioData, fs);
    end
end
% افزایش داده‌ها
augmentationsPerFile = 10;
noiseLevel = 0.005; % سطح نویز

for i = 1:numWords
    wordDir = fullfile(baseDir, wordList{i});
    audioFiles = dir(fullfile(wordDir, '*.wav'));
    
    for j = 1:length(audioFiles)
        [audioData, fs] = audioread(fullfile(wordDir, audioFiles(j).name));
        
        for k = 1:augmentationsPerFile
            % تغییر شدت صدا
            scale = 0.8 + (1.2 - 0.8) * rand(); % شدت صدا بین 0.8 و 1.2
            augmentedAudio = audioData * scale;
            
            % اضافه کردن نویز
            noise = noiseLevel * randn(size(audioData));
            augmentedAudio = augmentedAudio + noise;
            
            % ذخیره فایل‌های افزایش یافته
            augFilename = fullfile(wordDir, [wordList{i}, '_', num2str(j, '%02d'), '_aug_', num2str(k, '%02d'), '.wav']);
            audiowrite(augFilename, augmentedAudio, fs);
        end
    end
end


