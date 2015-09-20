% Cosmic Rays in MATLAB
% Version 1.0
% �������� GPL v3.0
% Alexey V. Voronin @ FoxyLab � 2015
% http://acdc.foxylab.com
% -----------------------------------
clc; % ������� ���� ������
close all;  % �������� �����
disp('***** Cosmic Rays Detector *****');
disp('Alexey V. Voronin @ FoxyLab � 2015');
disp('http://acdc.foxylab.com');
disp('**************************');
time = clock; % ���������� �������� �������
formatOut = 'yyyymmddHHMMSS';
%������������ ����� �����
unique = datestr(time,formatOut);
unique_txt = strcat(unique,'.txt');
diary(unique_txt); % ������� ����� ��������
diary on; % ��������� ������ ��������
adaptors = imaqhwinfo.InstalledAdaptors; % ������ ��������� (��������� �� 1)
% {'coreco'  'winvideo'}
% ������� ������������ ����� ��������� ����� ������������ ������� ����������� � �������� MATLAB. 
% �������� �������������� �������� ������� � �������� ���������� ����� �������� MATLAB � ������������ ������� ����������� � ������� ���������.
% �������� ������� �������� winvideo
wv = uint8(0); % ����� ����� ������� �������� winvideo
for i=1:length(adaptors) % ���� �� ���� ���������
    if (strcmp(adaptors(i),'winvideo') == 1)
        wv = uint8(1); % �������� ����� ������� �������� winvideo
    end;
end
if (wv == uint8(0))
    disp('winvideo adaptor not found!'); % ������� winvideo �� ������
else
    disp('winvideo adaptor found!'); % ������� winvideo ������
    devs = imaqhwinfo('winvideo', 'DeviceIDs'); % ������ � ���������������� ���������
    if (isempty(devs)) % ���� ���������� �� �������
        disp('Device not found!'); % ���������� ��� �������� winvideo �� �������
    else
    for i=1:length(devs) % ���� �� ���� �����������
        dev_info = imaqhwinfo('winvideo', i);
        disp(sprintf('DeviceID %d - %s',i,dev_info.DeviceName));
    end
    id = 1;
    % �������� ������� ����������, ���������� � ����������� � ID 1
    obj = videoinput('winvideo', id);
    set(obj, 'SelectedSourceName', 'input1'); % ����� ��������� ������� input1w
    maxheight = imaqhwinfo(obj,'MaxHeight'); % ������������ ������ �����
    maxwidth = imaqhwinfo(obj,'MaxWidth'); % ������������ ������ �����
    % 1 - Lenovo EasyCamera            YUY2_1280x720
    %{'YUY2_1280x720'  'YUY2_160x120'  'YUY2_320x240'  'YUY2_640x480'  'YUY2_800x600'}
    % 2 - Vimicro USB Camera (Altair)  YUY2_160x120
    % {'YUY2_160x120'  'YUY2_176x144'  'YUY2_320x240'  'YUY2_352x288'  'YUY2_640x480'}      
    limit = 150; % ������ ����������� �������
    set(obj,'ReturnedColorSpace','rgb'); % �������� ������������ - RGB   
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
    res = obj.VideoResolution; % ���������� ���������� ������
    w = res(1);
    h = res(2);
    disp(sprintf('Width = %d ; Height = %d',w,h)); % ����������� ������ � ������ �����
    pause(5); % ����� ��� ���������� 
    event = uint8(0); % ����� ����� �������
    % while 1 % ����������� ����
    while (event<0.5) % ���� �� ����������� �������
        time = clock; % ������� �����
        frame = getsnapshot(obj); % ������ ������ � ���������� ��� � ���� �������
        % ������� ������� �������
        c = zeros(w*h,1);
        for j=0:(h-1)
            for i=1:w 
                c(j*w+i) = i;
            end
        end
        % ������� ������� �����
        r = zeros(w*h,1);
        for j=0:(h-1)
            for i=1:w 
                r(j*w+i) = j+1;
            end
        end
        p = impixel(frame,c,r); % ��������� ������� RGB-��������
        colorMax = 0; % ����� ������������ �������� �������� �������
        pos = 0; % ����� ������� ���������
        red = 0; % ����� �������� �������� ������
        green = 0; % ����� �������� �������� ������
        blue = 0; % ����� �������� ������ ������
        for k=1:w*h % ���� �� ���� ��������
            red = p(k,1); % �������� �������� ������
            green = p(k,2); % �������� �������� ������
            blue = p(k,3);  % �������� ������ ������
            colorDistance = sqrt(red*red + green*green + blue*blue); % �������� ����������
            if (colorDistance > colorMax) % ���� �������� ���������� ��������� ��������
                colorMax = colorDistance; % ������� ������ ���������
                pos = k; % ������� ������ ���������
            end
        end
        if (pos > 0) 
            % ���������� �������� ������� ��� ��������� ���������
            % ����������
            red = p(pos,1);
            green = p(pos,2);
            blue = p(pos,3);
            % ������� �����
            if (red>limit) 
                event = uint8(1); % �������� ����� �������
            end
            % ������� �����
            if (blue>limit)
                event = uint8(1); % �������� ����� �������
            end
            % ����� �����
            if (green>limit)
                event = uint8(1); % �������� ����� �������
            end
        end
        clc; % ������� ���� ������
        close all;  % �������� �����
        disp(sprintf('max: RED = %d GREEN = %d BLUE = %d',red,blue,green)); % ����������� ������������ �������� �������� �������
        if (event>0.5) % ���� ������� ��������� (���� ������)
           disp(datestr(time));% ����������� ������� �������
           formatOut = 'yyyymmddHHMMSS'; % ������ ����� ����� ���-�����-����-����-������-�������
           unique = datestr(time,formatOut); % ������������ ����������� �����
           unique_png = strcat(unique,'.png'); % ������������ ����� png-����� 
           imwrite(frame,unique_png); % ������ ����� � ����
           beep; % �������� ������
           event = uint8(0); % ����� ����� �������
        end
    end     
    delete(obj); % �������� ������� ���������� �� ������
    end;
end;
diary off; % ���������� ������ ��������

   
