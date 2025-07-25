function [R_pearson, R_pearson_nucleus, R_spearman, R_spearman_nucleus, T] = ...
    colCoefCalc(data12CH, ch_coloc, B6col, B6col_nucl, filepathR, nameR)

try 
    disp("COLOCALIZATION add-on: correlation coefficient calculation started.");

    dataCH1 = data12CH(:,:,ch_coloc(1));
    dataCH2 = data12CH(:,:,ch_coloc(2));
    nameR = nameR(1);
    filepathR = filepathR(1);

    R_pearson = corr2(dataCH1(B6col), ...
        dataCH2(B6col))
    R_pearson_nucleus = corr2(dataCH1(B6col_nucl), ...
        dataCH2(B6col_nucl))

    R_spearman = corr(dataCH1(B6col), ...
        dataCH2(B6col), 'type', 'Spearman')
    R_spearman_nucleus = corr(dataCH1(B6col_nucl), ...
        dataCH2(B6col_nucl), 'type', 'Spearman')

    T = table(R_pearson, R_pearson_nucleus, R_spearman, R_spearman_nucleus);
    writetable(T, strcat(filepathR, nameR, '-CorrelationCoef.xlsx'), 'Sheet', 1, 'Range', 'A1');

    disp("Correlation coefficient calculation finished successfully.");
    disp(strcat("Coefficient data saved as: ", filepathR, nameR, "-CorrelationCoef.xlsx"));
catch
    R_pearson = [];
    R_pearson_nucleus = [];
    R_spearman = [];
    R_spearman_nucleus = [];
    T = [];
    disp("COLOCALIZATION add-on | ERROR: Correlation coefficient calculation failed. Please check data and try again.");
end

end