function write_results(cellArray, savefilename)
    ppath = cd; %fileparts(mfilename('fullpath'));
    f = strcat(ppath, filesep, savefilename, '.csv'); %strrep(strrep(datestr(clock), ':' , '-' ), ' ', '-'), '.csv')
    delimiter = ',';
    datei = fopen(f,'w');
    for z=1:size(cellArray,1)
        for s=1:size(cellArray,2)
            var = eval('cellArray{z,s}');

            if size(var,1) == 0
                var = '';
            end

            if isnumeric(var) == 1
                var = num2str(var);
            end

            if(iscell(var))
                var = var{1};
            end
            
            fprintf(datei,'%s', var);

            if s ~= size(cellArray,2)
                fprintf(datei,[delimiter]);
            end
        end
        fprintf(datei,'\n');
    end
    fclose(datei);
end

