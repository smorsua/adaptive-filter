function save_dec_txt(x, T, filepath)
    x_quant = fi(x, T);
    fid = fopen(filepath, "w");
    fprintf(fid, "%s\n", string(x_quant.dec));
    fclose(fid);
end