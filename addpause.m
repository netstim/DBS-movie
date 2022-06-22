function addpause(resultfig,lstrength,video,plen)
for buff=1:plen
    ea_lighteffect(resultfig,lstrength*2);
    drawnow
    writeVideo(video,getframe(resultfig));
end
ea_lighteffect(resultfig,1,1); % reset