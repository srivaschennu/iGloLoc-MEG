function varargout = markartifacts2(varargin)
% MARKARTIFACTS2 MATLAB code for markartifacts2.fig
%      MARKARTIFACTS2, by itself, creates a new MARKARTIFACTS2 or raises the existing
%      singleton*.
%
%      H = MARKARTIFACTS2 returns the handle to a new MARKARTIFACTS2 or the handle to
%      the existing singleton*.
%
%      MARKARTIFACTS2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MARKARTIFACTS2.M with the given input arguments.
%
%      MARKARTIFACTS2('Property','Value',...) creates a new MARKARTIFACTS2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before markartifacts2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to markartifacts2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help markartifacts2

% Last Modified by GUIDE v2.5 02-Feb-2012 11:23:44

if ismac
    guisuffix = '_mac';
elseif isunix
    guisuffix = '_unix';
elseif ispc
    guisuffix = '_win';
end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       [mfilename guisuffix], ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @markartifacts2_OpeningFcn, ...
    'gui_OutputFcn',  @markartifacts2_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before markartifacts2 is made visible.
function markartifacts2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to markartifacts2 (see VARARGIN)

% Choose default command line output for markartifacts2
handles.output = hObject;

handles.D = varargin{1};
handles.modality = varargin{2};

switch handles.modality
    case {'EEG' 'LFP'}
        scalefactor = 1;
    case {'MEGMAG' 'MEGPLANAR'}
        scalefactor = 1;
end

handles.data = handles.D(find(strcmp(handles.modality,handles.D.chantype)),:,:) * scalefactor;

if isempty(varargin) || length(varargin) > 4
    error('Usage: D = markartifacts(D, modality, [chanvarthresh, trialvarthresh]);');
elseif length(varargin) == 2
    handles.chanvarthresh = 500;
    handles.trialvarthresh = 500;
elseif length(varargin) == 3
    handles.chanvarthresh = varargin{3};
    handles.trialvarthresh = 500;
elseif length(varargin) == 4
    handles.chanvarthresh = varargin{3};
    handles.trialvarthresh = varargin{4};
end


set(handles.chanEdit,'String',num2str(handles.chanvarthresh));
set(handles.trialEdit,'String',num2str(handles.trialvarthresh));

% Update handles structure
guidata(hObject, handles);

set(handles.mainFig,'Name', [get(handles.mainFig,'Name') ': ' handles.D.fname ' (' handles.modality ')']);

drawchan(hObject);
drawtrial(hObject);


% UIWAIT makes markartifacts2 wait for user response (see UIRESUME)
% uiwait(handles.mainFig);


% --- Outputs from this function are returned to the command line.
function varargout = markartifacts2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;

% --- Executes on button press in acceptBtn.
function acceptBtn_Callback(hObject, eventdata, handles)
% hObject    handle to acceptBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CloseMenuItem_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.mainFig)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

D = handles.D;
badchan = handles.badchan;
modchan = find(strcmp(handles.modality,D.chantype));
badchan = modchan(badchan);
assignin('base','badchan',badchan);
badtrials = handles.badtrials;
assignin('base','badtrials',badtrials);

delete(handles.mainFig);

% --- Executes during object creation, after setting all properties.
function chanEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chanEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function trialEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on chanEdit and none of its controls.
function chanEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to chanEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if strcmp(eventdata.Key,'return')
    set(handles.chanText,'String','Updating...');
    pause(0.1);
    handles.chanvarthresh = str2double(get(hObject,'String'));
    % Update handles structure
    guidata(hObject, handles);

    drawchan(hObject);
    drawtrial(hObject);
end


% --- Executes on key press with focus on trialEdit and none of its controls.
function trialEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to trialEdit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if strcmp(eventdata.Key,'return')
    set(handles.trialText,'String','Updating...');
    pause(0.1);
    handles.trialvarthresh = str2double(get(hObject,'String'));
    % Update handles structure
    guidata(hObject, handles);
    
    drawtrial(hObject);
end

%% Function to update channel variance plot
function drawchan(hObject)

handles = guidata(hObject);
data = handles.data;

data = reshape(data,size(data,1),size(data,2)*size(data,3));
chanvar = var(data,0,2);

badchan = (chanvar > handles.chanvarthresh) | (chanvar == 0);

chanText = sprintf('%d of %d (%d%%) bad', ...
    sum(badchan),length(badchan),round((sum(badchan)/length(badchan))*100));
set(handles.chanText,'String',chanText);

bar(handles.chanAxes,chanvar);
set(handles.chanAxes,'XLim',[1 length(badchan)],'YLim',[0 handles.chanvarthresh*10],...
    'XTick',1:3:length(badchan),'XTickLabel',1:3:length(badchan));
xlabel(handles.chanAxes,'Channels'); ylabel(handles.chanAxes,'Variance');
line([1 length(badchan)],[handles.chanvarthresh handles.chanvarthresh],...
    'LineStyle','--','LineWidth',2,'Parent',handles.chanAxes);

handles.badchan = badchan;
% Update handles structure
guidata(hObject, handles);

%% Function to update trial variance plot
function drawtrial(hObject)

handles = guidata(hObject);
data = handles.data;
badchan = handles.badchan;

data = data(~badchan,:,:);
data = reshape(data,size(data,1)*size(data,2),size(data,3));

trialvar = var(data);

badtrials = (trialvar > handles.trialvarthresh);

set(handles.trialText,'String',sprintf('%d of %d (%d%%) bad', ...
    sum(badtrials),length(badtrials),round((sum(badtrials)/length(badtrials))*100)));

bar(handles.trialAxes,trialvar);
set(handles.trialAxes,'XLim',[1 length(badtrials)],'YLim',[0 handles.trialvarthresh*10]);
xlabel(handles.trialAxes,'Trials'); ylabel(handles.trialAxes,'Variance');
line([1 length(badtrials)],[handles.trialvarthresh handles.trialvarthresh],...
    'LineStyle','--','LineWidth',2,'Parent',handles.trialAxes);

handles.badtrials = badtrials;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function mainFig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function chanAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chanAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate chanAxes


% --- Executes during object creation, after setting all properties.
function trialAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate trialAxes



function chanEdit_Callback(hObject, eventdata, handles)
% hObject    handle to chanEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chanEdit as text
%        str2double(get(hObject,'String')) returns contents of chanEdit as a double



function trialEdit_Callback(hObject, eventdata, handles)
% hObject    handle to trialEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialEdit as text
%        str2double(get(hObject,'String')) returns contents of trialEdit as a double
