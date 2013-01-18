function wordGenLetterGUI
    % Insert comments here when it's more comprehensible
    global handle; handle = figure;
    global fontSelector;
    global sizeInput;
    global sampsPerPtInput;
    global boldCheckbox;
    global fractionalMetricsCheckbox;
    global antiAliasCheckbox;
    
    % Set up the figure box
    figWidth = 300;
    figHeight = 400;
    screenSize = get(0,'ScreenSize');
    set(handle, 'Position', [screenSize(3) / 2 - figWidth / 2, ...
                             screenSize(4) / 2 - figHeight / 2, ...
                             figWidth, figHeight]);
    set(handle, 'Name','Font Toolbox','NumberTitle','off');
    
    % Set up font defaults
    default.fontSize = 20;
    default.fontFace = 'Monospaced';
    default.isBold = true;
    default.hasFractionalMetrics = false;
    default.isAA = false;
    default.sampsPerPt = 8;
    
    % Set up GUI
    makeTitle();
    [fontSelector, default.fontFaceIndex] = ...
        createFontSelector(default.fontFace);
    [sizeInput, sizeDown, sizeUp] = ...
        createSizeInput(default.fontSize);
    boldCheckbox = ...
        createBoldCheckbox(default.isBold);
    [sampsPerPtInput, sampsPerPtDown, sampsPerPtUp] = ...
        createSampsPerPtInput(default.sampsPerPt);
    fractionalMetricsCheckbox = ...
        createFractionalMetricsCheckbox(default.hasFractionalMetrics);
    antiAliasCheckbox = ...
        createAntiAliasingCheckbox(default.isAA);
    loadButton = ...
        createLoadButton();
    defaultButton = ...
        createDefaultButton();
    previewButton = ...
        createPreviewButton();
    saveButton = ...
        createSaveButton();
    
    % Set up callbacks
    set(sizeDown, 'Callback', ... 
        {@sizeInput_Callback, -1});
    set(sizeUp, 'Callback', ...
        {@sizeInput_Callback, 1});
    set(sampsPerPtDown, 'Callback', ... 
        {@sampsPerPtInput_Callback, -1});
    set(sampsPerPtUp, 'Callback', ...
        {@sampsPerPtInput_Callback, 1});
    set(loadButton, 'Callback', ...
        {@loadButton_Callback});
    set(defaultButton, 'Callback', ...
        {@defaultButton_Callback, default});
    set(previewButton, 'Callback', ...
        {@previewButton_Callback});
    set(saveButton, 'Callback', ...
        {@saveButton_Callback});
end

function makeTitle()
    % Make the title for the box
    global handle;
    
    uicontrol(handle, ...
        'Style', 'text', ...
        'String', 'Font Toolbox',...
        'Position', [50 350 200 30]);
                    
end

function [fontSelector, defaultFontIndex] = createFontSelector(fontFace)
    % Set up the font selector pop up menu
    global handle;
    import java.awt.*;
    
    graphEnv = GraphicsEnvironment.getLocalGraphicsEnvironment();
    availableFontsJava = graphEnv.getAvailableFontFamilyNames();
    availableFonts = convertFontList(availableFontsJava);
    defaultFontIndex = findFontFaceDefaultIndex(availableFonts, fontFace);
    
    uicontrol(handle, ...
        'Style', 'text', ...
        'String', 'Font Face',...
        'Position', [30 300 130 25]);
    
    fontSelector    = uicontrol(handle, ...
                        'Style', 'popupmenu',...
                        'String', availableFonts,...
                        'Value', defaultFontIndex, ...
                        'Position', [30 275 130 25]);

end

function [sizeInput, sizeDown, sizeUp] = createSizeInput(fontSize)
    % Set up the size input text box and ++/-- buttons
    global handle;
    
    uicontrol(handle, ...
        'Style', 'text', ...
        'String', 'Font Size',...
        'Position', [30 240 130 25]);

    sizeDown        = uicontrol(handle, ...
                        'Style', 'pushbutton', ...
                        'String', '--', ...
                        'Position', [30 215 30 25]);
    sizeUp          = uicontrol(handle, ...
                        'Style', 'pushbutton', ...
                        'String', '++', ...
                        'Position', [130 215 30 25]);
    sizeInput       = uicontrol(handle, ...
                        'Style', 'edit',...
                        'String', fontSize,...
                        'Position', [60 215 70 25]);
                    
end

function sizeInput_Callback(object, eventData, increment)
    % Callback for size input buttons and text editor
    global sizeInput;
    
    valence = sign(increment);
    currentString = get(sizeInput,'String');
    currentValue = str2double(currentString);
    
    if (valence == 1)
        set(sizeInput,'String',sprintf('%d', currentValue + 1));
    elseif (valence == -1)
        set(sizeInput,'String',sprintf('%d', currentValue - 1));
    end
    
end

function [sampsPerPtInput, sampsPerPtDown, sampsPerPtUp] = ...
    createSampsPerPtInput(sampsPerPt)
    % Set up the size input text box and ++/-- buttons
    global handle;
    
    uicontrol(handle, ...
        'Style', 'text', ...
        'String', 'Samples Per Point',...
        'Position', [30 180 130 25]);

    sampsPerPtDown  = uicontrol(handle, ...
                        'Style', 'pushbutton', ...
                        'String', '--', ...
                        'Position', [30 155 30 25]);
    sampsPerPtUp    = uicontrol(handle, ...
                        'Style', 'pushbutton', ...
                        'String', '++', ...
                        'Position', [130 155 30 25]);
    sampsPerPtInput = uicontrol(handle, ...
                        'Style', 'edit',...
                        'String', sampsPerPt,...
                        'Position', [60 155 70 25]);
                    
end

function sampsPerPtInput_Callback(object, eventData, increment)
    % Callback for size input buttons and text editor
    global sampsPerPtInput;
    
    valence = sign(increment);
    currentString = get(sampsPerPtInput,'String');
    currentValue = str2double(currentString);
    
    if (valence == 1)
        set(sampsPerPtInput,'String',sprintf('%d', currentValue + 1));
    elseif (valence == -1)
        set(sampsPerPtInput,'String',sprintf('%d', currentValue - 1));
    end
    
end

function boldCheckbox = createBoldCheckbox(isBold)
    % Set up the bold flag check box
    global handle;
    
    boldCheckbox    = uicontrol(handle, ...
                        'Style', 'checkbox', ...
                        'String', 'Bold', ...
                        'Value', isBold, ...
                        'Position', [30 120 130 25]);
                    
end

function fractionalMetricsCheckbox = ...
    createFractionalMetricsCheckbox(hasFractionalMetrics)
    % Set up the bold flag check box
    global handle;
    
    fractionalMetricsCheckbox = uicontrol(handle, ...
                        'Style', 'checkbox', ...
                        'String', 'Fractional Metrics', ...
                        'Value', hasFractionalMetrics, ...
                        'Position', [30 85 130 25]);
                    
end

function antiAliasingCheckbox = createAntiAliasingCheckbox(isAA)
    % Set up the bold flag check box
    global handle;
    
    antiAliasingCheckbox = uicontrol(handle, ...
                        'Style', 'checkbox', ...
                        'String', 'Anti-Aliasing', ...
                        'Value', isAA, ...
                        'Position', [30 50 130 25]);
                    
end

function loadButton = createLoadButton()
    % Set up button that allows you to preview a few letters/numbers with
    % the properties you've specified thus far
    global handle;
    
    loadButton   = uicontrol(handle, ...
                        'Style', 'pushbutton', ...
                        'String', 'Load',...
                        'Position', [200 280 70 70]);
end

function loadButton_Callback(object, eventData)
    % Reset defaults
    global fontSelector;
    global sizeInput;
    global sampsPerPtInput;
    global boldCheckbox;
    global fractionalMetricsCheckbox;
    global antiAliasCheckbox;
    
    fileName = mrvSelectFile('r','mat','Load...');
    if (~isempty(fileName))
        load(fileName);
    end
    
    availableFonts = get(fontSelector,'String');
    index = findFontFaceDefaultIndex(availableFonts, fontName);
    set(fontSelector, 'Value', index);
    set(sizeInput, 'String', fontSize);
    set(sampsPerPtInput, 'String', sampsPerPt);
    set(boldCheckbox, 'Value', boldFlag);
    set(fractionalMetricsCheckbox, 'Value', fractionalMetrics);
    set(antiAliasCheckbox, 'Value',antiAlias);
    
end

function defaultButton = createDefaultButton()
    % Set up button that allows you to preview a few letters/numbers with
    % the properties you've specified thus far
    global handle;
    
    defaultButton   = uicontrol(handle, ...
                        'Style', 'pushbutton', ...
                        'String', 'Defaults',...
                        'Position', [200 200 70 70]);
end

function defaultButton_Callback(object, eventData, default)
    % Reset defaults
    global fontSelector;
    global sizeInput;
    global sampsPerPtInput;
    global boldCheckbox;
    global fractionalMetricsCheckbox;
    global antiAliasCheckbox;
    
    set(fontSelector, 'Value', default.fontFaceIndex);
    set(sizeInput, 'String', default.fontSize);
    set(sampsPerPtInput, 'String', default.sampsPerPt);
    set(boldCheckbox, 'Value', default.isBold);
    set(fractionalMetricsCheckbox, 'Value', default.hasFractionalMetrics);
    set(antiAliasCheckbox, 'Value', default.isAA);
    
end

function previewButton = createPreviewButton()
    % Set up button that allows you to preview a few letters/numbers with
    % the properties you've specified thus far
    global handle;
    
    previewButton   = uicontrol(handle, ...
                        'Style', 'pushbutton', ...
                        'String', 'Preview',...
                        'Position', [200 120 70 70]);
end

function previewButton_Callback(object, eventData)
    % Generate a preview in a new figure window
    global fontSelector;
    global sizeInput;
    global sampsPerPtInput;
    global boldCheckbox;
    global fractionalMetricsCheckbox;
    global antiAliasCheckbox;
    global previewFigure;
    
    % Get current font properties
    availableFonts = get(fontSelector,'String');
    fontFace    = availableFonts(get(fontSelector,'Value'));
    fontSize    = str2double(get(sizeInput, 'String'));
    sampsPerPt  = str2double(get(sampsPerPtInput, 'String'));
    isBold      = get(boldCheckbox, 'Value');
    hasFractionalMetrics = get(fractionalMetricsCheckbox, 'Value');
    isAA        = get(antiAliasCheckbox, 'Value');
    
    % Generate preview pane
    previewFigure = figure;
    set(previewFigure,'Name','Generating preview, please wait...', ...
        'NumberTitle','off');
    
    pause(.01); % Give system a second to throw up the figure window
    
    %Render text into pane
    img = renderText(sprintf('%s%s','a':'c','1':'3'), ...
        fontFace, fontSize, sampsPerPt, isAA, ...
        hasFractionalMetrics, isBold);
    
    set(previewFigure,'Name','Preview');
    imshow(img);
end

function saveButton = createSaveButton()
    % Set up the save button that lets you select the directory/filename
    global handle;
    
    saveButton      = uicontrol(handle, ...
                        'Style', 'pushbutton', ...
                        'String', 'Save',...
                        'Position', [200 40 70 70]);
    
end

function saveButton_Callback(object, eventData, sizeInput, increment)
    % Save out a mat file with the letters
    global fontSelector;
    global sizeInput;
    global sampsPerPtInput;
    global boldCheckbox;
    global fractionalMetricsCheckbox;
    global antiAliasCheckbox;
    
    availableFonts           = get(fontSelector,'String');
    params.fontName          = availableFonts(get(fontSelector,'Value'));
    params.fontSize          = str2double(get(sizeInput, 'String'));
    params.sampsPerPt        = str2double(get(sampsPerPtInput, 'String'));
    params.boldFlag          = get(boldCheckbox, 'Value');
    params.fractionalMetrics = get(fractionalMetricsCheckbox, 'Value');
    params.antiAlias         = get(antiAliasCheckbox, 'Value');
    
    fileName = mrvSelectFile('w','mat','Save to...');
    if (~isempty(fileName))
        wordGenLetterVar(fileName,params);
    end
    
end

function fontList = convertFontList(javaFontList)
    % Input javaFontList retrieved from java method, return a cell array to use
    % in creating a pop up menu in the GUI

    numFonts = length(javaFontList);
    fontList = cell(1,numFonts);
    for i = 1:numFonts
        fontList{i} = char(javaFontList(i));
    end

end

function index = findFontFaceDefaultIndex(availableFonts, fontFace)
    % Input the list of available fonts and return the index of one of the
    % common monospaced type fonts (if we don't find it, return index = 1)
    
    index = find(strcmp(availableFonts,fontFace));
    if isempty(index)
    	index = 1; % settle for the first
    end
    
end