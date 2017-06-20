function ltxwrite(obj,name,tabname)

% Writing file
[fl msg] = fopen([tabname '.tex'],'w+');

if ~isempty(msg)
    disp('Erro de abertura de arquivo!');
end

% =========================================================================
fprintf(fl,'\\documentclass[12pt]{article}\n');
fprintf(fl,'\\usepackage{tabu}\n\n\n');

fprintf(fl,'\\begin{document}\n\n\n');


%fprintf(fl,'\\newcommand{\\thickhline}{%%\n');
%    fprintf(fl,'\t\\noalign {\\ifnum 0=`}\\fi \\hrule height 1pt\n');
%    fprintf(fl,'\t\\futurelet \\reserved@a \\@xhline\n');
%    fprintf(fl,'\t}\n\n');

fprintf(fl,'%% Table of statistics.\n');
fprintf(fl,'\\begin{table}[h]\n');
    fprintf(fl,'\\caption{Sum\\''ario de ANOVAN com testes F parciais e ICs dos coeficientes para %s.}\\label{tab%s}\n',name,name);
	fprintf(fl,'\t\\begin{tabu}{p{5cm} c c c c c c}\n');
        % Cabeçalho.
		fprintf(fl,'\t\t\\tabucline[2pt]{-}\n');
			fprintf(fl,'\t\t\t\\textbf{Fonte de Variabilidade} & \\multicolumn{6}{c}{\\textbf{Estatatísticas}} \\\\ \\cline{2-7}\n');
			fprintf(fl,'\t\t\t& \\textbf{SS} & \\textbf{DF} & \\textbf{MS} & \\textbf{F} & \\textbf{p} & \\textbf{ICs} \\\\\n');
        fprintf(fl,'\t\t\\hline\n');
            
            % Corpo da tabela.
			fprintf(fl,'\t\t\t \\textbf{Regressao} & %.4f & %d & %.4f & %.2f & %.4f & \\\\\n',obj.SSr,obj.k,obj.MSr,obj.F,obj.pF);
                fprintf(fl,'\t\t\t coef. 1: contant & %.4f & %d & %.4f & %0.2f & %0.2f & [%0.2f %0.2f] \\\\\n',obj.SSrB_j(1),1,obj.SSrB_j(1),obj.tB_j(1),obj.pB_j(1),obj.CIB_j(1,1),obj.CIB_j(1,2));
                for i = 2:size(obj.tB_j)
                    fprintf(fl,'\t\t\t coef. %d & %.4f & %d & %.4f & %0.2f & %0.2f & [%0.2f %0.2f] \\\\\n',i,obj.SSrB_j(i),1,obj.SSrB_j(i),obj.tB_j(i),obj.pB_j(i),obj.CIB_j(i,1),obj.CIB_j(i,2));
                    %fprintf(fl,'\t\t\t coef. 2: NN1 & %.4f & %d & %.4f & %0.2f & %0.2f & [%0.2f %0.2f] \\\\\n',obj.SSrB_j(2),1,obj.SSrB_j(2),obj.tB_j(2),obj.pB_j(2),obj.CIB_j(2,1),obj.CIB_j(2,2));
                    %fprintf(fl,'\t\t\t coef. 3: NN2 & %.4f & %d & %.4f & %0.2f & %0.2f & [%0.2f %0.2f] \\\\\n',obj.SSrB_j(3),1,obj.SSrB_j(3),obj.tB_j(3),obj.pB_j(3),obj.CIB_j(3,1),obj.CIB_j(3,2));
                    %fprintf(fl,'\t\t\t coef. 4: FTN & %.4f & %d & %.4f & %0.2f & %0.2f & [%0.2f %0.2f] \\\\\n',obj.SSrB_j(4),1,obj.SSrB_j(4),obj.tB_j(4),obj.pB_j(4),obj.CIB_j(4,1),obj.CIB_j(4,2));
                end
            fprintf(fl,'\t\t\t \\textbf{Erro} & %.4f & %d & %.4f & & & \\\\\n',obj.SSe,obj.n-obj.k,obj.MSe);
            fprintf(fl,'\t\t\t \\textbf{Total} & %.4f & %d & & & & \\\\\n',obj.SSt,obj.n-obj.k-1);
        fprintf(fl,'\t\t\\tabucline[2pt]{-}\n');
        
	fprintf(fl,'\t\\end{tabu}\n');
fprintf(fl,'\\end{table}\n');


% Fora da tabela.
fprintf(fl,'\nS: %0.2f;  $R^{2}$: %0.2f; $R^{2}_{adj}$: %0.2f; $R^{2}_{pred}$: %0.2f; PRESS: %0.2f. \\\\\n',obj.S,obj.R2,obj.R2adj,obj.R2pred,obj.PRESS);

fprintf(fl,'\n\\end{document}\n');

% =========================================================================

fclose(fl);

system(['pdflatex ' tabname '.tex']);
