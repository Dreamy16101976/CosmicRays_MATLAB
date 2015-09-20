% Cosmic Rays in MATLAB
% Version 1.0
% лицензия GPL v3.0
% Alexey V. Voronin @ FoxyLab © 2015
% http://acdc.foxylab.com
% -----------------------------------
clc; % очистка окна команд
close all;  % удаление фигур
disp('***** Cosmic Rays Detector *****');
disp('Alexey V. Voronin @ FoxyLab © 2015');
disp('http://acdc.foxylab.com');
disp('**************************');
time = clock; % считывание текущего времени
formatOut = 'yyyymmddHHMMSS';
%формирование имени файла
unique = datestr(time,formatOut);
unique_txt = strcat(unique,'.txt');
diary(unique_txt); % задание файла дневника
diary on; % включение записи дневника
adaptors = imaqhwinfo.InstalledAdaptors; % массив адаптеров (нумерация от 1)
% {'coreco'  'winvideo'}
% адаптер представляет собой интерфейс между устройствами захвата изображений и системой MATLAB. 
% Основное предназначение адаптера состоит в передаче информации между системой MATLAB и устройствами захвата изображений с помощью драйверов.
% проверка наличия адаптера winvideo
wv = uint8(0); % сброс флага наличия адаптера winvideo
for i=1:length(adaptors) % цикл по всем адаптерам
    if (strcmp(adaptors(i),'winvideo') == 1)
        wv = uint8(1); % поднятие флага наличия адаптера winvideo
    end;
end
if (wv == uint8(0))
    disp('winvideo adaptor not found!'); % адаптер winvideo не найден
else
    disp('winvideo adaptor found!'); % адаптер winvideo найден
    devs = imaqhwinfo('winvideo', 'DeviceIDs'); % массив с идентификаторами устройств
    if (isempty(devs)) % если устройства не найдены
        disp('Device not found!'); % устройства для адаптера winvideo не найдены
    else
    for i=1:length(devs) % цикл по всем устройствам
        dev_info = imaqhwinfo('winvideo', i);
        disp(sprintf('DeviceID %d - %s',i,dev_info.DeviceName));
    end
    id = 1;
    % создание объекта видеоввода, связанного с устройством с ID 1
    obj = videoinput('winvideo', id);
    set(obj, 'SelectedSourceName', 'input1'); % выбор источника сигнала input1w
    maxheight = imaqhwinfo(obj,'MaxHeight'); % максимальная высота кадра
    maxwidth = imaqhwinfo(obj,'MaxWidth'); % максимальная ширина кадра
    % 1 - Lenovo EasyCamera            YUY2_1280x720
    %{'YUY2_1280x720'  'YUY2_160x120'  'YUY2_320x240'  'YUY2_640x480'  'YUY2_800x600'}
    % 2 - Vimicro USB Camera (Altair)  YUY2_160x120
    % {'YUY2_160x120'  'YUY2_176x144'  'YUY2_320x240'  'YUY2_352x288'  'YUY2_640x480'}      
    limit = 150; % предел обнаружения события
    set(obj,'ReturnedColorSpace','rgb'); % цветовое пространство - RGB   
    src_obj = getselectedsource(obj);
    % get(src_obj)
    % Device Specific Properties:
    % BacklightCompensation = on
    % Brightness = 0
    % Contrast = 10
    % Exposure = -4
    % ExposureMode = auto
    % FrameRate = 7.5000
    % Gain = 32
    % Gamma = 150   
    % Hue = 0
    % Saturation = 5
    % Sharpness = 5
    % Zoom = 0
    res = obj.VideoResolution; % считывание разрешения камеры
    w = res(1);
    h = res(2);
    disp(sprintf('Width = %d ; Height = %d',w,h)); % отображение ширины и высоты кадра
    pause(5); % пауза для считывания 
    event = uint8(0); % сброс флага события
    % while 1 % бесконечный цикл
    while (event<0.5) % цикл до обнаружения события
        time = clock; % текущее время
        frame = getsnapshot(obj); % захват снимка и сохранение его в виде матрицы
        % задание номеров колонок
        c = zeros(w*h,1);
        for j=0:(h-1)
            for i=1:w 
                c(j*w+i) = i;
            end
        end
        % задание номеров строк
        r = zeros(w*h,1);
        for j=0:(h-1)
            for i=1:w 
                r(j*w+i) = j+1;
            end
        end
        p = impixel(frame,c,r); % получение матрицы RGB-значения
        colorMax = 0; % сброс максимальных значений цветовых каналов
        pos = 0; % сброс позиции максимума
        red = 0; % сброс значения красного канала
        green = 0; % сброс значения зеленого канала
        blue = 0; % сброс значения синего канала
        for k=1:w*h % цикл по всем пикселам
            red = p(k,1); % значение красного канала
            green = p(k,2); % значение зеленого канала
            blue = p(k,3);  % значение синего канала
            colorDistance = sqrt(red*red + green*green + blue*blue); % цветовое расстояние
            if (colorDistance > colorMax) % если цветовое расстояние превышает максимум
                colorMax = colorDistance; % задание нового максимума
                pos = k; % позиция нового максимума
            end
        end
        if (pos > 0) 
            % считывание значений каналов для максимума цветового
            % расстояния
            red = p(pos,1);
            green = p(pos,2);
            blue = p(pos,3);
            % красный канал
            if (red>limit) 
                event = uint8(1); % поднятие флага события
            end
            % зеленый канал
            if (blue>limit)
                event = uint8(1); % поднятие флага события
            end
            % синий канал
            if (green>limit)
                event = uint8(1); % поднятие флага события
            end
        end
        clc; % очистка окна команд
        close all;  % удаление фигур
        disp(sprintf('max: RED = %d GREEN = %d BLUE = %d',red,blue,green)); % отображение максимальных значений цветовых каналов
        if (event>0.5) % если событие случилось (флаг поднят)
           disp(datestr(time));% отображение времени события
           formatOut = 'yyyymmddHHMMSS'; % шаблон имени файла год-месяц-день-часы-минуты-секунды
           unique = datestr(time,formatOut); % формирование уникального имени
           unique_png = strcat(unique,'.png'); % формирование имени png-файла 
           imwrite(frame,unique_png); % запись кадра в файл
           beep; % звуковой сигнал
           event = uint8(0); % сброс флага события
        end
    end     
    delete(obj); % удаление объекта видеоввода из памяти
    end;
end;
diary off; % отключение записи дневника

   
