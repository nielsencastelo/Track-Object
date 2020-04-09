clear;clc;close all;

a = imaqhwinfo;
[camera_name, camera_id, format] = getCameraInfo(a);
% Capture os quadros de v�deo usando a fun��o videoinput
% Voc� tem que substituir a resolu��o e o nome do adaptador instalado.
vid = videoinput(camera_name, camera_id, format);

% Defina as propriedades do objeto v�deo
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 5;

%iniciar a aquisi��o de v�deo aqui
start(vid)

% Definir um loop que parar depois de 100 quadros de aquisi��o
while(vid.FramesAcquired <= 100)
    
    % Receba o instant�neo do quadro atual
    data = getsnapshot(vid);
    
    % Agora para rastrear objetos vermelhos em tempo real
    % temos que subtrair o componente vermelho 
    % a partir da imagem em tons de cinza para extrair os componentes azul na imagem.
    diff_im = imsubtract(data(:,:,3), rgb2gray(data));
    % Use um filtro de mediana para filtrar o ru�do
    diff_im = medfilt2(diff_im, [3 3]);
    % Converter a imagem em tons de cinza, resultando em uma imagem bin�ria.
    diff_im = im2bw(diff_im,0.18);
    
    % Remove todos os pixels inferior a 300px
    diff_im = bwareaopen(diff_im,100);
    
    % Rotular todos os componentes conectados na imagem.
    bw = bwlabel(diff_im, 8);
    
    % Aqui n�s fazemos a an�lise de imagem blob.
    % N�s temos um conjunto de propriedades para cada regi�o rotulada.
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    
    % Mostrar a imagem
    imshow(data)
    
    hold on;
    
    % Este � um circuito para limitar os objetos vermelhos em uma caixa retangular.
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

stop(vid); % Para aquisi��o do video

% Liberar todos os dados de imagem armazenados no buffer de mem�ria.
flushdata(vid);