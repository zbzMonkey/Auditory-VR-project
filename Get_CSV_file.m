%% Get file
function fileName = Get_file()

if nargin==0
    %Prompt the user for the file
    [fileName,pathName]=uigetfile({'*.csv','All Files (*.csv)'},'Choose a CSV File');
    if fileName==0
        return
    end
    fileName=fullfile(pathName,fileName);
end