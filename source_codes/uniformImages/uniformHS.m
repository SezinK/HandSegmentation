close all;
clear all;clc;
%%
% take initial information from the user
[files,dataPath,outputFolder_name] = inputf();
% sent the initial values to the main function to run
main(files,dataPath,outputFolder_name);

% start functions
%%
function [files,dataPath,outputFolder_name] = inputf()

% % main part to take inputs and to give outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % data path & file list
[files,dataPath] = uigetfile('*.png', 'Select Files', 'MultiSelect', 'on');

% % create output folder
prompt = {'Enter output folder name: '};
dlg_title = 'X';
num_lines = 1;
def = {'New Folder'};
outputFolder_name = inputdlg(prompt,dlg_title,num_lines,def);
outputFolder_name=char(outputFolder_name);
mkdir(outputFolder_name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
%%
function main(files,dataPath,outputFolder_name)

for k=1:length(files)
% %    take one image path
   imgPath = char(fullfile(dataPath,files(k)));
   
% %    sent the original image's path to our hand detection function
   output = HandDetectionf(imgPath);
   
% %    write the output results into the output folder
   back = cd;
   cd(outputFolder_name);
   imwrite(output,char(files(k)));
   cd(back);
    
end

end
%%
function out = HandDetectionf(iname)
% Getting a RGB image.
img = imread(iname);
% figure; imshow(img);
% title('Original');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I = Illuminationf(img);
% figure; imshow(I);
% title('Illumination');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I = skinDetection(I);
% figure; imshow(I);
% title('Illumination');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
edgee = filtering(I);
% figure; imshow(edgee);
% title('edgee');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 out = edgee;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%
function out = Illuminationf(img)

% get R-G-B values from RGM image; seperate the image
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

% take average of the R-G-B channell " ex: Ravg = mean(mean(R)) "
Ravg = (sum(sum(R))) ./ ((size(R,1)) .* (size(R,2))); 
Gavg = (sum(sum(G))) ./ ((size(G,1)) .* (size(G,2)));
Bavg = (sum(sum(B))) ./ ((size(B,1)) .* (size(B,2)));

if(Ravg == Gavg && Ravg == Bavg && Gavg == Bavg)
        fprintf(stream,formatSpec, 'SAME');
else
%     adjust the red and blue pixels
    Ir = (Gavg/Ravg) .* R;
    Ib = (Gavg/Bavg) .* B;
end

% concatenate arrays " Ir, G, Ib " and return it
out = cat(3,Ir,G,Ib); 

end
%%
function out = skinDetection(RGB)

% Converting RGB to YCbCr using matlab function 'rgb2ycbcr'.
YCbCr = rgb2ycbcr(RGB);

% Getting Y, Cb, and Cr values from the YCbCr.
Y = YCbCr(:,:,1);
Cb = YCbCr(:,:,2);
Cr = YCbCr(:,:,3);

% create a kernel with 2 colms by using the size of YCbCr image
% initialize the kernel with '0'
kernel = zeros(size(YCbCr,1), size(YCbCr,2));

% initialize the kernel with '1' by using Cb and Cr channel
kernel(Cb>77 & Cb<127 & Cr>133 & Cr<173) = 1;

out = kernel;

end
%%
function out = filtering(kernel)

% fill the holes on the kernel and remove the noises
filled = medfilt2(imfill(kernel, 'holes'));

% % perpindicular linear
% se90 = strel('line',3,90);
% se0 = strel('line',3,0);
% filled_again = imdilate(filled,[se90 se0]);

% detect the biggest skinn part which has the biggest number of pixell
CC = bwconncomp(filled);
numberPix = cellfun(@numel,CC.PixelIdxList);
[biggest , idx] = max(numberPix);

% remove the smaller ones from the image
for i = 1: length(CC.PixelIdxList)
    if i ~= idx
        filled(CC.PixelIdxList{i}) = 0;
    end
end

% [~,threshOut] = edge(filled_again,'sobel');
% edgee = edge(filled_again,'sobel',threshOut*0.5);

out = filled;

end


% end functions
