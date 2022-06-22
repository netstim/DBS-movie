lead path

%% create initial fig
if 1
    copyfile('AllFibers',[ea_space([],'atlases'),'AllFibers']); % move atlas to atlases dir
    load options
    load LEAD_groupanalysis
    
    %% parts from lead group
    % amend .pt to identify which patient is selected (needed for isomatrix).
    for pt=1:length(M.patient.list)
        M.elstruct((pt)).pt=pt;
    end
    
    elmodels = [{'Patient specified'};ea_resolve_elspec];
    whichelmodel = elmodels{M.ui.elmodelselect};
    % account for electrode model specified in lead group
    if ~strcmp(whichelmodel,'Patient specified')
        arcell=repmat({whichelmodel},length(ptidx),1);
        [M.elstruct(ptidx).elmodel]=arcell{:};
    end
    
    
    resultfig=ea_elvis(options,M.elstruct);
    
    ea_setplanes(0,0,0,struct,'100um postmortem brain')
    % set contrast
    
    ea_setslidecontrast([],[],'c',0.35,resultfig);
    ea_setslidecontrast([],[],'o',-0.8,resultfig);

    allpatches = findall(resultfig,'Type','patch');
    [allpatches.AmbientStrength]=deal(0.6);
    [allpatches.DiffuseStrength]=deal(0.5);
    [allpatches.SpecularStrength]=deal(0.5);
    [allpatches.SpecularExponent]=deal(6);
    load('initial_view.mat')
    ea_view(initial_view);
    %saveas(resultfig,'dbsmovie.fig');
end

if ~exist('resultfig','var')
    resultfig=openfig('dbsmovie.fig');
end

lstrength=1; % changes of lights
ea_keepatlaslabels('off')
ea_view(initial_view);

eleGroupToggle=getappdata(resultfig,'eleGroupToggle');
eleGroupToggle.State='on';
eleGroupToggle.State='off';
el_render=getappdata(resultfig,'el_render');

%% stage one: slide 100um
fr=20;
video = VideoWriter(['dbsmovie.mp4'],'MPEG-4');
video.FrameRate=fr;
video.Quality = 95;
open(video)
ea_setplanes(-80,nan,nan);
load videopath_0
xxrange=-60:0.2:40;
inview=ea_interp_views(v,length(xxrange));
cnt=1;
for x=xxrange
    ea_setplanes(x,nan,nan);
    ea_view(inview(cnt));
   cnt=cnt+1;
    % GPi
    if x==-50
        el_render(2).showMacro=1;
    end
    if x==0
        el_render(2).showMacro=0;
    end
    % ALIC
    if x==-30
        el_render(4).showMacro=1;
    end
    if x==10
        el_render(4).showMacro=0;
    end
    % STN
    if x==0
        el_render(6).showMacro=1;
    end
    if x==20
        el_render(6).showMacro=0;
    end
    % Fornix
    if x==-5
        el_render(8).showMacro=1;
    end
    if x==30
        el_render(8).showMacro=0;
    end
    % Cg25
    if x==-35
        el_render(10).showMacro=1;
    end
    if x==10
        el_render(10).showMacro=0;
    end
    ea_lighteffect(resultfig,lstrength);
    drawnow
    writeVideo(video,getframe(resultfig));
end

addpause(resultfig,lstrength,video,20); % add 20 frames slightly fiddling with light

%% stage two: show atlases while rotating
eleGroupToggle.State='on';
eleGroupToggle.State='off';
ea_setplanes(30,nan,-30);
load('atlaslabels.mat')
load videopath_1
view=initial_view;
ea_keepatlaslabels(atlabels{(([rand(1,65),zeros(1,16),rand(1,6)]))>0.8});

for path=1:length(v)-1
       inview=ea_interp_views(v(path:path+1),300);
       for frame=1:length(inview)
           inframe=ceil(frame/3); % counting to 100
           ea_view(inview(frame));
           
           if rand(1)>0.99
              ea_keepatlaslabels(atlabels{(([rand(1,65),zeros(1,16),rand(1,6)]))>0.8}); 
           end
           
           if path==1 && inframe>84
               ea_setplanes(30,(-170+inframe),-30);
           end
           if path==2 && inframe==51
               ea_setplanes(-30,-70,-30);
           end
           if path==3 && inframe>89
               ea_setplanes(nan,-70,-120+inframe);
           end
           if path==4 && inframe==4
               ea_setplanes(nan,nan,-20);
           end
           if path==4 && inframe>79
               ea_setplanes(nan,30,60-inframe);
           end
           if path==5 && inframe==50
               ea_setplanes(40,30,-39);
           end
           if path==5 && inframe>89
               ea_setplanes(130-inframe,30,-129+inframe);
           end
           if path==5 && inframe==100
               ea_setplanes(30,nan,-30); % final setup
           end
           
           ea_lighteffect(resultfig,lstrength);
           drawnow;
           writeVideo(video,getframe(resultfig)); %use figure, since axis changes size based on view
       end
end
%ea_keepatlaslabels('AF');
%ea_keepatlaslabels('AF');
ea_keepatlaslabels('OFF');
ea_setplanes(30,nan,-30); % final setup
eleGroupToggle.State='off';
addpause(resultfig,lstrength,video,20); % add 20 frames slightly fiddling with light


%% stage full on:
load videopath_2
for path=1:length(v)-1
    inview=ea_interp_views(v(path:path+1),300);
    
    if path==2
        eleGroupToggle.State='on';
    end
    
    for frame=1:length(inview)

        ea_view(inview(frame));
        
        if path==1 && frame<10 % flicker electrodes
            for el=1:length(el_render)
            el_render(el).showMacro=rand(1)>0.3;
            end
        else
            eleGroupToggle.State='on';
        end
        
        if path==2
            atlkeep=66:81;
            keep=atlkeep((rand(16,1)*exp(frame/2))>1);
            if isempty(keep)
            ea_keepatlaslabels('OFF');
            else
            ea_keepatlaslabels(atlabels{keep});    
            end
        end
        if path==2 && frame==300
            addpause(resultfig,lstrength,video,40); % add 40 frames slightly fiddling with light
            ea_setplanes(nan,nan,-30);
        end
        
        if path==3 && frame==1
            ea_keepatlaslabels('ON');
        end
        
        ea_lighteffect(resultfig,lstrength);
        drawnow;
        writeVideo(video,getframe(resultfig)); %use figure, since axis changes size based on view

    end
end
addpause(resultfig,lstrength,video,20); % add 20 frames slightly fiddling with light

%% load cortex
load('BrainMesh_ICBM152_smoothed.mat');
load overlays % produces nii
load videopath_3
ea_view(v(1));
cortex=patch('Faces',ctx.faces,'Vertices',ctx.vertices,'FaceColor','w','FaceAlpha',0,'EdgeColor','none','FaceLighting','gouraud');

load head
headtransform=[0.8 0 0 4
    0 -0.78 0.17 7
    0 0.17 0.78 0
    0 0 0 1];
head.vertices=headtransform*[head.vertices,ones(length(head.vertices),1)]';
head.vertices=head.vertices(1:3,:)';
headpt=patch('Faces',head.faces,'Vertices',head.vertices,'FaceColor','w','FaceAlpha',0,'EdgeColor','none','FaceLighting','gouraud');


cnt=1;
gradientLevel = length(gray);

cmapNeg = ea_colorgradient(gradientLevel/2, [0.2,0.7,1], [1,1,1]);
cmapPos = ea_colorgradient(gradientLevel/2, [1,1,1], [1,0.3,0.0]);
cmap = [cmapNeg;cmapPos];
    innii=ea_interp_niis(nii,20);
overlaycnt=1;
takenii=nii(1); % to define mat
for path=1:length(v)-1
    inview=ea_interp_views(v(path:path+1),300);
    for frame=1:length(inview)
        if cnt<300
            set(cortex,'FaceAlpha',0.002*cnt);
        end

        if cnt==150
           ea_setplanes(nan,nan,nan); 
        end
        takenii.img=squeeze(innii(:,:,:,overlaycnt));
        overlaycnt=overlaycnt+1;
        if overlaycnt>size(innii,4)
            overlaycnt=1;
        end
        
        if path==4
            headpt.FaceAlpha=0.8*(frame/length(inview));
            
        end
        
        ea_overlaynii2patch(takenii,cortex,cmap)

        cnt=cnt+1;
        ea_view(inview(frame));
        drawnow
        writeVideo(video,getframe(resultfig));
    end
end

addpause(resultfig,lstrength,video,50); % add 50 frames slightly fiddling with light

close(video);




