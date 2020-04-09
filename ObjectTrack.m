clear;clc;close all;

a = imaqhwinfo;
[camera_name, camera_id, format] = getCameraInfo(a);
% Capture os quadros de vídeo usando a função videoinput
% Você tem que substituir a resolução e o nome do adaptador instalado.
vid = videoinput(camera_name, camera_id, format);

% Defina as propriedades do objeto vídeo
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 5;

%iniciar a aquisição de vídeo aqui
start(vid)

% Definir um loop que parar depois de 100 quadros de aquisição
while(vid.FramesAcquired <= 100)
    
    % Receba o instantâneo do quadro atual
    data = getsnapshot(vid);
    
    % Agora para rastrear objetos vermelhos em tempo real
    % temos que subtrair o componente vermelho 
    % a partir da imagem em tons de cinza para extrair os componentes azul na imagem.
    diff_im = imsubtract(data(:,:,3), rgb2gray(data));
    % Use um filtro de mediana para filtrar o ruído
    diff_im = medfilt2(diff_im, [3 3]);
    % Converter a imagem em tons de cinza, resultando em uma imagem binária.
    diff_im = im2bw(diff_im,0.18);
    
    % Remove todos os pixels inferior a 300px
    diff_im = bwareaopen(diff_im,100);
    
    % Rotular todos os componentes conectados na imagem.
    bw = bwlabel(diff_im, 8);
    
    % Aqui nós fazemos a análise de imagem blob.
    % Nós temos um conjunto de propriedades para cada região rotulada.
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    
    % Mostrar a imagem
    imshow(data)
    
    hold on;
    
    % Este é um circuito para limitar os objetos vermelhos em uma caixa retangular.
    for object = 1:length(stats)
        bb = stats(object).BoundingBox;
        bc = stats(object).Centroid;
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        plot(bc(1),bc(2), 'mx','LineWidth',5) % Plata o centroide da imagem
        % Plata a coordenada do centroide
        a = text(bc(1) + 15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2))))); 
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
    end
    
    hold off;
end

stop(vid); % Para aquisição do video

% Liberar todos os dados de imagem armazenados no buffer de memória.
flushdata(vid);