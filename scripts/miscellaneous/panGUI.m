function varargout = panGUI(varargin)
% panGUI Graphical user interface for panning through data
%   panGUI, by itself, creates a new window for panning through a plot
%   with a step size of 50.
%
%   H = panGUI returns the handle to a new panGUI window.
%
%   panGUI(STEP) creates a new window with a step size of STEP.
%
%   H = panGUI(STEP)

% Edit the above text to modify the response to help panGUI

% Last Modified by GUIDE v2.5 17-Apr-2003 23:01:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @panGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @panGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before panGUI is made visible.
function panGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to panGUI (see VARARGIN)

% Choose default command line output for panGUI
handles.output = hObject;

if (~isempty(varargin) & isnumeric(varargin{1}))
    step_size = varargin{1};
else
    step_size = 50;
end
edithandle = findobj(hObject,'Tag','edit1');
set(edithandle,'String',num2str(step_size));
% store step_size in data structure
handles.step_size = step_size;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes panGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = panGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
step_size = handles.step_size;
ax1 = axis;
axis([ax1(1)-step_size ax1(2)-step_size ax1(3:4)])

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
step_size = handles.step_size;
ax1 = axis;
axis([ax1(1)+step_size ax1(2)+step_size ax1(3:4)])


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
step_size = eval(get(hObject,'String'));
% get the current axis limits
ax = axis;
% change xmax to xmin + new step_size
axis([ax(1) ax(1)+step_size ax(3:4)]);
% store the new step_size
handles.step_size = step_size;
guidata(hObject,handles)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

step_size = handles.step_size;
% get the current axis limits
ax = axis;
% change xmax to xmin + new step_size
axis([0 step_size ax(3:4)]);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


