%Get image files
[FileNameA,PathNameA] = uigetfile('*.dcm','Select Dicom File A');
IMa = dicomread(fullfile(PathNameA,FileNameA));
[FileNameB,PathNameB] = uigetfile('*.dcm','Select Dicom File B',PathNameA);
IMb = dicomread(fullfile(PathNameB,FileNameB));
%Determine transformation, use cpselect for user input for reference points
[movingPoints,fixedPoints]=cpselect(imadjust(IMa),imadjust(IMb),'Wait',true);
movingPoints = cpcorr(movingPoints,fixedPoints,IMa,IMb);
tform = fitgeotrans(movingPoints,fixedPoints,'nonreflectivesimilarity');
[IMa_registered] = imwarp(IMa,tform,'FillValues',0);
movedPoints=transformPointsForward(tform,movingPoints);

%Transform image
trans=movingPoints-movedPoints;
tform = fitgeotrans(movingPoints,fixedPoints,'nonreflectivesimilarity');
J = imtranslate(IMa_registered,mean(trans).*-1,'FillValues',0,'OutputView','full');
hfig = figure;
imshowpair(J,IMb,'falsecolor')
uiwait(hfig)

%Make composite of the two images
DICOM = imfuse(J,IMb,'blend');

%Save dicom
filename_new = FileNameA(1:end-6);
[fileDICOM,pathDICOM] = uiputfile('*.dcm','Save image',fullfile(PathNameA,filename_new));
dicomwrite(DICOM,fullfile(pathDICOM,fileDICOM));
%imwrite(DICOM,fullfile(pathDICOM,[filename_new,'.jpg']),'Mode','lossless','Quality',100)